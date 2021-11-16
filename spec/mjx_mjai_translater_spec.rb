require './lib/mjx_mjai_translater/trans_server'
require './lib/mjx_mjai_translater/action'
$LOAD_PATH.unshift(__dir__) unless $LOAD_PATH.include?(__dir__)
require "test_utils"
require_relative "../mjai/lib/mjai/mjai_command"
require "timeout"


RSpec.describe MjxMjaiTranslater do
  it 'has a version number' do
    expect(MjxMjaiTranslater::VERSION).not_to be nil
  end
  it 'does something useful' do
    expect(true).to eq(true)
  end
end


RSpec.describe TransServer do  # take_actionで実装されている階層の関数をtest
  file = File.open("spec/resources/observations-000.json", "r")
  lines = file.readlines
  trans_server = TransServer.new({:target_id=>1, "test"=>"yes"})
  it 'test_observe' do
    previous_events = observation_from_json(lines, 0).public_observation.events
    observation = observation_from_json(lines, 1)
    trans_server._mjx_events = previous_events
    trans_server.observe(observation)
    new_mjai_actions = trans_server.new_mjai_actions
    expect(new_mjai_actions).to eq [MjaiAction.new({:type=>:dahai, :actor=>0, :pai=>Mjai::Pai.new("E"), :tsumogiri=>false}), MjaiAction.new({:type=>:tsumo, :actor=>1, :pai=>Mjai::Pai.new("9s")}), MjaiAction.new({:type=>:dahai, :actor=>1, :pai=>Mjai::Pai.new("W"), :tsumogiri=>false}),
    MjaiAction.new({:type=>:tsumo, :actor=>2, :pai=>Mjai::Pai.new("?")}), MjaiAction.new({:type=>:dahai, :actor=>2, :pai=>Mjai::Pai.new("S"), :tsumogiri=>true}),
    MjaiAction.new({:type=>:tsumo, :actor=>3, :pai=>Mjai::Pai.new("?")}), MjaiAction.new({:type=>:dahai, :actor=>3, :pai=>Mjai::Pai.new("S"), :tsumogiri=>false}), MjaiAction.new({:type=>:tsumo, :actor=>0, :pai=>Mjai::Pai.new("?")})]
  end
  it 'test_update_next_action' do
    observation = observation_from_json(lines,9)
    legal_actions = observation.legal_actions
    mjai_actions = [MjaiAction.new({:type=>:dahai, :actor=>0, :pai=>Mjai::Pai.new("E"), :tsumogiri=>false}), MjaiAction.new({:type=>:tsumo, :actor=>1, :pai=>Mjai::Pai.new("9s")}), MjaiAction.new({:type=>:dahai, :actor=>1, :pai=>Mjai::Pai.new("W"), :tsumogiri=>false}),
    MjaiAction.new({:type=>:tsumo, :actor=>2, :pai=>Mjai::Pai.new("?")}), MjaiAction.new({:type=>:dahai, :actor=>2, :pai=>Mjai::Pai.new("S"), :tsumogiri=>true}),
    MjaiAction.new({:type=>:tsumo, :actor=>3, :pai=>Mjai::Pai.new("?")}), MjaiAction.new({:type=>:dahai, :actor=>3, :pai=>Mjai::Pai.new("S"), :tsumogiri=>false}), MjaiAction.new({:type=>:tsumo, :actor=>0, :pai=>Mjai::Pai.new("?")}),MjaiAction.new({:type=>:chi, :actor=>0, :target=>3, :pai=>Mjai::Pai.new("3m"), :consumed=>[Mjai::Pai.new("2m"), Mjai::Pai.new("4m")]})]
    mjx_new_actions = trans_server.update_next_actions(mjai_actions, observation)
    expect(mjx_new_actions[-1]).to eq legal_actions[0]
  end
end

params = {
        :host => "127.0.0.1",
        :port => 11659,
        :room => "default",
        :game_type => "game_type:one_kyoku".intern,
        :player_commands => ["mjai-shanten"],
        :num_games => 1,
        :log_dir => "log",
    }

