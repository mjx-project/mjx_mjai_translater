#差分を取得する関数とその差分をactionに変換する関数のテスト
require 'json'
require 'grpc'
require './lib/mjxproto/mjx_pb'
require './lib/mjxproto/mjx_services_pb'
require 'google/protobuf'
require './lib/mjx_mjai_translater/trans_sever'


RSpec.describe  TransServer do
    it "event_historyの差分が適切に抽出できていること" do
        file = File.open("spec/resources/observations-000.json", "r")
        preserved_event_history = []
        expected_difference_list = []
        extracted_difference_list = []
        file.each_line { |line|
            json = JSON.load(line)
            json_string = Google::Protobuf.encode_json(json)
            proto_observation = Google::Protobuf.decode_json(Mjxproto::Observation, json_string)  # protobuf に変換
            difference_extracted = TransServer.new().extract_difference(preserved_event_history, proto_observation)  # 差分を取得する関数を動かす
            difference_expected = proto_observation.event_history.events[preserved_event_history.length .. -1]  # 差分が適切に取り出せているか 懸念点としてはチェックの仕方が差分を取り出す関数と同じロジックになってしまう可能性があること。
            expected_difference_list.append(difference_expected)
            extracted_difference_list.append(difference_extracted)
            preserved_event_history = proto_observation.event_history.events
        }                                       
        expect(extracted_difference_list).to eq expected_difference_list # 一気にチェック
    end
end

