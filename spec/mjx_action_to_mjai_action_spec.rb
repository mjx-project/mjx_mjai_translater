require "./lib/mjx_mjai_translater/mjx_to_mjai"
require 'json'
require 'grpc'
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
  file_2 = File.open("spec/resources/observations-002.json", "r")
  lines_2 = file_2.readlines
  file_3 = File.open("spec/resources/observations-003.json", "r")
  lines_3 = file_3.readlines
  mjx_to_mjai = MjxToMjai.new({0=>0,1=>1,
  2=>2, 3=>3})
  it "手出し" do
    observation = observation_from_json(lines,1)
    possible_actions = observation.possible_actions
    mjx_action = possible_actions[0]
    expected_mjai_action = {"type"=>"dahai", "actor"=>0, "pai"=>"4m", "tsumoigri"=>false}  # 今は起家から順番に恣意的に0,1,2,3とidを決めている。trans_server のインスタンス変数がその対応を全て管理しているので別の問題
    expect(mjx_to_mjai.mjx_act_to_mjai_act(mjx_action, nil)).to eq expected_mjai_action
  end
  it "ツモぎり" do
    observation = observation_from_json(lines,2)
    possible_actions = observation.possible_actions
    mjx_action = possible_actions[1]
    expected_mjai_action = {"type"=>"dahai", "actor"=>0, "pai"=>"6m", "tsumoigri"=>true} 
    expect(mjx_to_mjai.mjx_act_to_mjai_act(mjx_action, nil)).to eq expected_mjai_action
  end
  it "チー" do
    observation = observation_from_json(lines,11)
    possible_actions = observation.possible_actions
    mjx_action = possible_actions[0]
    expected_mjai_action = {"type"=>"chi", "actor"=>0, "target"=>3, "pai"=>"7s", "consumed"=>["8s", "9s"]}
    expect(mjx_to_mjai.mjx_act_to_mjai_act(mjx_action, nil)).to eq expected_mjai_action
  end
  it "ポン" do
    observation = observation_from_json(lines,5)
    possible_actions = observation.possible_actions
    mjx_action = possible_actions[0]
    expected_mjai_action = {"type"=>"pon", "actor"=>0, "target"=>2, "pai"=>"9s", "consumed"=>["9s", "9s"]}
    expect(mjx_to_mjai.mjx_act_to_mjai_act(mjx_action, nil)).to eq expected_mjai_action
  end
  it "カカン" do
    observation = observation_from_json(lines_1,43)
    possible_actions = observation.possible_actions
    mjx_action = possible_actions[0]
    expected_mjai_action = {"type"=>"kakan","actor"=>1,"pai"=>"1s","consumed"=>["1s", "1s", "1s"]}
    expect(mjx_to_mjai.mjx_act_to_mjai_act(mjx_action, nil)).to eq expected_mjai_action
  end
  it "ダイミンカン" do 
    observation = observation_from_json(lines_2,112)
    possible_actions = observation.possible_actions
    mjx_action = possible_actions[1]
    expected_mjai_action = {"type"=>"daiminkan", "actor"=>2, "target"=>3, "pai"=>"9p", "consumed"=>["9p", "9p", "9p"]}
    expect(mjx_to_mjai.mjx_act_to_mjai_act(mjx_action, nil)).to eq expected_mjai_action
  end
  it "アンカン" do
    observation = observation_from_json(lines,84)
    possible_actions = observation.possible_actions
    mjx_action = possible_actions[0]
    expected_mjai_action = {"type"=>"ankan","actor"=>0,"consumed"=>["5s", "5s", "5s", "5sr"]}
    expect(mjx_to_mjai.mjx_act_to_mjai_act(mjx_action, nil)).to eq expected_mjai_action
  end
  it "リーチ" do
    observation = observation_from_json(lines,113)
    possible_actions = observation.possible_actions
    mjx_action = possible_actions[0]
    expected_mjai_action = {"type"=>"reach","actor"=>0}
    expect(mjx_to_mjai.mjx_act_to_mjai_act(mjx_action, nil)).to eq expected_mjai_action
  end
  it "ツモ" do
    observation = observation_from_json(lines_1,128)
    possible_actions = observation.possible_actions
    public_observatoin = observation.public_observation.events
    mjx_action = possible_actions[0]
    p public_observatoin[-1].tile
    expected_mjai_action = {"type"=>"hora","actor"=>1,"target"=>1,"pai"=>"7p"}
    expect(mjx_to_mjai.mjx_act_to_mjai_act(mjx_action, public_observatoin)).to eq expected_mjai_action
  end
  it "ロン" do
    observation = observation_from_json(lines,87)
    possible_actions = observation.possible_actions
    public_observatoin = observation.public_observation.events
    mjx_action = possible_actions[0]
    p public_observatoin[-1].tile
    expected_mjai_action = {"type"=>"hora","actor"=>0,"target"=>2,"pai"=>"5p"}
    expect(mjx_to_mjai.mjx_act_to_mjai_act(mjx_action, public_observatoin)).to eq expected_mjai_action
  end
  it "no" do
    observation = observation_from_json(lines,5)
    possible_actions = observation.possible_actions
    mjx_action = possible_actions[-1]
    expected_mjai_action = {"type"=>"none"}
    expect(mjx_to_mjai.mjx_act_to_mjai_act(mjx_action, nil)).to eq expected_mjai_action
  end
end
