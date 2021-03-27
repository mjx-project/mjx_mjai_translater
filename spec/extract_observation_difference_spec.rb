#差分を取得する関数とその差分をactionに変換する関数のテスト
require 'json'
require 'grpc'
require './lib/mjxproto/mjx_pb'
require './lib/mjxproto/mjx_services_pb'
require 'google/protobuf'
require './lib/mjx_mjai_translater/trans_sever'
require 'json'

def observation_from_json(lines,line)  # 特定の行を取得する
    json = JSON.load(lines[line])
    json_string = Google::Protobuf.encode_json(json)
    proto_observation = Google::Protobuf.decode_json(Mjxproto::Observation, json_string)
end

RSpec.describe  TransServer do
    file = File.open("spec/resources/observations-000.json", "r")
    lines = file.readlines
    it "局の最初" do
        observation = observation_from_json(lines, 0)
        difference_extracted = TransServer.new().extract_difference(observation)  # 差分を取得する関数を動かす   
        expected_hash = {"eventHistory":{"events":[{}]}}
        expected_proto = Google::Protobuf.decode_json(Mjxproto::Observation,expected_hash.to_json.to_s)
        expect(difference_extracted).to eq  expected_proto.event_history.events                       
    end
    it "局の途中" do
        observation_previous = observation_from_json(lines, 0)
        observation = observation_from_json(lines, 1)
        difference_extracted = TransServer.new().extract_difference(observation_previous.event_history.events, observation)
        expected_hash = {"eventHistory":{"events":[{"type":"EVENT_TYPE_DISCARD_FROM_HAND","tile":109},{"who":"ABSOLUTE_POS_INIT_SOUTH"},{"type":"EVENT_TYPE_DISCARD_FROM_HAND","who":"ABSOLUTE_POS_INIT_SOUTH","tile":114},{"who":"ABSOLUTE_POS_INIT_WEST"},{"type":"EVENT_TYPE_DISCARD_FROM_HAND","who":"ABSOLUTE_POS_INIT_WEST","tile":38},{"who":"ABSOLUTE_POS_INIT_NORTH"},{"type":"EVENT_TYPE_DISCARD_FROM_HAND","who":"ABSOLUTE_POS_INIT_NORTH","tile":110},{}]}}
        expected_proto = Google::Protobuf.decode_json(Mjxproto::Observation,expected_hash.to_json.to_s)
        expect(difference_extracted).to eq  expected_proto.event_history.events
    end
end


RSpec.describe "observation間のdrawsの変動" do  # ツモ牌の情報の取得がdraws[-1]で良いことを確約するためのテスト
    file = File.open("spec/resources/observations-000.json", "r")
    lines = file.readlines
    previous_draws = []
    it "変動が1以下であること" do
        lines.length.times do |line|
            current_draws = observation_from_json(lines, line).private_info.draws  
            expect(current_draws.length - previous_draws.length).to be <= 1
            previous_draws = current_draws  # 更新
        end
    end
end
