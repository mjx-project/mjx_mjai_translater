#player クラス
#役割
#- mjaiのクライアントとの交信に必要な情報の保持 -> 自分でインスタンス変数を設定
#- mjaiのクライアントとのsocket通信 -> mjaiからのコピぺ
$LOAD_PATH.unshift(__dir__) unless $LOAD_PATH.include?(__dir__)
require "mjx_to_mjai"
require "action"
require "timeout"
class Player
    TIMEOUT_SEC = 60
    def initialize(socket, id, name)
        @socket = socket
        @observation = nil
        @id = id # mjaiのid
        @name = name
        @absolutepos_id_hash = {0=>0,1=>1,
        2=>2, 3=>3}
    end

    attr_accessor :id, :name, :observation

    def legal_actions()
      mjx_to_mjai = MjxToMjai.new(@absolutepos_id_hash, @id)  # leagal actionを参照するのはtarget playerのみ
      legal_actions = @observation.legal_actions
      return legal_actions.map { |x| mjx_to_mjai.mjx_act_to_mjai_act(x, @observation) }  # ここではpublic_observationは不要
    end
    

    def from_actions_to_discard_tiles(actions)  # possible actionの中からdiscardに関するものだけを取得する。
      tiles = []
      if actions.length.times do |i|
        if actions[i].type == :ACTION_TYPE_DISCARD or actions[i].type == :ACTION_TYPE_TSUMOGIRI
           tiles.push(actions[i].tile)
        end
      end
      return tiles
    end
  end


  def forbidden_tiles_mjai()  # 手牌のうち,possible action に含まれていないものを返す。
      legal_actions = @observation.legal_actions
      hand = @observation.private_observation.curr_hand.closed_tiles
      possible_tiles = from_actions_to_discard_tiles(legal_actions)
      mjx_to_mjai = MjxToMjai.new(nil, @id)
      return mjx_to_mjai.proto_tiles_to_mjai_tiles(hand).uniq() - mjx_to_mjai.proto_tiles_to_mjai_tiles(possible_tiles)  #mjaiのformatで処理する。
  end


  def respond_to_action_of_translator(action)
        begin
          p "playerから送る直前のaction"
          p action
          #p "直前にto_jsonがうまく行っているか"
          #p action.to_json
          #puts("server -> player %d\t%s" % [self.id, action.to_json()])
          @socket.puts(action.to_json())
          line = nil
          Timeout.timeout(TIMEOUT_SEC) do
            line = @socket.gets()
          end
          if line
            #puts("server <- player %d\t%s" % [self.id, line])
            
            return MjaiAction._from_json(line.chomp())
          else
            #puts("server :  Player %d has disconnected." % self.id)
            return MjaiAction.new({:type => :none})
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