RSpec.describe "TransServer Start kyoku" do  # take_actionで実装されている階層の関数をtest
  file = File.open("spec/resources/observations-000.json", "r")
  lines = file.readlines
  trans_server = TransServer.new({:target_id=>0, "test"=>"yes"})
  expected_mjai_action_start_1 = [MjaiAction.new({:type=>:dahai, :actor=>0, :pai=>Mjai::Pai.new("E"), :tsumogiri=>false}), MjaiAction.new({:type=>:tsumo, :actor=>1, :pai=>Mjai::Pai.new("?")}), MjaiAction.new({:type=>:dahai, :actor=>1, :pai=>Mjai::Pai.new("W"), :tsumogiri=>false}),
  MjaiAction.new({:type=>:tsumo, :actor=>2, :pai=>Mjai::Pai.new("?")}), MjaiAction.new({:type=>:dahai, :actor=>2, :pai=>Mjai::Pai.new("S"), :tsumogiri=>true}),
  MjaiAction.new({:type=>:tsumo, :actor=>3, :pai=>Mjai::Pai.new("?")}), MjaiAction.new({:type=>:dahai, :actor=>3, :pai=>Mjai::Pai.new("S"), :tsumogiri=>false}), MjaiAction.new({:type=>:tsumo, :actor=>0, :pai=>Mjai::Pai.new("9s")})]
  mjai_actions_start_1 = [MjaiAction.new({:type=>:none}), MjaiAction.new({:type=>:none}), MjaiAction.new({:type=>:none}),
  MjaiAction.new({:type=>:none}), MjaiAction.new({:type=>:none}),
  MjaiAction.new({:type=>:none}), MjaiAction.new({:type=>:none}), MjaiAction.new({:type=>:dahai, :actor=>0, :pai=>Mjai::Pai.new("W"), :tsumogiri=>false})]
  expected_mjai_action_start_2 = [MjaiAction.new({:type=>:dahai, :actor=>0, :pai=>Mjai::Pai.new("W"), :tsumogiri=>false}), MjaiAction.new({:type=>:tsumo, :actor=>1, :pai=>Mjai::Pai.new("?")}), MjaiAction.new({:type=>:dahai, :actor=>1, :pai=>Mjai::Pai.new("P"), :tsumogiri=>false}),
  MjaiAction.new({:type=>:tsumo, :actor=>2, :pai=>Mjai::Pai.new("?")}), MjaiAction.new({:type=>:dahai, :actor=>2, :pai=>Mjai::Pai.new("W"), :tsumogiri=>true}),
  MjaiAction.new({:type=>:tsumo, :actor=>3, :pai=>Mjai::Pai.new("?")}), MjaiAction.new({:type=>:dahai, :actor=>3, :pai=>Mjai::Pai.new("N"), :tsumogiri=>false}), MjaiAction.new({:type=>:tsumo, :actor=>0, :pai=>Mjai::Pai.new("2p")})]
  mjai_actions_start_2 = [MjaiAction.new({:type=>:none}), MjaiAction.new({:type=>:none}), MjaiAction.new({:type=>:none}),
  MjaiAction.new({:type=>:none}), MjaiAction.new({:type=>:none}),
  MjaiAction.new({:type=>:none}), MjaiAction.new({:type=>:none}), MjaiAction.new({:type=>:dahai, :actor=>0, :pai=>Mjai::Pai.new("P"), :tsumogiri=>false})]
  it 'test_take_action_start with do_action mocked' do  # 局の最初  連続で2順
    trans_server = TransServer.new({:target_id=>0, "test"=>"yes"})
    previous_events = observation_from_json(lines, 0).public_observation.events
    observation_1 = observation_from_json(lines, 1)
    trans_server._mjx_events = previous_events
    trans_server.observe(observation_1)  # observation→mjai action
    expected_mjai_actions = expected_mjai_action_start_1
    expect(trans_server.new_mjai_actions).to eq expected_mjai_actions
    mjai_actions = mjai_actions_start_1  # do_actionを通してmjaiのagentから送られてきたmjaiのactionの想定
    mjx_actions = trans_server.update_next_actions(mjai_actions, observation_1)  # mjai_action→mjx_action
    expected_mjx_action = observation_1.legal_actions[-2]
    expect(mjx_actions[-1]).to eq expected_mjx_action

    observation_2 = observation_from_json(lines, 2)
    trans_server.observe(observation_2)
    expected_mjai_actions = expected_mjai_action_start_2
    expect(trans_server.new_mjai_actions).to eq expected_mjai_actions
    mjai_actions = mjai_actions_start_2  # do_actionを通してmjaiのagentから送られてきたmjaiのactionの想定
    mjx_actions = trans_server.update_next_actions(mjai_actions, observation_2)  # mjai_action→mjx_action
    expected_mjx_action = observation_2.legal_actions[-1]
    expect(mjx_actions[-1]).to eq expected_mjx_action
  end

  it 'test_take_action_start' do
    #server = TCPServer.open(params[:host], params[:port]) 
    #trans_server = TransServer.new({:target_id=>0, "test"=>"yes"})
    #p "a"
    #start_default_players_2(params)
    #p "default_player立ち上げました"
    #Timeout.timeout(20) do
        #socket = server.accept()
        #p "処理を開始します"
        #player = Player.new(socket, 0, nil)
        #p player
        #trans_server.player = player
        #observation_0 = observation_from_json(lines, 0)
        #mjx_action = trans_server.take_action(observation_0, nil)
        #expect(mjx_action).not_to eq nil

        #observation_1 = observation_from_json(lines, 1)
        #mjx_action = trans_server.take_action(observation_1, nil)
        #expect(mjx_action).not_to eq nil

        #observation_2 = observation_from_json(lines, 2)
        #mjx_action = trans_server.take_action(observation_2, nil)
        #expect(mjx_action).not_to eq nil
        #server.close()
    #end
  end
