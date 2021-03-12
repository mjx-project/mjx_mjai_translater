require "random_agent"
#変換サーバの本体

class TransServer << Mjxproto::Agent::Service
    
    def initialize()
        self.players = []
        self._mjx_event_history = []
        self.new_mjai_acitons = []
        self.next_mjx_actions = []
    end


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

    def take_action(obser_vation)
        obserbve(observation)
        curr_player = get_curr_player(observation)
        response = none
        for mjai_action in self.mjai_new_actinos:
            response = self.do_action(mjai_action)
        self.next_mjx_actions = update_next_actions(response)
        return self.next_mjx_actions[curr_player]
    end



end
