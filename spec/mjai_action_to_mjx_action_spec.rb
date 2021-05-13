require 'json'
require 'grpc'
require './lib/mjxproto/mjx_pb'
require './lib/mjxproto/mjx_services_pb'
require 'google/protobuf'
require './lib/mjx_mjai_translater/mjai_action_to_mjx_action'
$LOAD_PATH.unshift(__dir__) unless $LOAD_PATH.include?(__dir__)
require "test_util"


RSpec.describe "mjai_action_to_mjx_action" do
    file = File.open("spec/resources/observations-000.json", "r")
    lines = file.readlines
    absolutepos_id_hash = {:ABSOLUTE_POS_INIT_EAST=>0,:ABSOLUTE_POS_INIT_SOUTH=>1,
    :ABSOLUTE_POS_INIT_WEST=>2, :ABSOLUTE_POS_INIT_NORTH=>3}
    it "discard" do
        observation = observation_from_json(lines,1)
        possible_actions = observation.possible_actions
        mjai_action = {"type"=>"dahai", "actor"=>0, "pai"=>"8m", "tsumoigri"=>false}  # 今は起家から順番に恣意的に0,1,2,3とidを決めている。trans_server のインスタンス変数がその対応を全て管理しているので別の問題
        expect(MjaiToMjx.new(absolutepos_id_hash).mjai_act_to_mjx_act(mjai_action, possible_actions)).to eq possible_actions[0]
    end
    it "chi" do
        observation = observation_from_json(lines,7)
        possible_actions = observation.possible_actions
        mjai_action = {"type"=>"chi", "actor"=>0, "target"=>3, "pai"=>"3p", "consumed"=>["4p", "5p"]}
        expect(MjaiToMjx.new(absolutepos_id_hash).mjai_act_to_mjx_act(mjai_action, possible_actions)).to eq possible_actions[0]
    end
    it "pon" do
        observation = observation_from_json(lines,9)
        possible_actions = observation.possible_actions
        mjai_action = {"type"=>"pon", "actor"=>0, "target"=>2, "pai"=>"2p", "consumed"=>["2p", "2p"]}
        expect(MjaiToMjx.new(absolutepos_id_hash).mjai_act_to_mjx_act(mjai_action, possible_actions)).to eq possible_actions[0]
    end
    it "daiminkan" do
        observation = observation_from_json(lines,173)
        possible_actions = observation.possible_actions
        mjai_action = {"type"=>"daiminkan", "actor"=>0, "target"=>2, "pai"=>"3p", "consumed"=>["3p", "3p", "3p"]}
        expect(MjaiToMjx.new(absolutepos_id_hash).mjai_act_to_mjx_act(mjai_action, possible_actions)).to eq possible_actions[1]
    end
    it "tsumo" do
        observation = observation_from_json(lines,96)
        possible_actions = observation.possible_actions
        mjai_action = {"type"=>"hora","actor"=>0,"target"=>2,"pai"=>"2m","uradora_markers"=>["8p"],"hora_tehais"=>["1m","3m","5m","6m","7m","1p","2p","3p","4p","5pr","6p","W","W","2m"],"yakus"=>[["akadora",1],["reach",1],["menzenchin_tsumoho",1]],"fu":30,"fan":3,"hora_points"=>4000,"deltas"=>[-2100,-1100,6300,-1100],"scores"=>[25900,21900,29300,22900]}
        expect(MjaiToMjx.new(absolutepos_id_hash).mjai_act_to_mjx_act(mjai_action, possible_actions)).to eq possible_actions[0]
    end
    it "ron" do
        observation = observation_from_json(lines,156)
        possible_actions = observation.possible_actions
        mjai_action = {"type"=>"hora","actor"=>0,"target"=>2,"pai"=>"2m","uradora_markers"=>["8p"],"hora_tehais"=>["1m","3m","5m","6m","7m","1p","2p","3p","4p","5pr","6p","W","W","2m"],"yakus"=>[["akadora",1],["reach",1],["menzenchin_tsumoho",1]],"fu":30,"fan":3,"hora_points"=>4000,"deltas"=>[-2100,-1100,6300,-1100],"scores"=>[25900,21900,29300,22900]}
        expect(MjaiToMjx.new(absolutepos_id_hash).mjai_act_to_mjx_act(mjai_action, possible_actions)).to eq possible_actions[0]
    end
    it "none" do
        observation = observation_from_json(lines,9)
        possible_actions = observation.possible_actions
        mjai_action = {"type"=>"none"}
        expect(MjaiToMjx.new(absolutepos_id_hash).mjai_act_to_mjx_act(mjai_action, possible_actions)).to eq possible_actions[1]
    end
end