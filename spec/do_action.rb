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
params_2 = {
    :host => "127.0.0.1",
    :port => 11658,
    :room => "default",
    :game_type => "game_type:one_kyoku".intern,
    :player_commands => ["mjai-shanten"],
    :num_games => 1,
    :log_dir => "log",
}

file = File.open("spec/resources/observations-000.json", "r")
lines = file.readlines


RSpec.describe 'do_action' do
=begin
    it '局開始時の数順' do
        server = TCPServer.open(params[:host], params[:port]) 
        trans_server = TransServer.new({:target_id=>0, "test"=>"yes"})
        p "a"
        start_default_players_2(params)
        p "default_player立ち上げました"
        Timeout.timeout(10) do
            Thread.new(server.accept()) do |socket|
                p "処理を開始します"
                player = Player.new(socket, 0, nil)
                trans_server.player = player
                p "trans_server立ち上げました"
                response = trans_server.do_action(
                    MjaiAction.new(
                       {:type=>:hello}
                    ))
                expect(response.type).to eq :join
                response = trans_server.do_action(
                    MjaiAction.new(
                        {:type=>:start_game, :id=>0}
                    )
                )  # start_game
                expect(response.type).to eq :none
                response = trans_server.do_action(
                    MjaiAction.new(
                        {:type=>:start_kyoku, :kyoku=>1, :bakaze=>Mjai::Pai.new("E"), :honba=>1, :kyotaku=>0, :oya=>0, :dora_marker=>Mjai::Pai.new("2s"), :tehais=>[[Mjai::Pai.new("9p"), Mjai::Pai.new("5s"), Mjai::Pai.new("N"), Mjai::Pai.new("F"), Mjai::Pai.new("N"), Mjai::Pai.new("2m"), Mjai::Pai.new("9s"), Mjai::Pai.new("7m"), Mjai::Pai.new("4p"), Mjai::Pai.new("N"), Mjai::Pai.new("4s"), Mjai::Pai.new("E"), Mjai::Pai.new("3m")], [Mjai::Pai.new("?")]*13, [Mjai::Pai.new("?")]*13, [Mjai::Pai.new("?")]*13]}
                        )
                )  # start_kyoku
                expect(response.type).to eq :none
                response = trans_server.do_action(
                    MjaiAction.new(
                        {:type=>:tsumo, :actor=>0, :pai=>Mjai::Pai.new("E")}
                    )   
                )  # tsumo
                expect(response.type).to eq :dahai 
                response = trans_server.do_action(
                    response
                )  # dahai
                expect(response.type).to eq :none
                server.close()
            end
        end
    end
=end
=begin
    it "局がの途中で無理矢理開始する時の挙動" do
        server = TCPServer.open(params_2[:host], params_2[:port]) 
        trans_server = TransServer.new({:target_id=>0, "test"=>"yes"})
        p "a"
        start_default_players_2(params_2)
        p "default_player立ち上げました"
        Timeout.timeout(10) do
            Thread.new(server.accept()) do |socket|
                p "処理を開始します"
                player = Player.new(socket, 0, nil)
                trans_server.player = player
                p "trans_server立ち上げました"
                response = trans_server.do_action(
                    MjaiAction.new(
                       {:type=>:hello}
                    ))
                expect(response.type).to eq :join
                response = trans_server.do_action(
                    MjaiAction.new(
                        {:type=>:start_game, :id=>0}
                    )
                )  # start_game
                expect(response.type).to eq :none
                response = trans_server.do_action(
                    MjaiAction.new(
                        {:type=>:start_kyoku, :kyoku=>1, :bakaze=>Mjai::Pai.new("F"), :honba=>1, :kyotaku=>0, :oya=>0, :dora_marker=>Mjai::Pai.new("2s"), :tehais=>[[Mjai::Pai.new("9p"), Mjai::Pai.new("5s"), Mjai::Pai.new("N"), Mjai::Pai.new("F"), Mjai::Pai.new("N"), Mjai::Pai.new("2m"), Mjai::Pai.new("9s"), Mjai::Pai.new("7m"), Mjai::Pai.new("4p"), Mjai::Pai.new("N"), Mjai::Pai.new("4s"), Mjai::Pai.new("E"), Mjai::Pai.new("3m")], [Mjai::Pai.new("?")]*13, [Mjai::Pai.new("?")]*13, [Mjai::Pai.new("?")]*13]}
                        )
                )  # start_kyoku
                expect(response.type).to eq :none
                response = trans_server.do_action(
                    MjaiAction.new(
                       {:type=>:hello}
                    ))
                expect(response.type).to eq :join
                response = trans_server.do_action(
                    MjaiAction.new(
                        {:type=>:start_game, :id=>0}
                    )
                ) # start_game
                expect(response.type).to eq :none
                response = trans_server.do_action(
                    MjaiAction.new(
                        {:type=>:start_kyoku, :kyoku=>1, :bakaze=>Mjai::Pai.new("F"), :honba=>1, :kyotaku=>0, :oya=>0, :dora_marker=>Mjai::Pai.new("2s"), :tehais=>[[Mjai::Pai.new("9p"), Mjai::Pai.new("5s"), Mjai::Pai.new("N"), Mjai::Pai.new("F"), Mjai::Pai.new("N"), Mjai::Pai.new("2m"), Mjai::Pai.new("9s"), Mjai::Pai.new("7m"), Mjai::Pai.new("4p"), Mjai::Pai.new("N"), Mjai::Pai.new("4s"), Mjai::Pai.new("E"), Mjai::Pai.new("3m")], [Mjai::Pai.new("?")]*13, [Mjai::Pai.new("?")]*13, [Mjai::Pai.new("?")]*13]}
                        )
                )  # start_kyoku
                expect(response.type).to eq :none
            end
        end
    end
