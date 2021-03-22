#差分を取得する関数とその差分をactionに変換する関数のテスト

require 'json'
require 'grpc'
require_relative '../lib/mjxproto/mjx_services_pb.rb'
require 'google/protobuf'
require_relative '../lib/mjxproto/mjx_pb.rb'
require_relative '../lib//mjx_mjai_translater/trans_sever.rb'



file = File.open("./resources/observations-000.json", "r")


RSpec.describe  TransServer do
    it "event_historyの差分が適切に抽出できていること" do
        preserved_event_history = []
        file.each_line { |line|
            json = JSON.load(line)
            json_string = Google::Protobuf.encode_json(json)
            proto_observation = Google::Protobuf.decode_json(Mjxproto::Observation, json_string)  # protobuf に変換
            difference_extracted = TransServer.new().extract_difference(preserved_event_history, proto_observation)  # 差分を取得する関数を動かす
            expect(difference_extracted).to eq proto_observation.event_history.events[preserved_event_history.events.length .. -1]  # 差分が適切に取り出せているか 懸念点としてはチェックの仕方が差分を取り出す関数と同じロジックになってしまう可能性があること。
            preserved_event_history = proto_observation.event_history
    }
    end
end

