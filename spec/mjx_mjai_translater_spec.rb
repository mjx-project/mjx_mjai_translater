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

  it 'test_take_action_start' do  # 局の最初
    previous_events = observation_from_json(lines, 0).public_observation.events
    observation = observation_from_json(lines, 1)
    trans_server.set_mjx_events(previous_events)
    trans_server.observe(observation)  # observation→mjai action
    mjai_actions = [MjaiAction.new({:type=>:none}), MjaiAction.new({:type=>:none}), MjaiAction.new({:type=>:none}),
    MjaiAction.new({:type=>:none}), MjaiAction.new({:type=>:none}),
    MjaiAction.new({:type=>:none}), MjaiAction.new({:type=>:none}), MjaiAction.new({:type=>:dahai, :actor=>0, :pai=>Mjai::Pai.new("W"), :tsumogiri=>false})]  # do_actionを通してmjaiのagentから送られてきたmjaiのactionの想定
    mjx_actions = trans_server.update_next_actions(mjai_actions, observation)  # mjai_action→mjx_action
    expected_mjx_action = observation.legal_actions[-2]
    expect(mjx_actions[-1]).to eq expected_mjx_action
  end
  it 'test_take_action_middle' do  # 局の途中
    observation = nil
    trans_server.observe(observation)
    mjai_actions = nil
    mjx_actions = trans_server.update_next_actions(mjai_actions, observation)
    expected_mjx_action = nil
    expect(mjx_actions[-1]).to eq expected_mjx_action
  end
  it 'test_take_action_end' do  # 局のおわり
    observation = nil
    trans_server.observe(observation)
    mjai_actions = nil
    mjx_actions = trans_server.update_next_actions(mjai_actions, observation)
    expected_mjx_action = nil
    expect(mjx_actions[-1]).to eq expected_mjx_action
  end

end
