this_dir = __dir__
lib_dir = File.join(this_dir, '../mjxproto')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)
require "grpc"
require 'mjx_services_pb'
$LOAD_PATH.unshift(__dir__) unless $LOAD_PATH.include?(__dir__)
require 'random_agent'
require 'mjx_to_mjai'
require 'mjai_action_to_mjx_action'
#変換サーバの本体

class TransServer < Mjxproto::Agent::Service
    
    def initialize(params) # paramsはcommandからextractされる。
        @params = params
        @num_player_size = @params[:num_player_size]
        @players = []
        @server = TCPServer.open(params[:host], params[:port])
        @absolutepos_id_hash = {:ABSOLUTE_POS_INIT_EAST=>0,:ABSOLUTE_POS_INIT_SOUTH=>1,
        :ABSOLUTE_POS_INIT_WEST=>2, :ABSOLUTE_POS_INIT_NORTH=>3} # default absolute_posとidの対応 mjxとmjaiのidが自然に対応しないのが原因 対応させる関数を作る必要がある。
        @_mjx_event_history = nil
        @new_mjai_acitons = []
        @next_mjx_actions = []
    end

    def run()
        #TCPserverにおけるrunの部分
        #- Clientと最初の通信をする。(クライアントの数がわかっていればいらないかも)


    def initialize_players(socket)
        @num_player_size.times do |i|
             @players.push(Player.new(socket, i)) # ここの作る順番がidになる。 やっぱり,最初にidとmjxのabsolute_posを対応させる関数がいる。
        end
    end          

    def do_action(action)
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
        with_response_hint = for_response && expect_response_from?(player)
        case action.type
          when :start_game
            return action.merge({:id => player_id})
          when :start_kyoku
            tehais_list = action.tehais.dup()
            for i in 0...4
              if i != player_id
                tehais_list[i] = [Pai::UNKNOWN] * tehais_list[i].size
              end
            end
            return action.merge({:tehais => tehais_list})
          when :tsumo
            if action.actor == player
              return action.merge({
                  :possible_actions =>
                      with_response_hint ? player.possible_actions : nil,
              })
            else
              return action.merge({:pai => Pai::UNKNOWN})
            end
          when :dahai, :kakan
            if action.actor != player
              return action.merge({
                  :possible_actions =>
                      with_response_hint ? player.possible_actions : nil,
              })
            else
              return action
            end
          when :chi, :pon
            if action.actor == player
              return action.merge({
                  :cannot_dahai =>
                      with_response_hint ? player.kuikae_dahais : nil,
              })
            else
              return action
            end
          when :reach
            if action.actor == player
              return action.merge({
                  :cannot_dahai =>
                      with_response_hint ? (player.tehais.uniq() - player.possible_dahais) : nil,
              })
            else
              return action
            end
          else
            return action
        end

        
    def step(new_event)
        # do_actionの呼ばれ方がActiveGame内で11パターンあったので、それらを模倣する
    end
    

    def update_next_actions(responses)
        #　ユーザーのアクションに対してmjaiのアクションからmjxのアクションに変更する
        next_mjai_actions = []
        responses.length.times do |i|
            next_mjai_actions.push(mjai_act_to_mjx_act(responses[i]))
        end
        return next_mjai_actions
    end


    def get_curr_player(observation)
        #  行動したプレイヤーをobservationから出力する。
    end


    def extract_difference(previous_history = @_mjx_event_history, observation)  # event_historyの差分を取り出す
        if !previous_history
            return current_history = observation.event_history.events
        end
        current_history = observation.event_history.events
        difference_history = current_history[previous_history.length ..]
        @_mjx_event_history = current_history  #更新
        return difference_history
    end


    def convert_to_mjai_actions(history_difference, scores)  # scoresはriichi_acceptedを送る場合などに使う
        # event_histryの差分に対して他のfileで定義されている変換関数を適用する。
        mjai_actions = []
        history_difference.length.times do |i|
           mjai_action = MjxToMjai.new(@absolutepos_id_hash).mjx_event_to_mjai_action(history_difference[i], scores)  # mjxのeventをmjai actioinに変換
           mjai_actions.push(mjai_action)
        end
        return mjai_actions
    end

    
    def observe(observation)
        history_difference = extract_difference(@_mjx_event_history, observation)
        @scores = observation.state.init_score.ten  # scoreを更新 mjaiのactionに変換する際に使用
        mjx_actions = convert_to_mjai_actions(history_difference,@scores)
        # self._mjx_event_historyと照合してself.mjai_new_actionsを更新する。mjaiのactionの方が種類が多い（ゲーム開始、局開始等） この関数の中でdrawsを追加する。
    end


    def take_action(observation, _unused_call)
        obserbve(observation)
        curr_player = get_curr_player(observation)
        responses = none
        for mjai_action in self.mjai_new_actinos
            responses = self.do_action(mjai_action)
        end
        self.next_mjx_actions = update_next_actions(responses)
        return self.next_mjx_actions[curr_player]
    end
end
