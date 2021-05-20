require "./lib/mjx_mjai_translater/mjx_to_mjai"
require 'json'
require 'grpc'
require './lib/mjxproto/mjx_pb'
require './lib/mjxproto/mjx_services_pb'
require 'google/protobuf'
require './lib/mjx_mjai_translater/mjai_action_to_mjx_action'
require './lib/mjx_mjai_translater/open_converter'
$LOAD_PATH.unshift(__dir__) unless $LOAD_PATH.include?(__dir__)
require "test_utils"

RSpec.describe  MjxToMjai do  # tile変換のテスト
  it "protoの赤tileがmjaiのtileに変換できること" do
    expect(MjxToMjai.new({}).proto_tile_to_mjai_tile(16)).to eq "5mr"
  end
  it "protoの赤以外の数牌をmjaiのtileに変換できること" do
    expect(MjxToMjai.new({}).proto_tile_to_mjai_tile(17)).to eq "5m"
  end
  it "protoの字牌をmjaiのtileに変換できるか" do
    expect(MjxToMjai.new({}).proto_tile_to_mjai_tile(131)).to eq "F"
  end
  it "protoの字牌をmjaiのtileに変換できるか" do
    expect(MjxToMjai.new({}).proto_tile_to_mjai_tile(121)).to eq "N"
  end
end

RSpec.describe  MjxToMjai do
  file = File.open("spec/resources/observations-000.json", "r")
  lines = file.readlines
  file_1 = File.open("spec/resources/observations-001.json", "r")
  lines_1 = file_1.readlines
  file_3 = File.open("spec/resources/observations-003.json", "r")
  lines_3 = file_3.readlines
  mjx_to_mjai = MjxToMjai.new({:ABSOLUTE_POS_INIT_EAST=>0,:ABSOLUTE_POS_INIT_SOUTH=>1,
  :ABSOLUTE_POS_INIT_WEST=>2, :ABSOLUTE_POS_INIT_NORTH=>3})
  it "打牌" do
    observation = observation_from_json(lines,1)
    possible_actions = observation.possible_actions
    mjx_action = possible_actions[0]
    expected_mjai_action = {"type"=>"dahai", "actor"=>0, "pai"=>"8m", "tsumoigri"=>false}
  end
  it "チー" do
    observation = observation_from_json(lines,7)
    possible_actions = observation.possible_actions
    mjx_action = possible_actions[0]
    expected_mjai_action = {"type"=>"chi", "actor"=>0, "target"=>3, "pai"=>"3p", "consumed"=>["4p", "5p"]}
  end
  it "ポン" do
    observation = observation_from_json(lines,9)
    possible_actions = observation.possible_actions
    mjx_action = possible_actions[0]
    expected_mjai_action = {"type"=>"pon", "actor"=>0, "target"=>2, "pai"=>"2p", "consumed"=>["2p", "2p"]}
  end
  it "カカン" do
    observation = observation_from_json(lines_1,119)
    possible_actions = observation.possible_actions
    mjx_action = possible_actions[0]
    expected_mjai_action = {"type"=>"kakan","actor"=>1,"pai"=>"5s","consumed"=>["5s", "5s", "5sr"]}
  end
  it "ダイミンカン" do 
    observation = observation_from_json(lines,173)
    possible_actions = observation.possible_actions
    mjx_action = possible_actions[1]
    expected_mjai_action = {"type"=>"daiminkan", "actor"=>0, "target"=>2, "pai"=>"3p", "consumed"=>["3p", "3p", "3p"]}
  end
  it "アンカン" do
    observation = observation_from_json(lines_3,42)
    possible_actions = observation.possible_actions
    mjx_action = possible_actions[0]
    expected_mjai_action = {"type"=>"ankan","actor"=>3,"consumed"=>["P", "P", "P", "P"]}
  end
  it "リーチ" do
    observation = observation_from_json(lines_3,30)
    possible_actions = observation.possible_actions
    mjx_action = possible_actions[0]
    expected_mjai_action = {"type"=>"reach","actor"=>3}
    expect(mjx_to_mjai.mjx_act_to_mjai_act(mjx_action)).to eq expected_mjai_action
  end
  it "ツモ" do
    observation = observation_from_json(lines,96)
    possible_actions = observation.possible_actions
    mjx_action = possible_actions[0]
    expected_mjai_action = {"type"=>"hora","actor"=>2,"target"=>2,"pai"=>"2m"}
  end
  it "ロン" do
    observation = observation_from_json(lines,156)
    possible_actions = observation.possible_actions
    mjx_action = possible_actions[0]
    expected_mjai_action = {"type"=>"hora","actor"=>0,"target"=>2,"pai"=>"2m"}
  end
  it "no" do
    observation = observation_from_json(lines,9)
    possible_actions = observation.possible_actions
    mjx_action = possible_actions[1]
    expected_mjai_action = {"type"=>"none"}
    expect(mjx_to_mjai.mjx_act_to_mjai_act(mjx_action)).to eq expected_mjai_action
  end
end