=end

    it "ryukyoku" do
        server = TCPServer.open(params[:host], params[:port]) 
        trans_server = TransServer.new({:target_id=>0, "test"=>"yes"})
        p "a"
        start_default_players_2(params)
        p "default_player立ち上げました"
        Timeout.timeout(10) do
            Thread.new(server.accept()) do |socket|
                p "処理を開始します"
                player = Player.new(socket, 0, nil)
                trans_server.player = player
                p "trans_server立ち上げました"
                response = trans_server.do_action(
                    MjaiAction.new(
                       {:type=>:hello}
                    ))
                expect(response.type).to eq :join
                response = trans_server.do_action(
                    MjaiAction.new(
                        {:type=>:start_game, :id=>0}
                    )
                )  # start_game
                response = trans_server.do_action(
                    MjaiAction.new(
                        {:type=>:start_kyoku, :kyoku=>1, :bakaze=>Mjai::Pai.new("E"), :honba=>1, :kyotaku=>0, :oya=>0, :dora_marker=>Mjai::Pai.new("2s"), :tehais=>[[Mjai::Pai.new("9p"), Mjai::Pai.new("5s"), Mjai::Pai.new("N"), Mjai::Pai.new("F"), Mjai::Pai.new("N"), Mjai::Pai.new("2m"), Mjai::Pai.new("9s"), Mjai::Pai.new("7m"), Mjai::Pai.new("4p"), Mjai::Pai.new("N"), Mjai::Pai.new("4s"), Mjai::Pai.new("E"), Mjai::Pai.new("3m")], [Mjai::Pai.new("?")]*13, [Mjai::Pai.new("?")]*13, [Mjai::Pai.new("?")]*13]}
                        )
                )  # start_kyoku
        
                expect(response.type).to eq :none
                observation = observation_from_json(lines, 271)
                trans_server.previous_observation = observation_from_json(lines, 270)
                public_observation_difference = trans_server.extract_difference(observation)
                mjx_event = public_observation_difference[-1]
                mjai_action  = MjxToMjai.new({0=>0,1=>1,2=>2, 3=>3}, 0).mjx_event_to_mjai_action(mjx_event, observation, [])  # ryukyokuをmjxto_mjaiを用いて取得
                response = trans_server.do_action(
                   mjai_action
                ) # ryukyoku
                response = trans_server.do_action(
                    MjaiAction.new(
                        {:type=>:end_kyoku}
                    )
                ) # end_kyoku
            end
        end
    end
=begin
    it "reach_accepted" do
        server = TCPServer.open(params_2[:host], params_2[:port]) 
        trans_server = TransServer.new({:target_id=>0, "test"=>"yes"})
        p "a"
        start_default_players_2(params_2)
        p "default_player立ち上げました"
        Timeout.timeout(10) do
            Thread.new(server.accept()) do |socket|
                p "処理を開始します"
                player = Player.new(socket, 0, nil)
                trans_server.player = player
                p "trans_server立ち上げました"
                response = trans_server.do_action(
                    MjaiAction.new(
                       {:type=>:hello}
                    ))
                expect(response.type).to eq :join
                response = trans_server.do_action(
                    MjaiAction.new(
                        {:type=>:start_game, :id=>0}
                    )
                )  # start_game
                expect(response.type).to eq :none
                response = trans_server.do_action(
                    MjaiAction.new(
                        {:type=>:start_kyoku, :kyoku=>1, :bakaze=>Mjai::Pai.new("E"), :honba=>1, :kyotaku=>0, :oya=>0, :dora_marker=>Mjai::Pai.new("2s"), :tehais=>[[Mjai::Pai.new("9p"), Mjai::Pai.new("5s"), Mjai::Pai.new("N"), Mjai::Pai.new("F"), Mjai::Pai.new("N"), Mjai::Pai.new("2m"), Mjai::Pai.new("9s"), Mjai::Pai.new("7m"), Mjai::Pai.new("4p"), Mjai::Pai.new("N"), Mjai::Pai.new("4s"), Mjai::Pai.new("E"), Mjai::Pai.new("3m")], [Mjai::Pai.new("?")]*13, [Mjai::Pai.new("?")]*13, [Mjai::Pai.new("?")]*13]}
                        )
                )  # start_kyoku
        
                expect(response.type).to eq :none
                response = trans_server.do_action(
                    MjaiAction.new(
                       {:type=>:reach_accepted,:actor=>0,:deltas=>[0,0,0,-1000],:scores=>[29100, 35000, 23000, 11900]}
                    )
                )
                response = trans_server.do_action(
                    MjaiAction.new(
                        {:type=>:end_kyoku}
                    )
                )
            end
        end
    end
=end
end