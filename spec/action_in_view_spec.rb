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
    it "tsumo not actor" do # idがactorと一致していない時
    end
    it "tsumo actor" do # idがactorと一致している時
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
        observation = observation_from_json(lines,1)
        hand = observation.private_observation.curr_hand.closed_tiles
        legal_actions = observation.legal_actions
        player = Player.new(nil, nil) # playerのinstanceを作る
        player.update_possible_actoins(legal_actions)  # legal_actionsを更新
        player.update_hand(hand)  # handを更新
        expect(player.forbidden_tiles_mjai()).to eq []
    end
    it "riichi" do  # 聴牌にならないはいを返しているか
        observation = observation_from_json(lines,130)
        hand = observation.private_observation.curr_hand.closed_tiles
        legal_actions = observation.legal_actions
        player = Player.new(nil, nil) # playerのinstanceを作る
        player.update_possible_actoins(legal_actions) 
        player.update_hand(hand) 
        expect(player.forbidden_tiles_mjai()).to eq ["1p","2p","3p","5p","6p","7p","8p","9p","8s"]
    end
    it "chi" do # 喰い替えになる牌を返しているか
        observation = observation_from_json(lines,71)
        hand = observation.private_observation.curr_hand.closed_tiles  # 実際に渡されるhandは晒したはいは除かれている
        legal_actions = observation.legal_actions
        player = Player.new(nil, nil)
        player.update_possible_actoins(legal_actions)  
        player.update_hand(hand) 
        expect(player.forbidden_tiles_mjai()).to eq ["3m"] # 7sを鳴いて7sを持っている。
    end
end