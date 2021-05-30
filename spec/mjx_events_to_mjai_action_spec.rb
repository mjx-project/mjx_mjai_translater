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
        previous_public_observation = observation_from_json(lines, 0).public_observation.events
        observation = observation_from_json(lines, 1)
        public_observation_difference = trans_server.extract_difference(previous_public_observation, observation)
        mjx_event = public_observation_difference[0]
        expected_mjai_action = {"type"=>"tsumo","actor"=>0,"pai"=>"?"}
        expect(mjx_to_mjai.mjx_event_to_mjai_action(mjx_event, nil)).to eq expected_mjai_action  # mjaiのwikiを参考に作成                                                                       
    end
    it "DISCARD" do
    end
    it "TSUMOGIRI" do
    end
    it "CHI" do
        previous_public_observation = observation_from_json(lines, 4).public_observation.events
        observation = observation_from_json(lines, 5)
        public_observation_difference = trans_server.extract_difference(previous_public_observation, observation)
        mjx_event = public_observation_difference[3]
        expected_mjai_action = {"type"=>"chi", "actor"=>2, "target"=>1, "pai"=>"4p", "consumed"=>["5p", "6p"]}
        expect(mjx_to_mjai.mjx_event_to_mjai_action(mjx_event, nil)).to eq expected_mjai_action
        #38, 39
    end
    it "PON" do
        previous_public_observation = observation_from_json(lines, 1).public_observation.events
        observation = observation_from_json(lines, 2)
        public_observation_difference = trans_server.extract_difference(previous_public_observation, observation)
        mjx_event = public_observation_difference[1]
        expected_mjai_action = {"type"=>"pon", "actor"=>1, "target"=>0, "pai"=>"E", "consumed"=>["E", "E"]}
        expect(mjx_to_mjai.mjx_event_to_mjai_action(mjx_event, nil)).to eq expected_mjai_action
        #84, 85
    end
    it "ADDED_KAN" do
        previous_public_observation = observation_from_json(lines, 8).public_observation.events
        observation = observation_from_json(lines, 9)
        public_observation_difference = trans_server.extract_difference(previous_public_observation, observation)
        mjx_event = public_observation_difference[4]
        expected_mjai_action = {"type"=>"kakan","actor"=>2,"pai"=>"9m","consumed"=>["9m", "9m", "9m"]}
        expect(mjx_to_mjai.mjx_event_to_mjai_action(mjx_event, nil)).to eq expected_mjai_action
    end
    it "OPEN_KAN" do
        previous_public_observation = observation_from_json(lines_2, 129).public_observation.events
        observation = observation_from_json(lines_2, 130)
        public_observation_difference = trans_server.extract_difference(previous_public_observation, observation)
        mjx_event = public_observation_difference[5]
        expected_mjai_action = {"type"=>"daiminkan", "actor"=>1, "target"=>0, "pai"=>"W", "consumed"=>["W", "W", "W"]}
        expect(mjx_to_mjai.mjx_event_to_mjai_action(mjx_event, nil)).to eq expected_mjai_action
    end
    it "CLOSED_KAN" do
        previous_public_observation = observation_from_json(lines, 84).public_observation.events
        observation = observation_from_json(lines, 85)
        public_observation_difference = trans_server.extract_difference(previous_public_observation, observation)
        mjx_event = public_observation_difference[0]
        expected_mjai_action = {"type"=>"ankan","actor"=>0,"consumed"=>["5s", "5s", "5s", "5sr"]}
        expect(mjx_to_mjai.mjx_event_to_mjai_action(mjx_event, nil)).to eq expected_mjai_action
        # 153 154  
    end  
    it "RIICHI" do
        previous_public_observation = observation_from_json(lines, 40).public_observation.events
        observation = observation_from_json(lines, 41)
        public_observation_difference = trans_server.extract_difference(previous_public_observation, observation)
        mjx_event = public_observation_difference[4]
        expected_mjai_action = {"type"=>"reach","actor"=>3}
        expect(mjx_to_mjai.mjx_event_to_mjai_action(mjx_event, nil)).to eq expected_mjai_action
    end
    it "RIICHI_SCORE_CHANGE" do
    end
    it "NEW_DORA" do
    end                                               
end