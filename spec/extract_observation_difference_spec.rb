#差分を取得する関数とその差分をactionに変換する関数のテスト
require 'json'
require 'grpc'
require 'google/protobuf'
require './lib/mjx_mjai_translater/trans_server'
$LOAD_PATH.unshift(__dir__) unless $LOAD_PATH.include?(__dir__)
require "test_utils"

RSpec.describe  TransServer do
    file = File.open("spec/resources/observations-000.json", "r")
    lines = file.readlines
    it "局の最初" do
        observation = observation_from_json(lines, 0)
        difference_extracted = TransServer.new({:target_id=>3, "test"=>"yes"}).extract_difference(observation)  # 差分を取得する関数を動かす  
        expected_hash = {"publicObservation":{"events":[{"type":"EVENT_TYPE_DRAW"}]}}
        expected_proto = Google::Protobuf.decode_json(Mjxproto::Observation,expected_hash.to_json.to_s)
        expect(difference_extracted).to eq  expected_proto.public_observation.events                       
    end
    it "局の途中" do
        observation_previous = observation_from_json(lines, 0)
        observation = observation_from_json(lines, 1)
        trans_server = TransServer.new({:target_id=>0, "test"=>"yes"})
        trans_server._mjx_events = observation_previous.public_observation.events
        difference_extracted = trans_server.extract_difference(observation)
        expected_hash = {"publicObservation":{"events":[{"tile":108},{"type":"EVENT_TYPE_DRAW","who":1},{"who":1,"tile":116},{"type":"EVENT_TYPE_DRAW","who":2},{"type":"EVENT_TYPE_TSUMOGIRI","who":2,"tile":112},{"type":"EVENT_TYPE_DRAW","who":3},{"who":3,"tile":114},{"type":"EVENT_TYPE_DRAW"}]}}
        expected_proto = Google::Protobuf.decode_json(Mjxproto::Observation,expected_hash.to_json.to_s)
        expect(difference_extracted).to eq  expected_proto.public_observation.events
    end
end


RSpec.describe "observation間のdrawsの変動" do  # ツモ牌の情報の取得がdraws[-1]で良いことを確約するためのテスト
    file = File.open("spec/resources/observations-000.json", "r")
    lines = file.readlines
    previous_draws = []
    it "変動が1以下であること" do
        lines.length.times do |line|
            current_legal_action = observation_from_json(lines, line).legal_actions[0]
            if current_legal_action.type == :ACTION_TYPE_DUMMY  # 局の初めのdummy通信はdrawの情報がないのでスキップ 
                next
            end
            current_draws = observation_from_json(lines, line).private_observation.draw_history
            expect(current_draws.length - previous_draws.length).to be <= 1
            previous_draws = current_draws  # 更新
        end
    end
end
