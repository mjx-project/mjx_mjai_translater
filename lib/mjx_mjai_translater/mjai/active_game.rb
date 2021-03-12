require "mjai/action"
require "mjai/pai"

class ActiveGame
    def initialize(players = nil)
        self.players = players if players
    end
    

    def players=(players)
        @players = players
        for player in @players
            player.game = self
        end
    end


    def on_action(&block)
        @on_action = block
    end
      

    def on_responses(&block)
        @on_responses = block
    end


    def do_action(action)
          
        if action.is_a?(Hash)
          action = Action.new(action)
        end
        
        #update_state(action) 変換サーバには必要ない
        
        @on_action.call(action) if @on_action
        
        responses = (0...4).map() do |i|
          @players[i].respond_to_action(action_in_view(action, i, true))
        end

        action_with_logs = action.merge({:logs => responses.map(){ |r| r && r.log }})
        responses = responses.map(){ |r| (!r || r.type == :none) ? nil : r.merge({:log => nil}) }
        @on_responses.call(action_with_logs, responses) if @on_responses

        @previous_action = action
        validate_responses(responses, action)
        return responses
        
    end