require 'json'
require 'grpc'
require './lib/mjxproto/mjx_pb'
require './lib/mjxproto/mjx_services_pb'
require 'google/protobuf'
require './lib/mjx_mjai_translater/mjai_action_to_mjx_action'


def observation_from_json(lines,line)  # 特定の行を取得する
    json = JSON.load(lines[line])
    json_string = Google::Protobuf.encode_json(json)
    proto_observation = Google::Protobuf.decode_json(Mjxproto::Observation, json_string)
end


RSpec.describe "mjai_action_to_mjx_action" do
    file = File.open("spec/resources/observations-000.json", "r")
    lines = file.readlines
    it "discard" do
        observation = observation_from_json(lines,1)
        possible_actions = observation.possible_actions
        mjai_action = {"type"=>"dahai", "actor"=>0, "pai"=>"8m", "tsumoigri"=>false}  # 今は起家から順番に恣意的に0,1,2,3とidを決めている。trans_server のインスタンス変数がその対応を全て管理しているので別の問題
        #expect(mjai_act_to_mjx_act(mjai_action, proto_possible_actions)).to eq possible_actions[0]
    end
    it "chi" do
        observation = observation_from_json(lines,7)
        possible_actions = observation.possible_actions
        mjai_action = {"type"=>"chi", "actor"=>0, "target"=>3, "pai"=>"3p", "consumed"=>["4p", "5p"]}
        #expect(mjai_act_to_mjx_act(mjai_action, proto_possible_actions)).to eq possible_actions[0]
    end
    it "pon" do
        observation = observation_from_json(lines,9)
        possible_actions = observation.possible_actions
        mjai_action = {"type"=>"pon", "actor"=>0, "target"=>2, "pai"=>"2p", "consumed"=>["2p", "2p"]}
        #expect(mjai_act_to_mjx_act(mjai_action, proto_possible_actions)).to eq possible_actions[0]
    end
    it "daiminkan" do
        observation = observation_from_json(lines,173)
        possible_actions = observation.possible_actions
        mjai_action = {"type"=>"daiminkan", "actor"=>0, "target"=>2, "pai"=>"3p", "consumed"=>["3p", "3p", "3p"]}
        #expect(mjai_act_to_mjx_act(mjai_action, proto_possible_actions)).to eq possible_actions[0]
    end
end