end


RSpec.describe "TransServer Middle kyoku" do  # take_actionで実装されている階層の関数をtest
  file = File.open("spec/resources/observations-000.json", "r")
  lines = file.readlines
  trans_server = TransServer.new({:target_id=>0, "test"=>"yes"})
  expected_mjai_actions_middle_1 = [MjaiAction.new({:type=>:dahai, :actor=>0, :pai=>Mjai::Pai.new("9p"), :tsumogiri=>false}), MjaiAction.new({:type=>:tsumo, :actor=>1, :pai=>Mjai::Pai.new("?")}), MjaiAction.new({:type=>:dahai, :actor=>1, :pai=>Mjai::Pai.new("9p"), :tsumogiri=>false}),
    MjaiAction.new({:type=>:tsumo, :actor=>2, :pai=>Mjai::Pai.new("?")}), MjaiAction.new({:type=>:dahai, :actor=>2, :pai=>Mjai::Pai.new("9m"), :tsumogiri=>false}),
    MjaiAction.new({:type=>:tsumo, :actor=>3, :pai=>Mjai::Pai.new("?")}), MjaiAction.new({:type=>:dahai, :actor=>3, :pai=>Mjai::Pai.new("3m"), :tsumogiri=>false})]
  mjai_actions_middle_1 = [MjaiAction.new({:type=>:none}), MjaiAction.new({:type=>:none}), MjaiAction.new({:type=>:none}), MjaiAction.new({:type=>:none}), MjaiAction.new({:type=>:none}),
    MjaiAction.new({:type=>:none}), MjaiAction.new({:type=>:none}), MjaiAction.new({:type=>:none})]
  expected_mjai_actions_middle_2 = [MjaiAction.new({:type=>:tsumo, :actor=>0, :pai=>Mjai::Pai.new("6s")})]
  mjai_actions_middle_2 = [MjaiAction.new({:type=>:dahai, :actor=>0, :pai=>Mjai::Pai.new("8p"), :tsumogiri=>false})]
  it 'test_take_action_middle with do_action mocked' do  # 局の最初  連続で2順
    previous_events = observation_from_json(lines, 8).public_observation.events
    observation_1 = observation_from_json(lines, 9)
    trans_server._mjx_events = previous_events
    trans_server.observe(observation_1)  # observation→mjai action
    expected_mjai_actions = expected_mjai_actions_middle_1
    expect(trans_server.new_mjai_actions).to eq expected_mjai_actions
    mjai_actions = mjai_actions_middle_1  # do_actionを通してmjaiのagentから送られてきたmjaiのactionの想定
    mjx_actions = trans_server.update_next_actions(mjai_actions, observation_1)  # mjai_action→mjx_action
    expected_mjx_action = observation_1.legal_actions[-1]
    expect(mjx_actions[-1]).to eq expected_mjx_action

    observation_2 = observation_from_json(lines, 10)
    trans_server.observe(observation_2)
    expected_mjai_actions = expected_mjai_actions_middle_2
    expect(trans_server.new_mjai_actions).to eq expected_mjai_actions
    mjai_actions = mjai_actions_middle_2  # do_actionを通してmjaiのagentから送られてきたmjaiのactionの想定
    mjx_actions = trans_server.update_next_actions(mjai_actions, observation_2)  # mjai_action→mjx_action
    expected_mjx_action = observation_2.legal_actions[3]
    expect(mjx_actions[-1]).to eq expected_mjx_action
  end
