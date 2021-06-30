this_dir = __dir__
lib_dir = File.join(this_dir, '../mjxproto/')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)
require "grpc"
$LOAD_PATH.unshift(__dir__) unless $LOAD_PATH.include?(__dir__)
require 'random_agent'
require 'mjx_to_mjai'
require 'mjai_action_to_mjx_action'
#変換サーバの本体

class TransServer < Mjxproto::Agent::Service
    
    def initialize() # params paramsはcommandからextractされる。
        @params = nil# params
        @num_player_size = 4#@params[:num_player_size]
        @players = []
        @server = nil #TCPServer.open(params[:host], params[:port]) 
        @absolutepos_id_hash = {0=>0,1=>1,
        2=>2, 3=>3} # default absolute_posとidの対応 mjxとmjaiのidが自然に対応しないのが原因 対応させる関数を作る必要がある。
        @_mjx_public_observatoin = nil
        @new_mjai_acitons = []
        @next_mjx_actions = []
        initialize_players(@server)# クラスができるときにplayerも必要な数作るようにする。
    end

    def run()
        #TCPserverにおけるrunの部分
        initial_communication()
        initialize_players(socket)
        while true
          observation = get_observation()
          take_action(observation)
        end
        
    end


    def initial_communication() # clientとの最初の通信
    end

    def initialize_players(socket)
        @num_player_size.times do |i|
             @players.push(Player.new(socket, i)) # ここの作る順番がidになる。 
        end
    end          

    def do_action(action) # mjai_clientにactionを渡してresponseを得る。
        #mjaiと同じ実装
        if action.is_a?(Hash)
            action = Action.new(action)
          end
          #update_state(action)これはmjxがやる
          #@on_action.call(action) if @on_action
          responses = (0...4).map() do |i|  
            @players[i].respond_to_action(action_in_view(action, i, true))  # aciton_in_view()実装する必要あり
          end
          #action_with_logs = action.merge({:logs => responses.map(){ |r| r && r.log }})
          responses = responses.map(){ |r| (!r || r.type == :none) ? nil : r.merge({:log => nil}) }
          #@on_responses.call(action_with_logs, responses) if @on_responses
          #@previous_action = action
          #validate_responses(responses, action)
          return responses
    end

    def action_in_view(action, player_id, for_response)  # action_in_viewをこちらで実装する。
        #全体を見て必要な情報
        #①各プレイヤーのpossible_actitons
        #②各playerの手配
        player = @players[player_id]
        with_response_hint = true #for_response && expect_response_from?(player)
        case action.type
          when :start_game
            return action.merge({:id => player_id})
          when :start_kyoku
            tehais_list = action.tehais.dup()
            for i in 0...4
              if i != player_id
                tehais_list[i] = ["none"] * tehais_list[i].size  # Pai::UNKNOWN
              end
            end
            return action.merge({:tehais => tehais_list})
          when :tsumo
            if action.actor == player
              return action.merge({
                  :legal_actions =>
                      with_response_hint ? player.legal_actions() : nil,
              })
            else
              return action.merge({:pai => "none"}) # Pai::UNKNOWN
            end
          when :dahai, :kakan
            if action.actor != player
              return action.merge({
                  :legal_actions =>
                      with_response_hint ? player.legal_actions() : nil,
              })
            else
              return action
            end
          when :chi, :pon
            if action.actor == player
              return action.merge({
                  :cannot_dahai =>
                      with_response_hint ? player.forbidden_tiles_mjai() : nil,
              })
            else
              return action
            end
          when :reach
            if action.actor == player
              return action.merge({
                  :cannot_dahai =>
                      with_response_hint ? player.forbidden_tiles_mjai() : nil,
              })
            else
              return action
            end
          else
            return action
        end
    end

    def update_next_actions(responses)
        #　ユーザーのアクションに対してmjaiのアクションからmjxのアクションに変更する
        next_mjai_actions = []
        responses.length.times do |i|
            next_mjai_actions.push(mjai_act_to_mjx_act(responses[i]))
        end
        return next_mjai_actions
    end


    def extract_difference(previous_public_observation = @_mjx_public_observatoin, observation)  # public_observatoinの差分を取り出す
        if !previous_public_observation
            return observation.public_observation.events
        end
        current_public_observation = observation.public_observation.events
        difference_history = current_public_observation[previous_public_observation.length ..]
        @_mjx_public_observatoin = current_public_observation  #更新
        return difference_history
    end


    def convert_to_mjai_actions(observation, scores)  # scoresはriichi_acceptedを送る場合などに使う
        public_observation_difference = history_difference = extract_difference(@_mjx_public_observatoin, observation) # 差分
        mjai_actions = []
        public_observation_difference.length.times do |i|
           mjai_action = MjxToMjai.new(@absolutepos_id_hash).mjx_event_to_mjai_action(public_observation_difference[i],observation, scores)  # mjxのeventをmjai actioinに変換
           mjai_actions.push(mjai_action)
        end
        return mjai_actions
    end

    
    def observe(observation)
        @scores = observation.state.init_score.ten  # scoreを更新 mjaiのactionに変換する際に使用
        @new_mjai_acitons = convert_to_mjai_actions(history_difference,@scores) # mjai_actionsを更新
        # self._mjx_public_observatoinと照合してself.mjai_new_actionsを更新する。mjaiのactionの方が種類が多い（ゲーム開始、局開始等） 
    end


    def get_mjx_actions()  # mjxからobservagtionを取得する。
      return observation
    end


    def take_action(observation, _unused_call)
        obserbve(observation)
        responses = []
        for mjai_action in self.mjai_new_actinos
            responses.push(self.do_action(mjai_action))
        end
        @next_mjx_actions = update_next_actions(responses)
        return @next_mjx_actions #mjxへactionを返す。
    end
end
