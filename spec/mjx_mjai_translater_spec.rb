require './lib/mjx_mjai_translater/trans_server'
require './lib/mjx_mjai_translater/action'
$LOAD_PATH.unshift(__dir__) unless $LOAD_PATH.include?(__dir__)
require "test_utils"


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
    trans_server.set_mjx_events(previous_events)
    trans_server.observe(observation)
    new_mjai_actions = trans_server.get_mjai_actions()
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


RSpec.describe "TransServer.take_action()" do  # take_actionで実装されている階層の関数をtest
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
  it 'test_take_action_start' do  # 局の最初  連続で2順
    previous_events = observation_from_json(lines, 0).public_observation.events
    observation_1 = observation_from_json(lines, 1)
    trans_server.set_mjx_events(previous_events)
    trans_server.observe(observation_1)  # observation→mjai action
    expected_mjai_actions = expected_mjai_action_start_1
    expect(trans_server.get_mjai_actions()).to eq expected_mjai_actions
    mjai_actions = mjai_actions_start_1  # do_actionを通してmjaiのagentから送られてきたmjaiのactionの想定
    mjx_actions = trans_server.update_next_actions(mjai_actions, observation_1)  # mjai_action→mjx_action
    expected_mjx_action = observation_1.legal_actions[-2]
    expect(mjx_actions[-1]).to eq expected_mjx_action

    observation_2 = observation_from_json(lines, 2)
    trans_server.observe(observation_2)
    expected_mjai_actions = expected_mjai_action_start_2
    expect(trans_server.get_mjai_actions()).to eq expected_mjai_actions
    mjai_actions = mjai_actions_start_2  # do_actionを通してmjaiのagentから送られてきたmjaiのactionの想定
    mjx_actions = trans_server.update_next_actions(mjai_actions, observation_2)  # mjai_action→mjx_action
    expected_mjx_action = observation_2.legal_actions[-1]
    expect(mjx_actions[-1]).to eq expected_mjx_action
  end
end
