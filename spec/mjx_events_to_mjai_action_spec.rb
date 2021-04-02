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
    it "ツモ、捨て牌" do  # actor(id)とabsolute_posは=ではないので内部で変換している。
        previous_history = observation_from_json(lines, 0).event_history.events
        observation = observation_from_json(lines, 1)
        history_difference = trans_server.extract_difference(previous_history, observation)
        expect(trans_server.convert_to_mjai_actions(history_difference)).to eq [{"type"=>"dahai","actor"=>0,"pai"=>"E", "tsumogiri"=>false}, {"type"=>"tsumo","actor"=>1,"pai"=>"?"},
                                                                                {"type"=>"dahai","actor"=>1,"pai"=>"S", "tsumogiri"=>false}, {"type"=>"tsumo","actor"=>2,"pai"=>"?"},
                                                                                {"type"=>"dahai","actor"=>2,"pai"=>"1p", "tsumogiri"=>false}, {"type"=>"tsumo","actor"=>3,"pai"=>"?"},
                                                                                {"type"=>"dahai","actor"=>3,"pai"=>"E", "tsumogiri"=>false}, {"type"=>"tsumo","actor"=>0,"pai"=>"?"}]  # mjaiのwikiを参考に作成
        #0 1                                                                                
    end
    it "リーチ, ポン" do
        previous_history = observation_from_json(lines, 38).event_history.events
        observation = observation_from_json(lines, 39)
        history_difference = trans_server.extract_difference(previous_history, observation)
        p history_difference
        expect(trans_server.convert_to_mjai_actions(history_difference)).to eq [{"type"=>"dahai","actor"=>0,"pai"=>"2p", "tsumogiri"=>false}, {"type"=>"pon","actor"=>2,"target"=>0,"pai"=>"2p","consumed"=>["2p","2p"]},
        {"type"=>"dahai","actor"=>2,"pai"=>"1p", "tsumogiri"=>false}, {"type"=>"tsumo", "actor"=>3,"pai"=>"?"},{"type"=>"reach","actor"=>3}, 
        {"type"=>"dahai", "actor"=>3,"pai"=>"3p", "tsumogiri"=>false}, {"type"=>"reach_accepted","actor"=>3},
        {"type"=>"tsumo", "actor"=>0, "pai"=>"?"}]
        #38, 39
    end
    it "チー" do
        previous_history = observation_from_json(lines, 84).event_history.events
        observation = observation_from_json(lines, 85)
        history_difference = trans_server.extract_difference(previous_history, observation)
        expect(trans_server.convert_to_mjai_actions(history_difference)).to eq [{"type"=>"dahai","actor"=>0,"pai"=>"1p", "tsumogiri"=>false}, {"type"=>"chi","actor"=>1,"target"=>0,"pai"=>"1p", "consumed"=>["2p","3p"]},
        {"type"=>"dahai","actor"=>1,"pai"=>"6s", "tsumogiri"=>false}, {"type"=>"tsumo","actor"=>2,"pai"=>"?"},
        {"type"=>"dahai","actor"=>2,"pai"=>"1s", "tsumogiri"=>true}, {"type"=>"tsumo","actor"=>3,"pai"=>"?"},
        {"type"=>"dahai","actor"=>3,"pai"=>"9p", "tsumogiri"=>true}, {"type"=>"tsumo","actor"=>0,"pai"=>"?"}]
        #84, 85
    end
    it "アンカン" do
        previous_history = observation_from_json(lines, 153).event_history.events
        observation = observation_from_json(lines, 154)
        history_difference = trans_server.extract_difference(previous_history, observation)
        expect(trans_server.convert_to_mjai_actions(history_difference)).to eq [{"type"=>"dahai","actor"=>0,"pai"=>"1s", "tsumogiri"=>true}, {"type"=>"tsumo","actor"=>1,"pai"=>"?"},
        {"type"=>"dahai","actor"=>1,"pai"=>"9p", "tsumogiri"=>true}, {"type"=>"tsumo","actor"=>2,"pai"=>"?"},{"type"=>"ankan","actor"=>2,"consumed"=>["1p","1p","1p","1p"]},
        {"type"=>"dora","dora_marker"=>"W"}, {"type"=>"tsumo","actor"=>2,"pai"=>"?"},{"type"=>"dahai","actor"=>2,"pai"=>"9m", "tsumogiri"=>false}, {"type"=>"tsumo","actor"=>3,"pai"=>"?"},
        {"type"=>"dahai","actor"=>3,"pai"=>"N", "tsumogiri"=>true}, {"type"=>"tsumo","actor"=>0,"pai"=>"?"}]  # history_differenceを目視で確認し、mjconvertにかけてmjaiのformatと照合した。
        # 153 154  
    end                                                        

end