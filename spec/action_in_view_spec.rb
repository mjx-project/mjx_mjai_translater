require './lib/mjx_mjai_translater/trans_sever'
require './lib/mjx_mjai_translater/trans_sever'

# action_in_view()はプレイヤーによって与える情報を調整するための関数
def observation_from_json(lines,line)  # コピペが多いのでこの関数用のファイルを別のPRデつくります。 
    json = JSON.load(lines[line])
    json_string = Google::Protobuf.encode_json(json)
    proto_observation = Google::Protobuf.decode_json(Mjxproto::Observation, json_string)
end


RSpec.describe "action_in_view" do
    it "start_game" do
    end
    it "start_kyoku" do
    end
    it "tsumo" do
    end
    it "dahai kakan" do
    end
    it "chi pon" do
    end
    it "reach" do
    end
end

RSpec.describe "forbidden_tile" do
    file = File.open("spec/resources/observations-000.json", "r")
    lines = file.readlines
    it "normal" do
        observation = observation_from_json(lines,0)
        init_hand = observation.private_info.init_hand
    end
    it "riichi" do  # 聴牌にならないはいを返しているか
    end
    it "hora" do # くい変えになる牌を返しているか
    end
end