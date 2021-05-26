require './lib/mjx_mjai_translater/trans_sever'
require './lib/mjx_mjai_translater/mjx_to_mjai'
require './lib/mjx_mjai_translater/player'
$LOAD_PATH.unshift(__dir__) unless $LOAD_PATH.include?(__dir__)
require "test_utils"


RSpec.describe "action_in_view" do
    trans_server = TransServer.new()
    it "start_game" do
    end
    it "start_kyoku" do
    end
    it "tsumo not actor" do # idがactorと一致している時
    end
    it "tsumo actor" do # idがactorと一致していない時
    end
    it "dahai kakan not actor" do
    end
    it "dahai kakan actor" do
    end
    it "chi pon not actor" do
    end
    it "chi actor" do
    end
    it "chi not actor" do
    end
    it "reach actor" do
    end
    it "reach not actor" do
    end
end


RSpec.describe "forbidden_tile" do  # 選択できない牌を取得する関数
    file = File.open("spec/resources/observations-000.json", "r")
    lines = file.readlines
    file_3 = File.open("spec/resources/observations-003.json", "r")
    lines_3 = file_3.readlines
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
        observation = observation_from_json(lines_3,31)
        hand = [1,101,67,5,17,13,56,11,63,124,127,102,18,125]
        possible_actions = observation.possible_actions
        player = Player.new(nil, nil) # playerのinstanceを作る
        player.update_possible_actoins(possible_actions) 
        player.update_hand(hand) 
        expect(player.forbidden_tiles_mjai()).to eq ["8s", "8p", "2m","6p", "3m", "7p", "P"]
    end
    it "chi" do # 喰い替えになる牌を返しているか
        observation = observation_from_json(lines,208)
        hand = [73,106,75,102,2,4,91,84,99,79,105]  # 実際に渡されるhandは晒したはいは除かれている
        possible_actions = observation.possible_actions
        player = Player.new(nil, nil)
        player.update_possible_actoins(possible_actions)  
        player.update_hand(hand) 
        expect(player.forbidden_tiles_mjai()).to eq ["7s"] # 7sを鳴いて7sを持っている。
    end
end