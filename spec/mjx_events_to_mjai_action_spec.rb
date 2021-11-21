require 'json'
require 'grpc'
require 'google/protobuf'
require './lib/mjx_mjai_translater/trans_server'
require './lib/mjx_mjai_translater/action'
$LOAD_PATH.unshift(__dir__) unless $LOAD_PATH.include?(__dir__)
require "test_utils"


RSpec.describe "mjx_eventの変換" do
    file = File.open("spec/resources/observations-000.json", "r")
    lines = file.readlines
    file_1 = File.open("spec/resources/observations-001.json", "r")
    lines_1 = file_1.readlines
    file_2 = File.open("spec/resources/observations-002.json", "r")
    lines_2 = file_2.readlines
    file_3 = File.open("spec/resources/observations-003.json", "r")
    lines_3 = file_3.readlines
    absolutepos_id_hash = {0=>0,1=>1,2=>2, 3=>3}
    mjx_to_mjai = MjxToMjai.new(absolutepos_id_hash, 0)
    trans_server = TransServer.new({:target_id=>0, "test"=>"yes"})
    it "DRAW" do  # actor(id)とabsolute_posは=ではないので内部で変換している。
        observation = observation_from_json(lines, 0)
        public_observation_difference = trans_server.extract_difference(observation)
        mjx_event = public_observation_difference[0]
        expected_mjai_action = MjaiAction.new({:type=>:tsumo,:actor=>0,:pai=>Mjai::Pai.new("2m")})
        expect(mjx_to_mjai.mjx_event_to_mjai_action(mjx_event, observation, nil)).to eq expected_mjai_action  # mjaiのwikiを参考に作成                                                                       
    end
    it "DISCARD" do
        previous_events = observation_from_json(lines, 0).public_observation.events
        observation = observation_from_json(lines, 1)
        trans_server._mjx_events = previous_events
        public_observation_difference = trans_server.extract_difference(observation)
        mjx_event = public_observation_difference[0]
        expected_mjai_action = MjaiAction.new({:type=>:dahai, :actor=>0, :pai=>Mjai::Pai.new("E"), :tsumogiri=>false})
        expect(mjx_to_mjai.mjx_event_to_mjai_action(mjx_event, nil, nil)).to eq expected_mjai_action 
    end
    it "tsumogiri" do
        previous_events = observation_from_json(lines, 1).public_observation.events
        observation = observation_from_json(lines, 2)
        trans_server._mjx_events = previous_events
        public_observation_difference = trans_server.extract_difference(observation)
        mjx_event = public_observation_difference[4]
        expected_mjai_action = MjaiAction.new({:type=>:dahai, :actor=>2, :pai=>Mjai::Pai.new("W"), :tsumogiri=>true})
        expect(mjx_to_mjai.mjx_event_to_mjai_action(mjx_event, nil, nil)).to eq expected_mjai_action 
    end
    it "CHI" do
        previous_events = observation_from_json(lines, 7).public_observation.events
        observation = observation_from_json(lines, 8)
        trans_server._mjx_events = previous_events
        public_observation_difference = trans_server.extract_difference(observation)
        mjx_event = public_observation_difference[5]
        expected_mjai_action = MjaiAction.new({:type=>:chi, :actor=>3, :target=>2, :pai=>Mjai::Pai.new("9p"), :consumed=>[Mjai::Pai.new("7p"), Mjai::Pai.new("8p")]})
        expect(mjx_to_mjai.mjx_event_to_mjai_action(mjx_event, nil, nil)).to eq expected_mjai_action
        #38, 39
    end
    it "PON" do
        previous_events = observation_from_json(lines, 5).public_observation.events
        observation = observation_from_json(lines, 6)
        trans_server._mjx_events = previous_events
        public_observation_difference = trans_server.extract_difference(observation)
        mjx_event = public_observation_difference[0]
        expected_mjai_action = MjaiAction.new({:type=>:pon, :actor=>0, :target=>1, :pai=>Mjai::Pai.new("4p"), :consumed=>[Mjai::Pai.new("4p"), Mjai::Pai.new("4p")]})
        expect(mjx_to_mjai.mjx_event_to_mjai_action(mjx_event, nil, nil)).to eq expected_mjai_action
        #84, 85
    end
    it "ADDED_KAN" do
        previous_events = observation_from_json(lines, 41).public_observation.events
        observation = observation_from_json(lines, 42)
        trans_server._mjx_events = previous_events
        public_observation_difference = trans_server.extract_difference(observation)
        mjx_event = public_observation_difference[6]
        expected_mjai_action = MjaiAction.new({:type=>:kakan,:actor=>3,:pai=>Mjai::Pai.new("9p"),:consumed=>[Mjai::Pai.new("9p"), Mjai::Pai.new("9p"), Mjai::Pai.new("9p")]})
        expect(mjx_to_mjai.mjx_event_to_mjai_action(mjx_event, nil, nil)).to eq expected_mjai_action
    end
    it "OPEN_KAN" do
        previous_events = observation_from_json(lines_2, 3).public_observation.events
        observation = observation_from_json(lines_2, 4)
        trans_server._mjx_events = previous_events
        public_observation_difference = trans_server.extract_difference(observation)
        mjx_event = public_observation_difference[7]
        expected_mjai_action = MjaiAction.new({:type=>:daiminkan, :actor=>0, :target=>1, :pai=>Mjai::Pai.new("7s"), :consumed=>[Mjai::Pai.new("7s"), Mjai::Pai.new("7s"), Mjai::Pai.new("7s")]})
        expect(mjx_to_mjai.mjx_event_to_mjai_action(mjx_event, nil, nil)).to eq expected_mjai_action
    end
    it "CLOSED_KAN" do
        previous_events = observation_from_json(lines, 283).public_observation.events 
        observation = observation_from_json(lines, 284)
        trans_server._mjx_events = previous_events
        public_observation_difference = trans_server.extract_difference(observation)
        mjx_event = public_observation_difference[4]
        expected_mjai_action = MjaiAction.new({:type=>:ankan,:actor=>2,:consumed=>[Mjai::Pai.new("9p"), Mjai::Pai.new("9p"), Mjai::Pai.new("9p"), Mjai::Pai.new("9p")]})
        expect(mjx_to_mjai.mjx_event_to_mjai_action(mjx_event, nil, nil)).to eq expected_mjai_action
        # 153 154  
    end  
    it "RIICHI" do
        previous_events = observation_from_json(lines, 92).public_observation.events
        observation = observation_from_json(lines, 93)
        trans_server._mjx_events = previous_events
        public_observation_difference = trans_server.extract_difference(observation)
        mjx_event = public_observation_difference[6]
        expected_mjai_action = MjaiAction.new({:type=>:reach,:actor=>3})
        expect(mjx_to_mjai.mjx_event_to_mjai_action(mjx_event, nil, nil)).to eq expected_mjai_action
    end
    it "RIICHI_SCORE_CHANGE" do
        previous_events = observation_from_json(lines, 92).public_observation.events
        observation = observation_from_json(lines, 93)
        trans_server._mjx_events = previous_events
        public_observation_difference = trans_server.extract_difference(observation)
        mjx_event = public_observation_difference[8]
        expected_mjai_action = MjaiAction.new({:type=>:reach_accepted,:actor=>3,:deltas=>[0,0,0,-1000],:scores=>[29100, 35000, 23000, 11900]})
        expect(mjx_to_mjai.mjx_event_to_mjai_action(mjx_event,observation ,nil)).to eq expected_mjai_action
    end
    it "NEW_DORA" do
        previous_events = observation_from_json(lines, 41).public_observation.events
        observation = observation_from_json(lines, 42)
        trans_server._mjx_events = previous_events
        public_observation_difference = trans_server.extract_difference(observation)
        mjx_event = public_observation_difference[8]
        expected_mjai_action = MjaiAction.new({:type=>:dora,:dora_marker=>Mjai::Pai.new("4s")})
        expect(mjx_to_mjai.mjx_event_to_mjai_action(mjx_event, nil, nil)).to eq expected_mjai_action
    end  
    it "RON" do 
        previous_events = observation_from_json(lines, 98).public_observation.events
        observation = observation_from_json(lines, 99)
        trans_server._mjx_events = previous_events
        public_observation_difference = trans_server.extract_difference(observation)
        mjx_event = public_observation_difference[-1]
        expected_mjai_action = MjaiAction.new({:type=>:hora,:actor=>3,:target=>1,:pai=>Mjai::Pai.new("8m"),:uradora_markers=>[Mjai::Pai.new("E")],:hora_tehais=>[Mjai::Pai.new("4m"), Mjai::Pai.new("4m"), Mjai::Pai.new("5m"), Mjai::Pai.new("5m"), Mjai::Pai.new("6m"), Mjai::Pai.new("6m"), Mjai::Pai.new("8m"), Mjai::Pai.new("8m"), Mjai::Pai.new("8m"), Mjai::Pai.new("3p"), Mjai::Pai.new("3p"), Mjai::Pai.new("7s"),Mjai::Pai.new("8s"), Mjai::Pai.new("9s")],
        :yakus=>[[:reach,1],[:ipeko,1]],:fu=>40,:fan=>2,:hora_points=>2600,:deltas=>[0,-3500,0,4500],:scores=>[29100,31500,23000,16400]})
        expect(mjx_to_mjai.mjx_event_to_mjai_action(mjx_event, observation, nil)).to eq expected_mjai_action
    end 
    it "RYUKYOKU" do
        previous_events = observation_from_json(lines, 270).public_observation.events
        observation = observation_from_json(lines, 271)
        trans_server._mjx_events = previous_events
        public_observation_difference = trans_server.extract_difference(observation)
        mjx_event = public_observation_difference[-1]
        players = [0, 1, 2, 3]
        expected_mjai_action = MjaiAction.new({:type=>:ryukyoku,:reason=>:fonpai,:tehais=>[[Mjai::Pai.new("1p"), Mjai::Pai.new("2p"), Mjai::Pai.new("3p"),Mjai::Pai.new("3p"), Mjai::Pai.new("4p"), Mjai::Pai.new("5p"), Mjai::Pai.new("C")],[Mjai::Pai.new("?"),Mjai::Pai.new("?"),Mjai::Pai.new("?"),Mjai::Pai.new("?"),Mjai::Pai.new("?"),Mjai::Pai.new("?"),Mjai::Pai.new("?"),Mjai::Pai.new("?"),Mjai::Pai.new("?"),Mjai::Pai.new("?"),Mjai::Pai.new("?"),Mjai::Pai.new("?"),Mjai::Pai.new("?")],[Mjai::Pai.new("?"),Mjai::Pai.new("?"),Mjai::Pai.new("?"),Mjai::Pai.new("?"),Mjai::Pai.new("?"),Mjai::Pai.new("?"),Mjai::Pai.new("?"),Mjai::Pai.new("?"),Mjai::Pai.new("?"),Mjai::Pai.new("?"),Mjai::Pai.new("?"),Mjai::Pai.new("?"),Mjai::Pai.new("?")],[Mjai::Pai.new("5mr"), Mjai::Pai.new("5m"), Mjai::Pai.new("7m"), Mjai::Pai.new("8m"), Mjai::Pai.new("9m"), Mjai::Pai.new("7s"), Mjai::Pai.new("7s")]],:tenpais=>[true,false,false,true],:deltas=>[1500,-1500,-1500,1500],:scores=>[37600,23900,4500,34000]})
        expect(mjx_to_mjai.mjx_event_to_mjai_action(mjx_event, observation, players)).to eq expected_mjai_action
    end    
    it "DOUBLE_RON" do 
        previous_events = observation_from_json(lines, 53).public_observation.events
        observation = observation_from_json(lines, 54)
        trans_server._mjx_events = previous_events
        public_observation_difference = trans_server.extract_difference(observation)
        mjx_event = public_observation_difference[-1]
        expected_mjai_action = [MjaiAction.new({:type=>:hora, :actor=>0, :target=>3, :pai=>Mjai::Pai.new("7m"), :uradora_markers=>[], :hora_tehais=>[Mjai::Pai.new("3m"), Mjai::Pai.new("3m"), Mjai::Pai.new("7m"), Mjai::Pai.new("7m"), Mjai::Pai.new("7m"), Mjai::Pai.new("4p"), Mjai::Pai.new("5pr"), Mjai::Pai.new("6p")],
        :yakus=>[[:houteiraoyui,1],[:dora,1],[:akadora,1]], :fu=>30, :fan=>3, :hora_points=>5800, :deltas=>[6100,0,0,-6100], :scores=>[32100,26000,22000,19900]}),
        MjaiAction.new({:type=> :hora, :actor=>1,:target=>3,:pai=>Mjai::Pai.new("7m"),:uradora_markers=>[] , :hora_tehais=>[Mjai::Pai.new("6m"), Mjai::Pai.new("7m"), Mjai::Pai.new("8m"),Mjai::Pai.new("1s"), Mjai::Pai.new("2s"), Mjai::Pai.new("3s"),Mjai::Pai.new("P"),Mjai::Pai.new("P")], :fan=>5,:fu=>30,:hora_points=>8000,:deltas=>[0,8000,0,-8000],:yakus=>[[:houteiraoyui,1],[:dora,3],[:akadora,1]], :scores=>[32100,34000,22000,11900]})]
        expect(mjx_to_mjai.mjx_event_to_mjai_action(mjx_event, observation, nil)).to eq expected_mjai_action
    end                                         
