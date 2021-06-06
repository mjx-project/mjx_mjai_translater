require 'json'
require 'grpc'
require 'google/protobuf'
require './lib/mjx_mjai_translater/mjai_action_to_mjx_action'
require './lib/mjx_mjai_translater/open_converter'
$LOAD_PATH.unshift(__dir__) unless $LOAD_PATH.include?(__dir__)
require "test_utils"


RSpec.describe "mjai_action_to_mjx_action" do
    file = File.open("spec/resources/observations-000.json", "r")
    lines = file.readlines
    file_1 = File.open("spec/resources/observations-001.json", "r")
    lines_1 = file_1.readlines
    file_2 = File.open("spec/resources/observations-002.json", "r")
    lines_2 = file_2.readlines
    file_3 = File.open("spec/resources/observations-003.json", "r")
    lines_3 = file_3.readlines
    absolutepos_id_hash = {0=>0,1=>1,2=>2, 3=>3}
    it "discard" do
        observation = observation_from_json(lines,1)
        possible_actions = observation.possible_actions
        mjai_action = {"type"=>"dahai", "actor"=>0, "pai"=>"1m", "tsumogiri"=>false}  # 今は起家から順番に恣意的に0,1,2,3とidを決めている。trans_server のインスタンス変数がその対応を全て管理しているので別の問題
        expect(MjaiToMjx.new(absolutepos_id_hash).mjai_act_to_mjx_act(mjai_action, possible_actions)).to eq possible_actions[0]
    end
    it "tsumogiri" do 
        observation = observation_from_json(lines,26)
        possible_actions = observation.possible_actions
        mjai_action = {"type"=>"dahai", "actor"=>0, "pai"=>"W", "tsumogiri"=>true} 
        expect(MjaiToMjx.new(absolutepos_id_hash).mjai_act_to_mjx_act(mjai_action, possible_actions)).to eq possible_actions[-1]
    end
    it "chi" do
        observation = observation_from_json(lines,10)
        possible_actions = observation.possible_actions
        mjai_action = {"type"=>"chi", "actor"=>0, "target"=>3, "pai"=>"3m", "consumed"=>["2m", "4m"]}
        expect(MjaiToMjx.new(absolutepos_id_hash).mjai_act_to_mjx_act(mjai_action, possible_actions)).to eq possible_actions[0]
    end
    it "pon" do
        observation = observation_from_json(lines,6)
        possible_actions = observation.possible_actions
        mjai_action = {"type"=>"pon", "actor"=>0, "target"=>1, "pai"=>"4p", "consumed"=>["4p", "4p"]}
        expect(MjaiToMjx.new(absolutepos_id_hash).mjai_act_to_mjx_act(mjai_action, possible_actions)).to eq possible_actions[0]
    end
    it "kakan" do
        observation = observation_from_json(lines,35)
        possible_actions = observation.possible_actions
        mjai_action = {"type"=>"kakan","actor"=>0,"pai"=>"N","consumed"=>["N", "N", "N"]}
        expect(MjaiToMjx.new(absolutepos_id_hash).mjai_act_to_mjx_act(mjai_action, possible_actions)).to eq possible_actions[0]
    end
    it "daiminkan" do
        observation = observation_from_json(lines,23)
        possible_actions = observation.possible_actions
        mjai_action = {"type"=>"daiminkan", "actor"=>0, "target"=>2, "pai"=>"2p", "consumed"=>["2p", "2p", "2p"]}
        expect(MjaiToMjx.new(absolutepos_id_hash).mjai_act_to_mjx_act(mjai_action, possible_actions)).to eq possible_actions[1]
    end
    it "ankan" do
        observation = observation_from_json(lines_1,31)
        possible_actions = observation.possible_actions
        mjai_action = {"type"=>"ankan","actor"=>1,"consumed"=>["P", "P", "P", "P"]}
        expect(MjaiToMjx.new(absolutepos_id_hash).mjai_act_to_mjx_act(mjai_action, possible_actions)).to eq possible_actions[0]
    end
    it "riichi" do
        observation = observation_from_json(lines,135)
        possible_actions = observation.possible_actions
        mjai_action = {"type"=>"reach","actor"=>0}
        expect(MjaiToMjx.new(absolutepos_id_hash).mjai_act_to_mjx_act(mjai_action, possible_actions)).to eq possible_actions[0]
    end
    it "tsumo" do
        observation = observation_from_json(lines,160)
        possible_actions = observation.possible_actions
        mjai_action = {"type"=>"hora","actor"=>0,"target"=>0,"pai"=>"8s"}
        expect(MjaiToMjx.new(absolutepos_id_hash).mjai_act_to_mjx_act(mjai_action, possible_actions)).to eq possible_actions[0]
    end
    it "ron" do
        observation = observation_from_json(lines,55)
        possible_actions = observation.possible_actions
        mjai_action = {"type"=>"hora","actor"=>0,"target"=>3,"pai"=>"7m"}
        expect(MjaiToMjx.new(absolutepos_id_hash).mjai_act_to_mjx_act(mjai_action, possible_actions)).to eq possible_actions[0]
    end
    it "none" do
        observation = observation_from_json(lines,6)
        possible_actions = observation.possible_actions
        mjai_action = {"type"=>"none"}
        expect(MjaiToMjx.new(absolutepos_id_hash).mjai_act_to_mjx_act(mjai_action, possible_actions)).to eq possible_actions[-1]
    end
end