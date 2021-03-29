require 'json'
require 'grpc'
require './lib/mjxproto/mjx_pb'
require './lib/mjxproto/mjx_services_pb'
require 'google/protobuf'
require './lib/mjx_mjai_translater/trans_sever'

def observation_from_json(lines,line)  # 特定の行を取得する
    json = JSON.load(lines[line])
    json_string = Google::Protobuf.encode_json(json)
    proto_observation = Google::Protobuf.decode_json(Mjxproto::Observation, json_string)
end


RSpec.describe TransServer do
    file = File.open("spec/resources/observations-000.json", "r")
    lines = file.readlines
    trans_server = TransServer.new()
    it "ツモ、捨て牌" do  # actorとabsolute_posは=ではないので内部で変換している。
        previous_history = observation_from_json(lines, 0).event_history.events
        observation = observation_from_json(lines, 1)
        history_difference = trans_server.extract_difference(previous_history, observation)
        puts history_difference
        expect(trans_server.convert_to_mjai_actions(history_difference)).to eq [{"type"=>"dahai","actor"=>0,"pai"=>"E", "tsumogiri"=>false}, {"type"=>"tsumo","actor"=>1,"pai"=>"?"},
                                                                                {"type"=>"dahai","actor"=>1,"pai"=>"S", "tsumogiri"=>false}, {"type"=>"tsumo","actor"=>2,"pai"=>"?"},
                                                                                {"type"=>"dahai","actor"=>2,"pai"=>"1s", "tsumogiri"=>false}, {"type"=>"tsumo","actor"=>3,"pai"=>"?"},
                                                                                {"type"=>"dahai","actor"=>3,"pai"=>"E", "tsumogiri"=>false}, {"type"=>"tsumo","actor"=>0,"pai"=>"?"}]  # mjaiのwikiを参考に作成
    end
    it "リーチ" do
        #38, 39
    end
    it "ポン" do
    end
    it "チー" do
        #84, 85
    end
end