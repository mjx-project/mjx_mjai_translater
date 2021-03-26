#差分を取得する関数とその差分をactionに変換する関数のテスト
require 'json'
require 'grpc'
require './lib/mjxproto/mjx_pb'
require './lib/mjxproto/mjx_services_pb'
require 'google/protobuf'
require './lib/mjx_mjai_translater/trans_sever'

def observation_from_json(line)
    json = JSON.load(lines[line])
    json_string = Google::Protobuf.encode_json(json)
    proto_observation = Google::Protobuf.decode_json(Mjxproto::Observation, json_string)
end


RSpec.describe  TransServer do
    file = File.open("spec/resources/observations-000.json", "r")
    lines = file.readlines
    it "局の最初" do
        observation = observation_from_json(0)
        difference_extracted = TransServer.new().extract_difference(None, observation)  # 差分を取得する関数を動かす                          
        expect(difference_extracted).to eq  [{"init_hand"[43,45,93,113,49,101,80,40,70,95,19,109,4]}, {"draw":28}]
    end
    it "局の途中"
        observation_previous = observation_from_json(0)
        observation = observation_from_json(1)
        difference_extracted = TransServer.new().extract_difference(observation_previous, observation)
        expect(difference_extracted).to eq [{"draw":55}, {"discard":109}]
    end
end

