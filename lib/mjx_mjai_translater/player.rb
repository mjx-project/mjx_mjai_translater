#player クラス
#役割
#- mjaiのクライアントとの交信に必要な情報の保持 -> 自分でインスタンス変数を設定
#- mjaiのクライアントとのsocket通信 -> mjaiからのコピペ


class Player 
    def initialize()
        
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