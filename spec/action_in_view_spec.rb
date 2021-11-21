require './lib/mjx_mjai_translater/trans_server'
require './lib/mjx_mjai_translater/mjx_to_mjai'
require './lib/mjx_mjai_translater/trans_player'
$LOAD_PATH.unshift(__dir__) unless $LOAD_PATH.include?(__dir__)
require "test_utils"

RSpec.describe "action_in_view" do
    trans_server = TransServer.new({:target_id=>0, "test"=>"yes"})
    player = Player.new(nil, 0, nil)
    file = File.open("spec/resources/observations-000.json", "r")
    lines = file.readlines
    file_3 = File.open("spec/resources/observations-003.json", "r")
    lines_3 = file_3.readlines
    it "start_game" do
    end
    it "start_kyoku non actor" do
        non_tehai = [Mjai::Pai.new("?")]*13
        expected_tehai = [Mjai::Pai.new("7m"),Mjai::Pai.new("F"),Mjai::Pai.new("5m"),Mjai::Pai.new("6m"),Mjai::Pai.new("1m"),Mjai::Pai.new("7p"),Mjai::Pai.new("6m"),Mjai::Pai.new("7p"),Mjai::Pai.new("6p"),Mjai::Pai.new("W"),Mjai::Pai.new("2m"),Mjai::Pai.new("5sr"),Mjai::Pai.new("2m")]
        mjai_action = MjaiAction.new({:type => :start_kyoku,:bakaze=>Mjai::Pai.new("E"), :kyoku=>1, :honba=>0, :kyotaku=>0, :oya=>0, :dora_marker=>Mjai::Pai.new("3p"),
        :tehais=>[expected_tehai, non_tehai, non_tehai, non_tehai]})
        viewed_tehai = trans_server.action_in_view(mjai_action, 1, nil, true)
        expect(viewed_tehai).to eq MjaiAction.new({:type => :start_kyoku,:bakaze=>Mjai::Pai.new("E"), :kyoku=>1, :honba=>0, :kyotaku=>0, :oya=>0, :dora_marker=>Mjai::Pai.new("3p"),
        :tehais=>[non_tehai, non_tehai, non_tehai, non_tehai]})
    end
    it "start_kyoku actor" do
        non_tehai = [Mjai::Pai.new("?")]*13
        expected_tehai = [Mjai::Pai.new("7m"),Mjai::Pai.new("F"),Mjai::Pai.new("5m"),Mjai::Pai.new("6m"),Mjai::Pai.new("1m"),Mjai::Pai.new("7p"),Mjai::Pai.new("6m"),Mjai::Pai.new("7p"),Mjai::Pai.new("6p"),Mjai::Pai.new("W"),Mjai::Pai.new("2m"),Mjai::Pai.new("5sr"),Mjai::Pai.new("2m")]
        mjai_action = MjaiAction.new({:type => :start_kyoku,:bakaze=>Mjai::Pai.new("E"), :kyoku=>1, :honba=>0, :kyotaku=>0, :oya=>0, :dora_marker=>Mjai::Pai.new("3p"),
        :tehais=>[expected_tehai, non_tehai, non_tehai, non_tehai]})
        viewed_tehai = trans_server.action_in_view(mjai_action, 0, nil, true)
        expect(viewed_tehai).to eq MjaiAction.new({:type => :start_kyoku,:bakaze=>Mjai::Pai.new("E"), :kyoku=>1, :honba=>0, :kyotaku=>0, :oya=>0, :dora_marker=>Mjai::Pai.new("3p"),
        :tehais=>[expected_tehai, non_tehai, non_tehai, non_tehai]})
    end
    it "tsumo not actor" do # idがactorと一致していない時
        mjai_action = MjaiAction.new({:type => :tsumo, :pai => Mjai::Pai.new("E"), :actor => 0})
        viewed_tehai = trans_server.action_in_view(mjai_action, 1, nil, true)
        expect(viewed_tehai).to eq MjaiAction.new({:type => :tsumo, :pai => Mjai::Pai.new("?"), :actor => 0})
    end
    it "tsumo actor" do # idがactorと一致している時
        observation = observation_from_json(lines,1)
        legal_actions = observation.legal_actions
        trans_server = TransServer.new({:target_id=>0, "test"=>"yes"})
        player = Player.new(nil, 0, nil)
        player.observation = observation 
        trans_server.player = player
        mjai_possible_actions = [MjaiAction.new({:type => :dahai, :pai =>Mjai::Pai.new("1m"), :actor=>0,:tsumogiri=>false}), MjaiAction.new({:type => :dahai, :pai =>Mjai::Pai.new("2m"), :actor=>0,:tsumogiri=>false}),
        MjaiAction.new({:type => :dahai, :pai =>Mjai::Pai.new("4m"), :actor=>0,:tsumogiri=>false}), MjaiAction.new({:type => :dahai, :pai =>Mjai::Pai.new("1p"), :actor=>0,:tsumogiri=>false}), MjaiAction.new({:type => :dahai, :pai =>Mjai::Pai.new("2p"), :actor=>0,:tsumogiri=>false}),
        MjaiAction.new({:type => :dahai, :pai =>Mjai::Pai.new("4p"), :actor=>0,:tsumogiri=>false}), MjaiAction.new({:type => :dahai, :pai =>Mjai::Pai.new("9p"), :actor=>0,:tsumogiri=>false}), MjaiAction.new({:type => :dahai, :pai =>Mjai::Pai.new("2s"), :actor=>0,:tsumogiri=>false}),
        MjaiAction.new({:type => :dahai, :pai =>Mjai::Pai.new("7s"), :actor=>0,:tsumogiri=>false}),  MjaiAction.new({:type => :dahai, :pai =>Mjai::Pai.new("9s"), :actor=>0,:tsumogiri=>false}),  MjaiAction.new({:type => :dahai, :pai =>Mjai::Pai.new("9s"), :actor=>0,:tsumogiri=>true}),
        MjaiAction.new({:type => :dahai, :pai =>Mjai::Pai.new("W"), :actor=>0,:tsumogiri=>false}), MjaiAction.new({:type => :dahai, :pai =>Mjai::Pai.new("P"), :actor=>0,:tsumogiri=>false})]
        mjai_action = MjaiAction.new({:type => :tsumo, :pai => Mjai::Pai.new("E"), :actor => 0})
        viewed_tehai = trans_server.action_in_view(mjai_action, 0, nil, true)
        expect(viewed_tehai).to eq MjaiAction.new({:type => :tsumo, :pai => Mjai::Pai.new("E"), :actor => 0, :possible_actions=>mjai_possible_actions})
    end
    it "dahai kakan not actor" do
        observation = observation_from_json(lines,1)
        legal_actions = observation.legal_actions
        trans_server = TransServer.new({:target_id=>0, "test"=>"yes"})
        player = Player.new(nil, 0, nil)
        player.observation = observation 
        trans_server.player = player
        mjai_possible_actions = [MjaiAction.new({:type => :dahai, :pai =>Mjai::Pai.new("1m"), :actor=>0,:tsumogiri=>false}), MjaiAction.new({:type => :dahai, :pai =>Mjai::Pai.new("2m"), :actor=>0,:tsumogiri=>false}),
        MjaiAction.new({:type => :dahai, :pai =>Mjai::Pai.new("4m"), :actor=>0,:tsumogiri=>false}), MjaiAction.new({:type => :dahai, :pai =>Mjai::Pai.new("1p"), :actor=>0,:tsumogiri=>false}), MjaiAction.new({:type => :dahai, :pai =>Mjai::Pai.new("2p"), :actor=>0,:tsumogiri=>false}),
        MjaiAction.new({:type => :dahai, :pai =>Mjai::Pai.new("4p"), :actor=>0,:tsumogiri=>false}), MjaiAction.new({:type => :dahai, :pai =>Mjai::Pai.new("9p"), :actor=>0,:tsumogiri=>false}), MjaiAction.new({:type => :dahai, :pai =>Mjai::Pai.new("2s"), :actor=>0,:tsumogiri=>false}),
        MjaiAction.new({:type => :dahai, :pai =>Mjai::Pai.new("7s"), :actor=>0,:tsumogiri=>false}),  MjaiAction.new({:type => :dahai, :pai =>Mjai::Pai.new("9s"), :actor=>0,:tsumogiri=>false}),  MjaiAction.new({:type => :dahai, :pai =>Mjai::Pai.new("9s"), :actor=>0,:tsumogiri=>true}),
        MjaiAction.new({:type => :dahai, :pai =>Mjai::Pai.new("W"), :actor=>0,:tsumogiri=>false}), MjaiAction.new({:type => :dahai, :pai =>Mjai::Pai.new("P"), :actor=>0,:tsumogiri=>false})]
        mjai_action = MjaiAction.new({:type => :dahai, :pai => Mjai::Pai.new("E"), :actor => 0})
        viewed_tehai = trans_server.action_in_view(mjai_action, 1, nil, true)
        expect(viewed_tehai).to eq MjaiAction.new({:type => :dahai, :pai => Mjai::Pai.new("E"), :actor => 0, :possible_actions=>mjai_possible_actions})
    end
    it "dahai kakan actor" do
        mjai_action = MjaiAction.new({:type => :dahai, :pai => Mjai::Pai.new("E"), :actor => 0})
        viewed_tehai = trans_server.action_in_view(mjai_action, 0, nil, true)
        expect(viewed_tehai).to eq MjaiAction.new({:type => :dahai, :pai => Mjai::Pai.new("E"), :actor => 0})
    end
    it "chi pon not actor" do
        mjai_action = MjaiAction.new({:type=>:chi, :actor=>0, :target=>3, :pai=>Mjai::Pai.new("3m"), :consumed=>[Mjai::Pai.new("2m"), Mjai::Pai.new("4m")]})
        viewed_tehai = trans_server.action_in_view(mjai_action, 1, nil, true)
        expect(viewed_tehai).to eq MjaiAction.new({:type=>:chi, :actor=>0, :target=>3, :pai=>Mjai::Pai.new("3m"), :consumed=>[Mjai::Pai.new("2m"), Mjai::Pai.new("4m")]})
    end
    it "chi pon actor" do
        observation = observation_from_json(lines,71)
        hand = observation.private_observation.curr_hand.closed_tiles  # 実際に渡されるhandは晒したはいは除かれている
        legal_actions = observation.legal_actions
        player = Player.new(nil, 0, nil) # playerのinstanceを作る
        player.observation = observation  
         
        trans_server.player = player
        mjai_action = MjaiAction.new({:type=>:chi, :actor=>0, :target=>3, :pai=>Mjai::Pai.new("7s"), :consumed=>[Mjai::Pai.new("8s"), Mjai::Pai.new("8s")]})
        viewed_tehai = trans_server.action_in_view(mjai_action, 0, nil, true)
        expect(viewed_tehai).to eq MjaiAction.new({:type=>:chi, :actor=>0, :target=>3, :pai=>Mjai::Pai.new("7s"), :consumed=>[Mjai::Pai.new("8s"), Mjai::Pai.new("8s")], :cannot_dahai => [Mjai::Pai.new("3m")]})
    end
    it "reach not actor" do
        mjai_action = MjaiAction.new({:type=>:reach,:actor=>0})
        viewed_tehai = trans_server.action_in_view(mjai_action, 1, nil, true)
        expect(viewed_tehai).to eq mjai_action = MjaiAction.new({:type=>:reach,:actor=>0})
    end
    it "reach actor" do
        observation = observation_from_json(lines,130)
        hand = observation.private_observation.curr_hand.closed_tiles
        legal_actions = observation.legal_actions
        player = Player.new(nil, 0, nil) # playerのinstanceを作る
        player.observation = observation 
         
        trans_server.player = player
        mjai_action = MjaiAction.new({:type=>:reach,:actor=>0})
        viewed_tehai = trans_server.action_in_view(mjai_action, 0, nil, true)
        forbidden_tiles = [Mjai::Pai.new("1p"),Mjai::Pai.new("2p"),Mjai::Pai.new("3p"),Mjai::Pai.new("5p"),Mjai::Pai.new("6p"),Mjai::Pai.new("7p"),Mjai::Pai.new("8p"),Mjai::Pai.new("9p"),Mjai::Pai.new("8s")]
        expect(viewed_tehai).to eq mjai_action = MjaiAction.new({:type=>:reach,:actor=>0, :cannot_dahai=>forbidden_tiles})
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
        player = Player.new(nil, nil, nil) # playerのinstanceを作る
        player.observation = observation  # legal_actionsを更新
          # handを更新
        expect(player.forbidden_tiles_mjai()).to eq []
    end
    it "riichi" do  # 聴牌にならない牌を返しているか
        observation = observation_from_json(lines,130)
        hand = observation.private_observation.curr_hand.closed_tiles
        legal_actions = observation.legal_actions
        player = Player.new(nil, nil, nil) # playerのinstanceを作る
        player.observation = observation 
         
        expect(player.forbidden_tiles_mjai()).to eq [Mjai::Pai.new("1p"),Mjai::Pai.new("2p"),Mjai::Pai.new("3p"),Mjai::Pai.new("5p"),Mjai::Pai.new("6p"),Mjai::Pai.new("7p"),Mjai::Pai.new("8p"),Mjai::Pai.new("9p"),Mjai::Pai.new("8s")]
    end
    it "chi" do # 喰い替えになる牌を返しているか
        observation = observation_from_json(lines,71)
        hand = observation.private_observation.curr_hand.closed_tiles  # 実際に渡されるhandは晒したはいは除かれている
        legal_actions = observation.legal_actions
        player = Player.new(nil, nil, nil) # playerのinstanceを作る
        player.observation = observation  
         
        expect(player.forbidden_tiles_mjai()).to eq [Mjai::Pai.new("3m")] # 7sを鳴いて7sを持っている。
    end
end