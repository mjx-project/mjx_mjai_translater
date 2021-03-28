this_dir = __dir__
lib_dir = File.join(this_dir, '../mjxproto')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)
require "grpc"
require 'mjx_services_pb'
$LOAD_PATH.unshift(__dir__) unless $LOAD_PATH.include?(__dir__)
require 'random_agent'
require 'mjx_to_mjai'
#変換サーバの本体

class TransServer < Mjxproto::Agent::Service
    
    def initialize()
        @players = []
        @_mjx_event_history = nil
        @new_mjai_acitons = []
        @next_mjx_actions = []
    end


    def initialize_players(host, port)
        #- Serverを立てる
        #- Clientと最初の通信をする。(クライアントの数がわかっていればいらないかも)
        #- TCPPlayerをクライアントの数の分立てる
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

        
    def step(new_event)
        # do_actionの呼ばれ方がActiveGame内で11パターンあったので、それらを模倣する
    end
    

    def update_next_actions(response)
        #　ユーザーのアクションに対してmjaiのアクションからmjxのアクションに変更する
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


    def convert_to_mjai_actions(history_difference)
        # event_histryの差分に対して他のfileで定義されている変換関数を適用する。
        mjai_actions = []
        history_difference.length.time |i|
           mjai_action = MjxToMjai.mjx_event_to_mjai_action(history_difference[i])
           mjai_actions.push(mjai_action)
        end
        return mjai_actions
    end

    
    def observe(observation)
        history_difference = extract_difference(@_mjx_event_history, observation)
        # mjx_actions = convert_to_mjai_actions(history_difference)
        # self._mjx_event_historyと照合してself.mjai_new_actionsを更新する。mjaiのactionの方が種類が多い（ゲーム開始、局開始等） この関数の中でdrawsを追加する。
    end


    def take_action(observation, _unused_call)
        obserbve(observation)
        curr_player = get_curr_player(observation)
        response = none
        for mjai_action in self.mjai_new_actinos
            response = self.do_action(mjai_action)
        end
        self.next_mjx_actions = update_next_actions(response)
        return self.next_mjx_actions[curr_player]
    end
end
