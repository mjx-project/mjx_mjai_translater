require './lib/mjx_mjai_translater/trans_server'
require './lib/mjx_mjai_translater/mjx_to_mjai'
require './lib/mjx_mjai_translater/trans_player'
require './lib/mjx_mjai_translater/mjai_action_to_mjx_action'
require_relative "../mjai/lib/mjai/mjai_command"
require "timeout"

params = {
        :host => "127.0.0.1",
        :port => 11659,
        :room => "default",
        :game_type => "game_type:one_kyoku".intern,
        :player_commands => ["mjai-shanten"],
        :num_games => 1,
        :log_dir => "log",
    }


RSpec.describe 'do_action' do
    it 'test_do_action' do
        server = TCPServer.open(params[:host], params[:port]) 
        trans_server = TransServer.new({:target_id=>0, "test"=>"yes"})
        p "a"
        start_default_players_2(params)
        p "default_player立ち上げました"
        Timeout.timeout(10) do
            Thread.new(server.accept()) do |socket|
                p "処理を開始します"
                player = Player.new(socket, 0, nil)
                trans_server.set_player(player)
                p "trans_server立ち上げました"
                response = trans_server.do_action(
                    MjaiAction.new(
                       {:type=>:hello}
                    ))
                p response
                s.close()
            end
        end
    end
end