end


RSpec.describe "TransServer end kyoku" do  # take_actionで実装されている階層の関数をtest
  file = File.open("spec/resources/observations-000.json", "r")
  lines = file.readlines
  trans_server = TransServer.new({:target_id=>0, "test"=>"yes"})
  expected_mjai_actions_end_kyoku_1 = [MjaiAction.new({:type=>:dahai, :actor=>0, :pai=>Mjai::Pai.new("1s"), :tsumogiri=>true}), MjaiAction.new({:type=>:ryukyoku, :reason=>:fonpai, :tehais=>[[Mjai::Pai.new("3m"), Mjai::Pai.new("4m"), Mjai::Pai.new("5m"), Mjai::Pai.new("2p"), Mjai::Pai.new("2p"), Mjai::Pai.new("2p"), Mjai::Pai.new("6s"), Mjai::Pai.new("7s"), Mjai::Pai.new("9s"), Mjai::Pai.new("9s")], [Mjai::Pai.new("5mr"), Mjai::Pai.new("5m"), Mjai::Pai.new("6s"), Mjai::Pai.new("8s")], [Mjai::Pai.new("?")]*13, [Mjai::Pai.new("5p"), Mjai::Pai.new("6p"), Mjai::Pai.new("7p"), Mjai::Pai.new("7p"), Mjai::Pai.new("8p"), Mjai::Pai.new("3s"), Mjai::Pai.new("3s"), Mjai::Pai.new("5sr"), Mjai::Pai.new("5s"), Mjai::Pai.new("5s")]], :tenpais=>[true, true, false, true], :deltas=>[1000, 1000, -3000, 1000], :scores=>[26000, 26000, 22000, 26000]}) ,MjaiAction.new({:type=>:end_kyoku})]
  mjai_actions_end_kyoku_1 = [MjaiAction.new({:type=>:none}), MjaiAction.new({:type=>:none}), MjaiAction.new({:type=>:none})]
  expected_mjai_actions_end_kyoku_2 = [MjaiAction.new({:type=>:start_kyoku, :kyoku=>1, :bakaze=>Mjai::Pai.new("E"), :honba=>1, :kyotaku=>0, :oya=>0, :dora_marker=>Mjai::Pai.new("2s"), :tehais=>[[Mjai::Pai.new("9p"), Mjai::Pai.new("5s"), Mjai::Pai.new("N"), Mjai::Pai.new("F"), Mjai::Pai.new("N"), Mjai::Pai.new("2m"), Mjai::Pai.new("9s"), Mjai::Pai.new("7m"), Mjai::Pai.new("4p"), Mjai::Pai.new("N"), Mjai::Pai.new("4s"), Mjai::Pai.new("E"), Mjai::Pai.new("3m")], [Mjai::Pai.new("?")]*13, [Mjai::Pai.new("?")]*13, [Mjai::Pai.new("?")]*13]}) ,MjaiAction.new({:type=>:tsumo, :actor=>0, :pai=>Mjai::Pai.new("5m")})]
  mjai_actions_end_kyoku_2 = [MjaiAction.new({:type=>:none}), MjaiAction.new({:type=>:dahai, :actor=>0, :pai=>Mjai::Pai.new("E"), :tsumogiri=>false})]
  it 'test_take_action_end_kyoku with do_action mocked' do  # 局の最初  連続で2順
    previous_events = observation_from_json(lines, 28).public_observation.events
    observation_1 = observation_from_json(lines, 29)
    trans_server._mjx_events = previous_events
    trans_server.observe(observation_1)  # observation→mjai action
    expected_mjai_actions = expected_mjai_actions_end_kyoku_1
    expect(trans_server.new_mjai_actions).to eq expected_mjai_actions
    mjai_actions = mjai_actions_end_kyoku_1  # do_actionを通してmjaiのagentから送られてきたmjaiのactionの想定
    mjx_actions = trans_server.update_next_actions(mjai_actions, observation_1)  # mjai_action→mjx_action
    expected_mjx_action = observation_1.legal_actions[-1]
    expect(mjx_actions[-1]).to eq expected_mjx_action

    observation_2 = observation_from_json(lines, 30)
    trans_server.observe(observation_2)
    expected_mjai_actions = expected_mjai_actions_end_kyoku_2
    expect(trans_server.new_mjai_actions).to eq expected_mjai_actions
    mjai_actions = mjai_actions_end_kyoku_2  # do_actionを通してmjaiのagentから送られてきたmjaiのactionの想定
    mjx_actions = trans_server.update_next_actions(mjai_actions, observation_2)  # mjai_action→mjx_action
    expected_mjx_action = observation_2.legal_actions[-3]
    expect(mjx_actions[-1]).to eq expected_mjx_action
  end
