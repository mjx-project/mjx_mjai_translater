require "random_agent"
this_dir = __dir__
lib_dir = File.join(this_dir, '../mjxproto')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)
require 'grpc'
require 'mjx_services_pb'
require "socket"
require "thread"
#変換サーバの本体

class TransServer << Mjxproto::Agent::Service
    
    def initialize()
        @players = []
        @_mjx_event_history = []
        @new_mjai_acitons = []
        @next_mjx_actions = []
    end


    def initialize_players(host, port)#serverを立てて、playerをコマンドの数に応じて立てる
        @mutex = Mutex.new()
        @server = TCPServer.open(host, port)
                


    def do_action(action)
        #mjaiと同じ実装
    end

        
    def step(new_event):
        # do_actionの呼ばれ方がActiveGame内で11パターンあったので、それらを模倣する
    end
    

    def update_next_actions(response)
        #　ユーザーのアクションに対してmjaiのアクションからmjxのアクションに変更する
    end


    def get_curr_player(observation)
    end

    
    def observe(observation)
    end


    def take_action(observation, _unused_call)
        obserbve(observation)
        curr_player = get_curr_player(observation)
        response = none
        for mjai_action in self.mjai_new_actinos:
            response = self.do_action(mjai_action)
        self.next_mjx_actions = update_next_actions(response)
        return self.next_mjx_actions[curr_player]
    end



end
