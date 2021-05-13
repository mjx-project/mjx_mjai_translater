require './lib/mjx_mjai_translater/trans_sever'
require './lib/mjx_mjai_translater/player'
require './lib/mjx_mjai_translater/mjx_to_mjai'
require './lib/mjx_mjai_translater/open_converter'

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


RSpec.describe "forbidden_tile" do  # 選択できない牌を取得する関数
    file = File.open("spec/resources/observations-000.json", "r")
    lines = file.readlines
    it "normal" do
        observation = observation_from_json(lines,0)
        init_hand = observation.private_info.init_hand
        draw = observation.private_info.draws[0]
        init_hand.push(draw)
        possible_actions = observation.possible_actions
        player = Player.new(nil, nil) # playerのinstanceを作る
        player.update_possible_actoins(possible_actions)  # possible_actionsを更新
        player.update_hand(init_hand)  # handを更新
        expect(player.forbidden_tiles_mjai()).to eq []
    end
    it "riichi" do  # 聴牌にならないはいを返しているか
    end
    it "chi" do # くい変えになる牌を返しているか
        observation = observation_from_json(lines,208)
        hand = [73,106,75,102,2,4,91,84,99,79,105]  # 実際に渡されるhandは晒したはいは除かれている
        possible_actions = observation.possible_actions
        player = Player.new(nil, nil)
        player.update_possible_actoins(possible_actions)  
        player.update_hand(hand) 
        expect(player.forbidden_tiles_mjai()).to eq ["7s"] # 99は7sで
    end
end