end

RSpec.describe "TransServer end game" do  # take_actionで実装されている階層の関数をtest
  file = File.open("spec/resources/observations-000.json", "r")
  lines = file.readlines
  trans_server = TransServer.new({:target_id=>0, "test"=>"yes"})
  player = Player.new(0, nil, nil)
  trans_server.player = player
  expected_mjai_actions_end_game_1 = [MjaiAction.new({:type=>:dahai, :actor=>0, :pai=>Mjai::Pai.new("7m"), :tsumogiri=>false}), MjaiAction.new({:type=>:tsumo, :actor=>1, :pai=>Mjai::Pai.new("?")}), MjaiAction.new({:type=>:dahai, :actor=>1, :pai=>Mjai::Pai.new("4s"), :tsumogiri=>false}), MjaiAction.new({:type=>:tsumo, :actor=>2, :pai=>Mjai::Pai.new("?")}) ,MjaiAction.new({:type=>:hora, :actor=>2, :target=>2, :pai=>Mjai::Pai.new("7s"), :uradora_markers=>[], :hora_tehais=>[Mjai::Pai.new("7s"), Mjai::Pai.new("7s"), Mjai::Pai.new("C"), Mjai::Pai.new("C"), Mjai::Pai.new("C")], :yakus=>[[:sangenpai, 1]], :fu=>70, :fan=>1, :hora_points=>2400, :deltas=>[-900, -900, 3300, -1500], :scores=>[36700, 23000, 7800, 32500]}), MjaiAction.new({:type => :end_kyoku})]
  mjai_actions_end_game_1 = [MjaiAction.new({:type=>:none}), MjaiAction.new({:type=>:none}), MjaiAction.new({:type=>:none})]
  expected_mjai_actions_end_game_2 = [MjaiAction.new({:type => :start_game}), MjaiAction.new({:type=>:start_kyoku, :kyoku=>1, :bakaze=>Mjai::Pai.new("E"), :honba=>0, :kyotaku=>0, :oya=>0, :dora_marker=>Mjai::Pai.new("1s"), :tehais=>[[Mjai::Pai.new("4m"), Mjai::Pai.new("P"), Mjai::Pai.new("9p"), Mjai::Pai.new("9s"), Mjai::Pai.new("2s"), Mjai::Pai.new("2p"), Mjai::Pai.new("W"), Mjai::Pai.new("7s"), Mjai::Pai.new("1p"), Mjai::Pai.new("1m"), Mjai::Pai.new("4p"), Mjai::Pai.new("4p"), Mjai::Pai.new("E")], [Mjai::Pai.new("?")]*13, [Mjai::Pai.new("?")]*13, [Mjai::Pai.new("?")]*13]}), MjaiAction.new({:type=>:tsumo, :actor=>0, :pai=>Mjai::Pai.new("2m")})]
  mjai_actions_end_game_2 = [MjaiAction.new({:type=>:none}), MjaiAction.new({:type=>:none}), MjaiAction.new({:type=>:dahai, :actor=>0, :pai=>Mjai::Pai.new("E"), :tsumogiri=>false})]
  it 'test_take_action_end_game with do_action mocked' do
    previous_events = observation_from_json(lines, 285).public_observation.events
    observation_1 = observation_from_json(lines, 286)
    trans_server._mjx_events = previous_events
    trans_server.observe(observation_1)  # observation→mjai action
    expected_mjai_actions = expected_mjai_actions_end_game_1
    expect(trans_server.new_mjai_actions).to eq expected_mjai_actions
    mjai_actions = mjai_actions_end_game_1  # do_actionを通してmjaiのagentから送られてきたmjaiのactionの想定
    mjx_actions = trans_server.update_next_actions(mjai_actions, observation_1)  # mjai_action→mjx_action
    expected_mjx_action = observation_1.legal_actions[-1]
    expect(mjx_actions[-1]).to eq expected_mjx_action

    observation_2 = observation_from_json(lines, 0)
    trans_server.observe(observation_2)
    expected_mjai_actions = expected_mjai_actions_end_game_2
    expect(trans_server.new_mjai_actions).to eq expected_mjai_actions
    mjai_actions = mjai_actions_end_game_2  # do_actionを通してmjaiのagentから送られてきたmjaiのactionの想定
    mjx_actions = trans_server.update_next_actions(mjai_actions, observation_2)  # mjai_action→mjx_action
    expected_mjx_action = observation_2.legal_actions[-3]
    expect(mjx_actions[-1]).to eq expected_mjx_action
  end
