require 'json'
require 'grpc'
require 'google/protobuf'
require './lib/mjx_mjai_translater/trans_sever'
$LOAD_PATH.unshift(__dir__) unless $LOAD_PATH.include?(__dir__)
require "test_utils"


RSpec.describe TransServer do
    file = File.open("spec/resources/observations-000.json", "r")
    lines = file.readlines
    file_1 = File.open("spec/resources/observations-001.json", "r")
    lines_1 = file_1.readlines
    trans_server = TransServer.new()
    it "DRAW" do  # actor(id)とabsolute_posは=ではないので内部で変換している。
        previous_public_observation = observation_from_json(lines, 0).public_observatoin.events
        observation = observation_from_json(lines, 1)
        public_observation_difference = trans_server.extract_difference(previous_public_observation, observation)
        expect(trans_server.convert_to_mjai_actions(public_observation_difference, [26000,26000,26000,21000])).to eq   # mjaiのwikiを参考に作成
        #0 1                                                                                
    end
    it "DISCARD" do
    end
    it "TSUMOGIRI" do
    end
    it "CHI" do
        previous_public_observation = observation_from_json(lines, 38).public_observatoin.events
        observation = observation_from_json(lines, 39)
        public_observation_difference = trans_server.extract_difference(previous_public_observation, observation)
        expect(trans_server.convert_to_mjai_actions(public_observation_difference, [26000,26000,26000,22000])).to eq 
        #38, 39
    end
    it "PON" do
        previous_public_observation = observation_from_json(lines, 84).public_observatoin.events
        observation = observation_from_json(lines, 85)
        public_observation_difference = trans_server.extract_difference(previous_public_observation, observation)
        expect(trans_server.convert_to_mjai_actions(public_observation_difference, [26000,26000,26000,21000])).to eq 
        #84, 85
    end
    it "ADDED_KAN" do
        previous_public_observation = observation_from_json(lines_1, 125).public_observatoin.events
        observation = observation_from_json(lines_1, 126)
        public_observation_difference = trans_server.extract_difference(previous_public_observation, observation)
        expect(trans_server.convert_to_mjai_actions(public_observation_difference, [26000,26000,26000,21000])).to eq 
    end
    it "OPEN_KAN" do
        previous_public_observation = observation_from_json(lines_1, 197).public_observatoin.events
        observation = observation_from_json(lines_1, 198)
        public_observation_difference = trans_server.extract_difference(previous_public_observation, observation) 
        expect(trans_server.convert_to_mjai_actions(public_observation_difference, [26000,26000,26000,21000])).to eq 
    end
    it "CLOSED_KAN" do
        previous_public_observation = observation_from_json(lines, 153).public_observatoin.events
        observation = observation_from_json(lines, 154)
        public_observation_difference = trans_server.extract_difference(previous_public_observation, observation)
        expect(trans_server.convert_to_mjai_actions(public_observation_difference, [26000,26000,26000,21000])).to eq   # public_observation_differenceを目視で確認し、mjconvertにかけてmjaiのformatと照合した。
        # 153 154  
    end  
    it 
    it "RIICHI" do
    end
    it "RIICHI_SCORE_CHANGE" do
    end
    it "NEW_DORA" do
    end                                               
end