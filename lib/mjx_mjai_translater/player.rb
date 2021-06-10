#player クラス
#役割
#- mjaiのクライアントとの交信に必要な情報の保持 -> 自分でインスタンス変数を設定
#- mjaiのクライアントとのsocket通信 -> mjaiからのコピぺ
$LOAD_PATH.unshift(__dir__) unless $LOAD_PATH.include?(__dir__)
require "mjx_to_mjai"

class Player 

    def initialize(socket, id)
        @legal_actions = []  # mjxとのやりとりで更新していく
        @hand = []  # mjxとのやりとりで更新していく。
        @socket = socket
        @id = id
        @absolutepos_id_hash = {0=>0,1=>1,
        2=>2, 3=>3}
    end


    def update_possible_actoins(legal_actions)
      @legal_actions= legal_actions
    end


    def update_hand(hand)
      @hand = hand
    end


    def legal_actions()
      mjx_to_mjai = MjxToMjai.new(@absolutepos_id_hash)
      return @legal_actions.map { |x| mjx_to_mjai.mjx_act_to_mjai_act(x) }
    end


    def hand()
        return @hand
    end


    def from_actions_to_discard_tiles(actions)  # possible actionの中からdiscardに関するものだけを取得する。
      tiles = []
      if actions.length.times do |i|
        if actions[i].type == :ACTION_TYPE_DISCARD
           tiles.push(actions[i].tile)
        end
      end
      return tiles
    end
  end


  def forbidden_tiles_mjai()  # 手牌のうち,possible action に含まれていないものを返す。
        possible_tiles = from_actions_to_discard_tiles(@legal_actions)
        mjx_to_mjai = MjxToMjai.new(nil)
        return mjx_to_mjai.proto_tiles_to_mjai_tiles(@hand).uniq() - mjx_to_mjai.proto_tiles_to_mjai_tiles(possible_tiles)  #mjaiのformatで処理する。
  end


  def respond_to_action(action)
        begin
          puts("server -> player %d\t%s" % [self.id, action.to_json()])
          @socket.puts(action.to_json())
          line = nil
          Timeout.timeout(TIMEOUT_SEC) do
            line = @socket.gets()
          end
          if line
            puts("server <- player %d\t%s" % [self.id, line])
            return Action.from_json(line.chomp(), self.game)
          else
            puts("server :  Player %d has disconnected." % self.id)
            return Action.new({:type => :none})
          end
          
        rescue Timeout::Error
          return create_action({
              :type => :error,
              :message => "Timeout. No response in %d sec." % TIMEOUT_SEC,
          })
        rescue JSON::ParserError => ex
          return create_action({
              :type => :error,
              :message => "JSON syntax error: %s" % ex.message,
          })
        rescue ValidationError => ex
          return create_action({
              :type => :error,
              :message => ex.message,
          })
          
        end
        
    end
      
end
