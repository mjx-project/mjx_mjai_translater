this_dir = __dir__
lib_dir = File.join(this_dir, '../mjxproto/')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)
require "grpc"
require "socket"
$LOAD_PATH.unshift(__dir__) unless $LOAD_PATH.include?(__dir__)
require 'trans_player'
require 'mjx_to_mjai'
require 'mjai_action_to_mjx_action'
require 'action'
require 'player'
#変換サーバの本体

class TransServer < Mjxproto::Agent::Service
    
    def initialize(params) # params paramsはcommandからextractされる。
        @params = params
        @absolutepos_id_hash = {0=>0,1=>1,
        2=>2, 3=>3} # default absolute_posとidの対応 mjxとmjaiのidが自然に対応しないのが原因 対応させる関数を作る必要がある。
        @_mjx_events = nil
        @target_id = params[:target_id]
        @new_mjai_acitons = []
        @next_mjx_actions = []
        if !params["test"]
          @server = TCPServer.open(params[:host], params[:port]) 
          @socket = @server.accept()
          @player = Player.new(@socket, @target_id, "name")
        end
    end

    def set_mjx_events(mjx_events)  # for test
      @_mjx_events = mjx_events
    end

    def get_mjai_actions()  # for test
      return @new_mjai_acitons
    end

    def set_player(player)  # for test
      @player = player
    end


    def do_action(action) # mjai_clientにactionを渡してresponseを得る。
        #mjaiと同じ実装
        if action.is_a?(Hash)
            action = MjaiAction.new(action)
          end
          responses = @player.respond_to_action_of_translator(action_in_view(action, @target_id, true))  
          #responses = responses.map(){ |r| (!r || r.type == :none) ? nil : r.merge({:log => nil}) }
          return responses
    end

    def action_in_view(action, player_id, for_response)  # action_in_viewをこちらで実装する。
        #全体を見て必要な情報
        #①各プレイヤーのpossible_actitons
        #②各playerの手配
        with_response_hint = true #for_response && expect_response_from?(player)
        case action.type
          when :start_game
            return action.merge({:id => player_id})
          when :start_kyoku
            tehais_list = action.tehais.dup()
            for i in 0...4
              if i != player_id
                tehais_list[i] = [Mjai::Pai.new("?")] * tehais_list[i].size  # Pai::UNKNOWN
              end
            end
            return action.merge({:tehais => tehais_list})
          when :tsumo
            if action.actor == player_id
              return action.merge({
                  :possible_actions =>
                      with_response_hint ? @player.legal_actions() : nil,
              })
            else
              return action.merge({:pai => Mjai::Pai.new("?")}) # Pai::UNKNOWN
            end
          when :dahai, :kakan
            if action.actor != player_id
              return action.merge({
                  :possible_actions =>
                      with_response_hint ? @player.legal_actions() : nil,
              })
            else
              return action
            end
          when :chi, :pon
            if action.actor == player_id
              return action.merge({
                  :cannot_dahai =>
                      with_response_hint ? @player.forbidden_tiles_mjai() : nil,
              })
            else
              return action
            end
          when :reach
            if action.actor == player_id
              return action.merge({
                  :cannot_dahai =>
                      with_response_hint ? @player.forbidden_tiles_mjai() : nil,
              })
            else
              return action
            end
          else
            return action
        end
    end


    def update_next_actions(responses, observation)
        #　ユーザーのアクションに対してmjaiのアクションからmjxのアクションに変更する
        next_mjx_actions = []
        legal_actions = observation.legal_actions
        mjai_to_mjx = MjaiToMjx.new(@absolutepos_id_hash)
        responses.length.times do |i|
            next_mjx_actions.push(mjai_to_mjx.mjai_act_to_mjx_act(responses[i], legal_actions))
        end
        if MjxToMjai.new(@absolutepos_id_hash, @target_id).is_kyoku_over(observation)
          next_mjx_actions.push(legal_actions[0])
        end
        return next_mjx_actions
    end


    def extract_difference(observation, previous_events = @_mjx_events)  # public_observatoinの差分を取り出す
        #STDERR.puts observation
        if !previous_events
            return observation.public_observation.events
        end
        current_events = observation.public_observation.events
        difference_history = current_events[previous_events.length ..]
        @_mjx_events = current_events  #更新
        return difference_history
    end


    def convert_to_mjai_actions(observation, scores)  # scoresはriichi_acceptedを送る場合などに使う
        public_observation_difference  = extract_difference(observation) # 差分
        mjai_actions = []
        mjx_to_mjai = MjxToMjai.new(@absolutepos_id_hash, @target_id)
        if mjx_to_mjai.is_start_game(observation)
          mjai_actions.push(MjaiAction.new({:type=>:start_game}))
        end
        if mjx_to_mjai.is_start_kyoku(observation)
          mjai_actions.push(mjx_to_mjai.start_kyoku(observation))
        end
        public_observation_difference.length.times do |i|
           mjai_action = mjx_to_mjai.mjx_event_to_mjai_action(public_observation_difference[i],observation, scores)  # mjxのeventをmjai actioinに変換
           mjai_actions.push(mjai_action)
        end
        if mjx_to_mjai.is_kyoku_over(observation)
          mjai_actions.push(MjaiAction.new({:type=>:end_kyoku}))
          @_mjx_events = nil
       end
       if mjx_to_mjai.is_game_over(observation)
          mjai_actions.push(MjaiAction.new({:type=>:end_game}))
          @_mjx_events = nil # gameが終わった時にreset
       end
        return mjai_actions
    end

    
    def observe(observation)
        @scores = observation.public_observation.init_score.tens  # scoreを更新 mjaiのactionに変換する際に使用
        #history_difference = extract_difference(observation)
        #puts history_difference
        @new_mjai_acitons = convert_to_mjai_actions(observation,@scores) # mjai_actionsを更新
        if @player
          hand = observation.private_observation.curr_hand.closed_tiles  # 実際に渡されるhandは晒した牌は除かれている
          legal_actions = observation.legal_actions
          @player.update_hand(hand)
          @player.update_legal_actions(legal_actions)
        end
        #STDERR.puts @new_mjai_acitons
        # self._mjx_public_observatoinと照合してself.mjai_new_actionsを更新する。mjaiのactionの方が種類が多い（ゲーム開始、局開始等） 
    end


    def take_action(observation, _unused_call)
        #puts observation
        obserbve(observation)
        responses = []
        for mjai_action in @mjai_new_actinos
            responses.push(self.do_action(mjai_action))
        end
        @next_mjx_actions = update_next_actions(responses, observation)
        return @next_mjx_actions[-1] #mjxへactionを返す。最後のactionだけ参照勝すれば良い
    end

end

def main  # agentを1対立てる
  s = GRPC::RpcServer.new
  s.add_http2_port('0.0.0.0:50052', :this_port_is_insecure)
  s.handle(TransServer.new({:target_id=>3, :host=>"127.0.0.1", :port=>11600}))
  s.run_till_terminated_or_interrupted([1, 'int', 'SIGQUIT'])
end

if __FILE__ == $0
  main
end



