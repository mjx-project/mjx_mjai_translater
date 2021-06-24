require 'json'
require 'grpc'
require 'google/protobuf'
require './lib/mjx_mjai_translater/trans_sever'
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
    mjx_to_mjai = MjxToMjai.new(absolutepos_id_hash)
    trans_server = TransServer.new()
    it "DRAW" do  # actor(id)とabsolute_posは=ではないので内部で変換している。
        observation = observation_from_json(lines, 0)
        public_observation_difference = trans_server.extract_difference(observation)
        mjx_event = public_observation_difference[0]
        expected_mjai_action = {"type"=>"tsumo","actor"=>0,"pai"=>"?"}
        expect(mjx_to_mjai.mjx_event_to_mjai_action(mjx_event, nil, nil)).to eq expected_mjai_action  # mjaiのwikiを参考に作成                                                                       
    end
    it "DISCARD" do
        previous_public_observation = observation_from_json(lines, 0).public_observation.events
        observation = observation_from_json(lines, 1)
        public_observation_difference = trans_server.extract_difference(previous_public_observation, observation)
        mjx_event = public_observation_difference[0]
        expected_mjai_action = {"type"=>"dahai", "actor"=>0, "pai"=>"E", "tsumogiri"=>false}
        expect(mjx_to_mjai.mjx_event_to_mjai_action(mjx_event, nil, nil)).to eq expected_mjai_action 
    end
    it "TSUMOGIRI" do
        previous_public_observation = observation_from_json(lines, 1).public_observation.events
        observation = observation_from_json(lines, 2)
        public_observation_difference = trans_server.extract_difference(previous_public_observation, observation)
        mjx_event = public_observation_difference[4]
        expected_mjai_action = {"type"=>"dahai", "actor"=>2, "pai"=>"W", "tsumogiri"=>true}
        expect(mjx_to_mjai.mjx_event_to_mjai_action(mjx_event, nil, nil)).to eq expected_mjai_action 
    end
    it "CHI" do
        previous_public_observation = observation_from_json(lines, 7).public_observation.events
        observation = observation_from_json(lines, 8)
        public_observation_difference = trans_server.extract_difference(previous_public_observation, observation)
        mjx_event = public_observation_difference[5]
        expected_mjai_action = {"type"=>"chi", "actor"=>3, "target"=>2, "pai"=>"9p", "consumed"=>["7p", "8p"]}
        expect(mjx_to_mjai.mjx_event_to_mjai_action(mjx_event, nil, nil)).to eq expected_mjai_action
        #38, 39
    end
    it "PON" do
        previous_public_observation = observation_from_json(lines, 5).public_observation.events
        observation = observation_from_json(lines, 6)
        public_observation_difference = trans_server.extract_difference(previous_public_observation, observation)
        mjx_event = public_observation_difference[0]
        expected_mjai_action = {"type"=>"pon", "actor"=>0, "target"=>1, "pai"=>"4p", "consumed"=>["4p", "4p"]}
        expect(mjx_to_mjai.mjx_event_to_mjai_action(mjx_event, nil, nil)).to eq expected_mjai_action
        #84, 85
    end
    it "ADDED_KAN" do
        previous_public_observation = observation_from_json(lines, 41).public_observation.events
        observation = observation_from_json(lines, 42)
        public_observation_difference = trans_server.extract_difference(previous_public_observation, observation)
        mjx_event = public_observation_difference[6]
        expected_mjai_action = {"type"=>"kakan","actor"=>3,"pai"=>"9p","consumed"=>["9p", "9p", "9p"]}
        expect(mjx_to_mjai.mjx_event_to_mjai_action(mjx_event, nil, nil)).to eq expected_mjai_action
    end
    it "OPEN_KAN" do
        previous_public_observation = observation_from_json(lines_2, 3).public_observation.events
        observation = observation_from_json(lines_2, 4)
        public_observation_difference = trans_server.extract_difference(previous_public_observation, observation)
        mjx_event = public_observation_difference[7]
        expected_mjai_action = {"type"=>"daiminkan", "actor"=>0, "target"=>1, "pai"=>"7s", "consumed"=>["7s", "7s", "7s"]}
        expect(mjx_to_mjai.mjx_event_to_mjai_action(mjx_event, nil, nil)).to eq expected_mjai_action
    end
    it "CLOSED_KAN" do
        previous_public_observation = observation_from_json(lines, 283).public_observation.events 
        observation = observation_from_json(lines, 284)
        public_observation_difference = trans_server.extract_difference(previous_public_observation, observation)
        mjx_event = public_observation_difference[4]
        expected_mjai_action = {"type"=>"ankan","actor"=>2,"consumed"=>["9p", "9p", "9p", "9p"]}
        expect(mjx_to_mjai.mjx_event_to_mjai_action(mjx_event, nil, nil)).to eq expected_mjai_action
        # 153 154  
    end  
    it "RIICHI" do
        previous_public_observation = observation_from_json(lines, 92).public_observation.events
        observation = observation_from_json(lines, 93)
        public_observation_difference = trans_server.extract_difference(previous_public_observation, observation)
        mjx_event = public_observation_difference[6]
        expected_mjai_action = {"type"=>"reach","actor"=>3}
        expect(mjx_to_mjai.mjx_event_to_mjai_action(mjx_event, nil, nil)).to eq expected_mjai_action
    end
    it "RIICHI_SCORE_CHANGE" do
        previous_public_observation = observation_from_json(lines, 92).public_observation.events
        observation = observation_from_json(lines, 93)
        public_observation_difference = trans_server.extract_difference(previous_public_observation, observation)
        mjx_event = public_observation_difference[8]
        expected_mjai_action = {"type"=>"reach_accepted","actor"=>3,"deltas"=>[0,0,0,-1000],"scores"=>[29100, 35000, 23000, 11900]}
        expect(mjx_to_mjai.mjx_event_to_mjai_action(mjx_event,observation ,nil)).to eq expected_mjai_action
    end
    it "NEW_DORA" do
        previous_public_observation = observation_from_json(lines, 41).public_observation.events
        observation = observation_from_json(lines, 42)
        public_observation_difference = trans_server.extract_difference(previous_public_observation, observation)
        mjx_event = public_observation_difference[8]
        expected_mjai_action = {"type"=>"dora","dora_marker"=>"4s"}
        expect(mjx_to_mjai.mjx_event_to_mjai_action(mjx_event, nil, nil)).to eq expected_mjai_action
    end  
    it "RON" do 
        previous_public_observation = observation_from_json(lines, 98).public_observation.events
        observation = observation_from_json(lines, 99)
        public_observation_difference = trans_server.extract_difference(previous_public_observation, observation)
        mjx_event = public_observation_difference[-1]
        expected_mjai_action = [{"type"=>"hora","actor"=>3,"target"=>1,"pai"=>"8m","uradora_markers"=>["E"],"hora_tehais"=>["4m", "4m", "5m", "5m", "6m", "6m", "8m", "8m", "8m", "3p", "3p", "7s","8s", "9s"],
        "yakus"=>[["reach",1],["ipeko",1]],"fu"=>40,"fan"=>2,"hora_points"=>2600,"deltas"=>[0,-3500,0,4500],"scores"=>[29100,31500,23000,16400]}]
        expect(mjx_to_mjai.mjx_event_to_mjai_action(mjx_event, observation, nil)).to eq expected_mjai_action
    end 
    it "RYUKYOKU" do
        previous_public_observation = observation_from_json(lines, 270).public_observation.events
        observation = observation_from_json(lines, 271)
        public_observation_difference = trans_server.extract_difference(previous_public_observation, observation)
        mjx_event = public_observation_difference[-1]
        players = []
        4.times do |i|
            players.push(Player.new(i, nil))
            players[i].update_hand(["?"]*13)
        end
        expected_mjai_action = {"type"=>"ryukyoku","reason"=>"fanpai","tehais"=>[["1p", "2p", "3p","3p", "4p", "5p", "C"],["?","?","?","?","?","?","?","?","?","?","?","?","?"],["?","?","?","?","?","?","?","?","?","?","?","?","?"],["5mr", "5m", "7m", "8m", "9m", "7s", "7s"]],"tenpais"=>[true,false,false,true],"deltas"=>[1500,-1500,-1500,1500],"scores"=>[37600,23900,4500,34000]}
        expect(mjx_to_mjai.mjx_event_to_mjai_action(mjx_event, observation, players)).to eq expected_mjai_action
    end    
    it "DOUBLE_RON" do 
        previous_public_observation = observation_from_json(lines, 53).public_observation.events
        observation = observation_from_json(lines, 54)
        public_observation_difference = trans_server.extract_difference(previous_public_observation, observation)
        mjx_event = public_observation_difference[-1]
        expected_mjai_action = [{"type"=>"hora", "actor"=>0, "target"=>3, "pai"=>"7m", "uradora_markers"=>[], "hora_tehais"=>["3m", "3m", "7m", "7m", "7m", "4p", "5pr", "6p"],
        "yakus"=>[["houteiraoyui",1],["dora",1],["akadora",1]], "fu"=>30, "fan"=>3, "hora_points"=>5800, "deltas"=>[6100,0,0,-6100], "scores"=>[32100,26000,22000,19900]}]
    end                                         
end