end


RSpec.describe "局、半荘の開始終了" do
    file = File.open("spec/resources/observations-000.json", "r")
    lines = file.readlines
    file_2 = File.open("spec/resources/observations-002.json", "r")
    lines_2 = file_2.readlines
    absolutepos_id_hash = {0=>0,1=>1,2=>2, 3=>3}
    mjx_to_mjai = MjxToMjai.new(absolutepos_id_hash, 1)
    it "start_kyoku only 2" do
        observation = observation_from_json(lines, 30)
        is_start_kyoku = mjx_to_mjai.is_start_kyoku(observation)
        is_start_game = mjx_to_mjai.is_start_game(observation)
        expect(is_start_kyoku).to eq true
        expect(is_start_game).to eq false
    end
    it "start_kyoku only 2" do
        observation = observation_from_json(lines_2, 21)
        is_start_kyoku = mjx_to_mjai.is_start_kyoku(observation)
        is_start_game = mjx_to_mjai.is_start_game(observation)
        expect(is_start_kyoku).to eq true
        expect(is_start_game).to eq false
    end
    it "start_game" do
        observation = observation_from_json(lines, 0)
        is_start_game = mjx_to_mjai.is_start_game(observation)
        expect(is_start_game).to eq true
    end
    it "end_kyoku only" do
        observation = observation_from_json(lines, 29)
        is_kyoku_over = mjx_to_mjai.is_kyoku_over(observation)
        is_game_over = mjx_to_mjai.is_game_over(observation)
        expect(is_kyoku_over).to eq true
        expect(is_game_over).to eq false
    end
    it "end_game" do
        observation = observation_from_json(lines, 286)
        is_game_over = mjx_to_mjai.is_game_over(observation)
        expect(is_game_over).to eq true
    end