end

RSpec.describe "id initialization" do
  file = File.open("spec/resources/observations-000.json", "r")
  lines = file.readlines
  file_1 = File.open("spec/resources/observations-001.json", "r")
  lines_1 = file_1.readlines
  file_2 = File.open("spec/resources/observations-002.json", "r")
  lines_2 = file_2.readlines
  file_3 = File.open("spec/resources/observations-003.json", "r")
  lines_3 = file_3.readlines
  it "check id position correspondance 起家" do
    observation_0 = observation_from_json(lines, 0)
    trans_server = TransServer.new({:target_id=>1, "test"=>"yes"})
    player = Player.new(1, nil, nil)
    trans_server.player = player
    trans_server.observe(observation_0)
    expect(trans_server.target_id).to eq 0
  end
  it "check id position correspondance 南家" do
    observation_1 = observation_from_json(lines_1, 0)
    trans_server = TransServer.new({:target_id=>0, "test"=>"yes"})
    player = Player.new(0, nil, nil)
    trans_server.player = player
    trans_server.observe(observation_1)
    expect(trans_server.target_id).to eq 1
  end
  it "check id position correspondance 西家" do
    observation_2 = observation_from_json(lines_2, 0)
    trans_server = TransServer.new({:target_id=>0, "test"=>"yes"})
    player = Player.new(0, nil, nil)
    trans_server.player = player
    trans_server.observe(observation_2)
    expect(trans_server.target_id).to eq 2
  end
  it "check id position correspondance 北家" do
    observation_3 = observation_from_json(lines_3, 0)
    trans_server = TransServer.new({:target_id=>0, "test"=>"yes"})
    player = Player.new(0, nil, nil)
    trans_server.player = player
    trans_server.observe(observation_3)
    expect(trans_server.target_id).to eq 3
  end
end




