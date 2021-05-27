require 'json'
require 'grpc'
require './lib/mjxproto/mjx_pb'
require './lib/mjxproto/mjx_services_pb'
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
    it "ツモ、捨て牌" do  # actor(id)とabsolute_posは=ではないので内部で変換している。
        previous_history = observation_from_json(lines, 0).event_history.events
        observation = observation_from_json(lines, 1)
        history_difference = trans_server.extract_difference(previous_history, observation)
        expect(trans_server.convert_to_mjai_actions(history_difference, [26000,26000,26000,21000])).to eq [{"type"=>"dahai","actor"=>0,"pai"=>"E", "tsumogiri"=>false}, {"type"=>"tsumo","actor"=>1,"pai"=>"?"},
                                                                                {"type"=>"dahai","actor"=>1,"pai"=>"S", "tsumogiri"=>false}, {"type"=>"tsumo","actor"=>2,"pai"=>"?"},
                                                                                {"type"=>"dahai","actor"=>2,"pai"=>"1p", "tsumogiri"=>false}, {"type"=>"tsumo","actor"=>3,"pai"=>"?"},
                                                                                {"type"=>"dahai","actor"=>3,"pai"=>"E", "tsumogiri"=>false}, {"type"=>"tsumo","actor"=>0,"pai"=>"?"}]  # mjaiのwikiを参考に作成
        #0 1                                                                                
    end
    it "リーチ, ポン" do
        previous_history = observation_from_json(lines, 38).event_history.events
        observation = observation_from_json(lines, 39)
        history_difference = trans_server.extract_difference(previous_history, observation)
        expect(trans_server.convert_to_mjai_actions(history_difference, [26000,26000,26000,22000])).to eq [{"type"=>"dahai","actor"=>0,"pai"=>"2p", "tsumogiri"=>false}, {"type"=>"pon","actor"=>2,"target"=>0,"pai"=>"2p","consumed"=>["2p","2p"]},
        {"type"=>"dahai","actor"=>2,"pai"=>"1p", "tsumogiri"=>false}, {"type"=>"tsumo", "actor"=>3,"pai"=>"?"},{"type"=>"reach","actor"=>3}, 
        {"type"=>"dahai", "actor"=>3,"pai"=>"3p", "tsumogiri"=>false}, {"type"=>"reach_accepted","actor"=>3, "deltas"=>[0,0,0,-1000], "scoers"=>[26000,26000,26000,21000]},
        {"type"=>"tsumo", "actor"=>0, "pai"=>"?"}]
        #38, 39
    end
    it "チー" do
        previous_history = observation_from_json(lines, 84).event_history.events
        observation = observation_from_json(lines, 85)
        history_difference = trans_server.extract_difference(previous_history, observation)
        expect(trans_server.convert_to_mjai_actions(history_difference, [26000,26000,26000,21000])).to eq [{"type"=>"dahai","actor"=>0,"pai"=>"1p", "tsumogiri"=>false}, {"type"=>"chi","actor"=>1,"target"=>0,"pai"=>"1p", "consumed"=>["2p","3p"]},
        {"type"=>"dahai","actor"=>1,"pai"=>"6s", "tsumogiri"=>false}, {"type"=>"tsumo","actor"=>2,"pai"=>"?"},
        {"type"=>"dahai","actor"=>2,"pai"=>"1s", "tsumogiri"=>true}, {"type"=>"tsumo","actor"=>3,"pai"=>"?"},
        {"type"=>"dahai","actor"=>3,"pai"=>"9p", "tsumogiri"=>true}, {"type"=>"tsumo","actor"=>0,"pai"=>"?"}]
        #84, 85
    end
    it "カカン" do
        previous_history = observation_from_json(lines_1, 125).event_history.events
        observation = observation_from_json(lines_1, 126)
        history_difference = trans_server.extract_difference(previous_history, observation)
        expect(trans_server.convert_to_mjai_actions(history_difference, [26000,26000,26000,21000])).to eq [{"type"=>"kakan","actor"=>1,"pai"=>"P","consumed"=>["P","P","P"]}, {"type"=>"tsumo","actor"=>1,"pai"=>"?"}]
    end
    it "ミンカン" do
        previous_history = observation_from_json(lines_1, 197).event_history.events
        observation = observation_from_json(lines_1, 198)
        history_difference = trans_server.extract_difference(previous_history, observation) 
        expect(trans_server.convert_to_mjai_actions(history_difference, [26000,26000,26000,21000])).to eq [{"type"=>"dahai","actor"=>1,"pai"=>"9m", "tsumogiri"=>true},{"type"=>"daiminkan","actor"=>2,"target"=>1, "pai"=>"9m","consumed"=>["9m","9m","9m"]},
        {"type"=>"tsumo","actor"=>2,"pai"=>"?"},{"type"=>"dora","dora_marker"=>"1s"},{"type"=>"dahai","actor"=>2,"pai"=>"W","tsumogiri"=>true},{"type"=>"tsumo","actor"=>3,"pai"=>"?"}, {"type"=>"dahai","actor"=>3,"pai"=>"5m","tsumogiri"=>true},
        {"type"=>"tsumo","actor"=>0,"pai"=>"?"},{"type"=>"dahai","actor"=>0,"pai"=>"1m","tsumogiri"=>true},{"type"=>"tsumo","actor"=>1,"pai"=>"?"}]
    end
    it "アンカン" do
        previous_history = observation_from_json(lines, 153).event_history.events
        observation = observation_from_json(lines, 154)
        history_difference = trans_server.extract_difference(previous_history, observation)
        expect(trans_server.convert_to_mjai_actions(history_difference, [26000,26000,26000,21000])).to eq [{"type"=>"dahai","actor"=>0,"pai"=>"1s", "tsumogiri"=>true}, {"type"=>"tsumo","actor"=>1,"pai"=>"?"},
        {"type"=>"dahai","actor"=>1,"pai"=>"9p", "tsumogiri"=>true}, {"type"=>"tsumo","actor"=>2,"pai"=>"?"},{"type"=>"ankan","actor"=>2,"consumed"=>["1p","1p","1p","1p"]},
        {"type"=>"dora","dora_marker"=>"W"}, {"type"=>"tsumo","actor"=>2,"pai"=>"?"},{"type"=>"dahai","actor"=>2,"pai"=>"9m", "tsumogiri"=>false}, {"type"=>"tsumo","actor"=>3,"pai"=>"?"},
        {"type"=>"dahai","actor"=>3,"pai"=>"N", "tsumogiri"=>true}, {"type"=>"tsumo","actor"=>0,"pai"=>"?"}]  # history_differenceを目視で確認し、mjconvertにかけてmjaiのformatと照合した。
        # 153 154  
    end                                                        

end