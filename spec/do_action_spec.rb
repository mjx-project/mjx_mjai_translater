require './lib/mjx_mjai_translater/trans_server'
require './lib/mjx_mjai_translater/mjx_to_mjai'
require './lib/mjx_mjai_translater/trans_player'
require './lib/mjx_mjai_translater/mjai_action_to_mjx_action'
require_relative "../mjai/lib/mjai/jsonizable"
require "timeout"

params = {
        :host => "127.0.0.1",
        :port => 11600,
        :room => "default",
        :game_type => "game_type:one_kyoku".intern,
        :player_commands => ["tsumgiri"],
        :num_games => 1,
        :log_dir => "log",
    }


RSpec.describe 'do_action' do
    it 'test_do_action' do
        server = TCPServer.open(params[:host], params[:port]) 
        trans_server = TransServer.new({:target_id=>0, "test"=>"yes"})
        Timeout.timeout(10) do
            Thread.new(server.accept()) do |socket|
                p "処理を開始します"
                player = Player(socket, 0)
                trans_server.set_player(player)
                p "trans_server立ち上げました"
                start_default_players_2(params)
                p "default_player立ち上げました"
                response = trans_server.do_action(
                    MjaiAction.new(
                        {:type=>:start_kyoku, :kyoku=>1, :bakaze=>Mjai::Pai.new("E"), :honba=>1, :kyotaku=>0, :oya=>0, :dora_marker=>Mjai::Pai.new("2s"), :tehais=>[[Mjai::Pai.new("9p"), Mjai::Pai.new("5s"), Mjai::Pai.new("N"), Mjai::Pai.new("F"), Mjai::Pai.new("N"), Mjai::Pai.new("2m"), Mjai::Pai.new("9s"), Mjai::Pai.new("7m"), Mjai::Pai.new("4p"), Mjai::Pai.new("N"), Mjai::Pai.new("4s"), Mjai::Pai.new("E"), Mjai::Pai.new("3m")], [Mjai::Pai.new("?")]*13, [Mjai::Pai.new("?")]*13, [Mjai::Pai.new("?")]*13]}
                        )
                    )
                p response
                s.close()
            end
        end
    end
end