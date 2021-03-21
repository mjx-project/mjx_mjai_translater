#差分を取得する関数とその差分をactionに変換する関数のテスト

require 'json'
require 'grpc'
require '/Users/nishimorihajimeichirou/mjai-mjx-translater/lib/mjxproto/mjx_services_pb.rb'
require 'google/protobuf'
require '/Users/nishimorihajimeichirou/mjai-mjx-translater/lib/mjxproto/mjx_pb.rb'
require '/Users/nishimorihajimeichirou/mjai-mjx-translater/lib/mjx_mjai_translater/trans_sever.rb'


file = File.open("./resources/observations-000.json", "r")


RSpec.describe  TransServer do
    it "event_historyの差分が適切に抽出できていること" do
        preserved_event_history = []
        file.each_line { |line|
            json = JSON.load(line)
            json_string = Google::Protobuf.encode_json(json)
            proto_observation = Google::Protobuf.decode_json(Mjxproto::Observation, json_string)  # protobuf に変換
            difference_extracted = TransServer.new().extract_difference(preserved_event_history, proto_observation)
            expect(difference_extracted).to eq proto_observation.event_history.events[preserved_event_history.events.length .. -1]
            preserved_event_history = proto_observation.event_history
    }
    end
end