end


RSpec.describe "局開始時のaction" do
    file = File.open("spec/resources/observations-000.json", "r")
    lines = file.readlines
    file_1 = File.open("spec/resources/observations-001.json", "r")
    lines_1 = file_1.readlines
    absolutepos_id_hash = {0=>0,1=>1,2=>2, 3=>3}
    trans_server = TransServer.new({:target_id=>1, "test"=>"yes"})
    player = Player.new(0, nil, nil)
    trans_server.player = player
    trans_server.mjx_to_mjai = MjxToMjai.new({0=>0,1=>1, 2=>2, 3=>3}, 1)
    mjx_to_mjai = MjxToMjai.new(absolutepos_id_hash, 1) 
    non_tehai = [Mjai::Pai.new("?")]*13
    it "initial_action" do
        observation = observation_from_json(lines_1, 0)
        mjai_actions = trans_server.convert_to_mjai_actions(observation , nil)
        expected_tehai = [Mjai::Pai.new("7m"),Mjai::Pai.new("F"),Mjai::Pai.new("5m"),Mjai::Pai.new("6m"),Mjai::Pai.new("1m"),Mjai::Pai.new("7p"),Mjai::Pai.new("6m"),Mjai::Pai.new("7p"),Mjai::Pai.new("6p"),Mjai::Pai.new("W"),Mjai::Pai.new("2m"),Mjai::Pai.new("5sr"),Mjai::Pai.new("2m")]
        expect(mjai_actions).to eq [MjaiAction.new({:type => :start_game}),MjaiAction.new({:type => :start_kyoku,:bakaze=>Mjai::Pai.new("E"), :kyoku=>1, :honba=>0, :kyotaku=>0, :oya=>0, :dora_marker=>Mjai::Pai.new("3p"),
        :tehais=>[non_tehai,expected_tehai, non_tehai, non_tehai]}), MjaiAction.new({:type=>:tsumo,:actor=>0,:pai=>Mjai::Pai.new("?")}) ,MjaiAction.new({:type=>:dahai, :actor=>0, :pai=>Mjai::Pai.new("E"), :tsumogiri=>false}), MjaiAction.new({:type=>:tsumo,:actor=>1,:pai=>Mjai::Pai.new("9m")})]
    end
end