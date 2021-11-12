require "./lib/mjx_mjai_translater/mjx_to_mjai"
require 'json'
require 'grpc'
require 'google/protobuf'
require './lib/mjx_mjai_translater/mjai_action_to_mjx_action'
require './lib/mjx_mjai_translater/open_converter'
require './lib/mjx_mjai_translater/action'
$LOAD_PATH.unshift(__dir__) unless $LOAD_PATH.include?(__dir__)
require "test_utils"

RSpec.describe  MjxToMjai do  # tile変換のテスト
  it "protoの赤tileがmjaiのtileに変換できること" do
    expect(MjxToMjai.new({}, 0).proto_tile_to_mjai_tile(16)).to eq Mjai::Pai.new("5mr")
  end
  it "protoの赤以外の数牌をmjaiのtileに変換できること" do
    expect(MjxToMjai.new({}, 0).proto_tile_to_mjai_tile(17)).to eq Mjai::Pai.new("5m")
  end
  it "protoの字牌をmjaiのtileに変換できるか" do
    expect(MjxToMjai.new({}, 0).proto_tile_to_mjai_tile(131)).to eq Mjai::Pai.new("F")
  end
  it "protoの字牌をmjaiのtileに変換できるか" do
    expect(MjxToMjai.new({}, 0).proto_tile_to_mjai_tile(121)).to eq Mjai::Pai.new("N")
  end
end

RSpec.describe  MjxToMjai do
  file = File.open("spec/resources/observations-000.json", "r")
  lines = file.readlines
  file_1 = File.open("spec/resources/observations-001.json", "r")
  lines_1 = file_1.readlines
  file_2 = File.open("spec/resources/observations-002.json", "r")
  lines_2 = file_2.readlines
  file_3 = File.open("spec/resources/observations-003.json", "r")
  lines_3 = file_3.readlines
  mjx_to_mjai = MjxToMjai.new({0=>0,1=>1,
  2=>2, 3=>3}, 0)
  it "手出し" do
    observation = observation_from_json(lines,1)
    legal_actions = observation.legal_actions
    mjx_action = legal_actions[0]
    expected_mjai_action = MjaiAction.new({:type=>:dahai, :actor=>0, :pai=>Mjai::Pai.new("1m"), :tsumogiri=>false})  # 今は起家から順番に恣意的に0,1,2,3とidを決めている。trans_server のインスタンス変数がその対応を全て管理しているので別の問題
    expect(mjx_to_mjai.mjx_act_to_mjai_act(mjx_action, nil)).to eq expected_mjai_action
  end
  it "ツモぎり" do
    observation = observation_from_json(lines,25)
    legal_actions = observation.legal_actions
    mjx_action = legal_actions[-1]
    expected_mjai_action = MjaiAction.new({:type=>:dahai, :actor=>0, :pai=>Mjai::Pai.new("W"), :tsumogiri=>true})
    expect(mjx_to_mjai.mjx_act_to_mjai_act(mjx_action, nil)).to eq expected_mjai_action
  end
  it "チー" do
    observation = observation_from_json(lines,9)
    legal_actions = observation.legal_actions
    mjx_action = legal_actions[0]
    expected_mjai_action = MjaiAction.new({:type=>:chi, :actor=>0, :target=>3, :pai=>Mjai::Pai.new("3m"), :consumed=>[Mjai::Pai.new("2m"), Mjai::Pai.new("4m")]})
    expect(mjx_to_mjai.mjx_act_to_mjai_act(mjx_action, nil)).to eq expected_mjai_action
  end
  it "ポン" do
    observation = observation_from_json(lines,5)
    legal_actions = observation.legal_actions
    mjx_action = legal_actions[0]
    expected_mjai_action = MjaiAction.new({:type=>:pon, :actor=>0, :target=>1, :pai=>Mjai::Pai.new("4p"), :consumed=>[Mjai::Pai.new("4p"), Mjai::Pai.new("4p")]})
    expect(mjx_to_mjai.mjx_act_to_mjai_act(mjx_action, nil)).to eq expected_mjai_action
  end
  it "カカン" do
    observation = observation_from_json(lines,33)
    legal_actions = observation.legal_actions
    mjx_action = legal_actions[0]
    expected_mjai_action = MjaiAction.new({:type=>:kakan,:actor=>0,:pai=>Mjai::Pai.new("N"),:consumed=>[Mjai::Pai.new("N"), Mjai::Pai.new("N"), Mjai::Pai.new("N")]})
    expect(mjx_to_mjai.mjx_act_to_mjai_act(mjx_action, nil)).to eq expected_mjai_action
  end
  it "ダイミンカン" do 
    observation = observation_from_json(lines,22)
    legal_actions = observation.legal_actions
    mjx_action = legal_actions[1]
    expected_mjai_action = MjaiAction.new({:type=>:daiminkan, :actor=>0, :target=>2, :pai=>Mjai::Pai.new("2p"), :consumed=>[Mjai::Pai.new("2p"), Mjai::Pai.new("2p"), Mjai::Pai.new("2p")]})
    expect(mjx_to_mjai.mjx_act_to_mjai_act(mjx_action, nil)).to eq expected_mjai_action
  end
  it "アンカン" do
    observation = observation_from_json(lines_1,29)
    legal_actions = observation.legal_actions
    mjx_action = legal_actions[0]
    expected_mjai_action = MjaiAction.new({:type=>:ankan,:actor=>1,:consumed=>[Mjai::Pai.new("P"), Mjai::Pai.new("P"),Mjai::Pai.new("P"), Mjai::Pai.new("P")]})
    expect(mjx_to_mjai.mjx_act_to_mjai_act(mjx_action, nil)).to eq expected_mjai_action
  end
  it "リーチ" do
    observation = observation_from_json(lines,129)
    legal_actions = observation.legal_actions
    mjx_action = legal_actions[0]
    expected_mjai_action = MjaiAction.new({:type=>:reach,:actor=>0})
    expect(mjx_to_mjai.mjx_act_to_mjai_act(mjx_action, nil)).to eq expected_mjai_action
  end
  it "ツモ" do
    observation = observation_from_json(lines,153)
    legal_actions = observation.legal_actions
    public_observatoin = observation.public_observation.events
    mjx_action = legal_actions[0]
    expected_mjai_action = MjaiAction.new({:type=>:hora,:actor=>0,:target=>0,:pai=>Mjai::Pai.new("8s")})
    expect(mjx_to_mjai.mjx_act_to_mjai_act(mjx_action, public_observatoin)).to eq expected_mjai_action
  end
  it "ロン" do
    observation = observation_from_json(lines,53)
    legal_actions = observation.legal_actions
    public_observatoin = observation.public_observation.events
    mjx_action = legal_actions[0]
    expected_mjai_action = MjaiAction.new({:type=>:hora,:actor=>0,:target=>3,:pai=>Mjai::Pai.new("7m")})
    expect(mjx_to_mjai.mjx_act_to_mjai_act(mjx_action, public_observatoin)).to eq expected_mjai_action
  end
  it "no" do
    observation = observation_from_json(lines,5)
    legal_actions = observation.legal_actions
    mjx_action = legal_actions[-1]
    expected_mjai_action =  MjaiAction.new({:type=>:none})
    expect(mjx_to_mjai.mjx_act_to_mjai_act(mjx_action, nil)).to eq expected_mjai_action
  end
end