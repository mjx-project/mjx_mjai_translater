require "./lib/mjx_mjai_translater/mjx_to_mjai"


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
  end
  it "ツモ" do
    observation = observation_from_json(lines,96)
    possible_actions = observation.possible_actions
    mjx_action = possible_actions[0]
    expected_mjai_action = {"type"=>"hora","actor"=>0,"target"=>2,"pai"=>"2m","uradora_markers"=>["8p"],"hora_tehais"=>["1m","3m","5m","6m","7m","1p","2p","3p","4p","5pr","6p","W","W","2m"],"yakus"=>[["akadora",1],["reach",1],["menzenchin_tsumoho",1]],"fu":30,"fan":3,"hora_points"=>4000,"deltas"=>[-2100,-1100,6300,-1100],"scores"=>[25900,21900,29300,22900]}
  end
  it "ロン" do
    observation = observation_from_json(lines,156)
    possible_actions = observation.possible_actions
    mjx_action = possible_actions[0]
    expected_mjai_action = {"type"=>"hora","actor"=>0,"target"=>2,"pai"=>"2m","uradora_markers"=>["8p"],"hora_tehais"=>["1m","3m","5m","6m","7m","1p","2p","3p","4p","5pr","6p","W","W","2m"],"yakus"=>[["akadora",1],["reach",1],["menzenchin_tsumoho",1]],"fu":30,"fan":3,"hora_points"=>4000,"deltas"=>[-2100,-1100,6300,-1100],"scores"=>[25900,21900,29300,22900]}
  end
  it "no" do
    observation = observation_from_json(lines,9)
    possible_actions = observation.possible_actions
    mjx_action = possible_actions[1]
    expected_mjai_action = {"type"=>"none"}
  end
end
