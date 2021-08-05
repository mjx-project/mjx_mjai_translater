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
        observation = observation_from_json(lines,0)
        legal_actions = observation.legal_actions
        mjai_action = {"type"=>"dahai", "actor"=>0, "pai"=>Mjai::Pai.new("1m"), "tsumogiri"=>false}  # 今は起家から順番に恣意的に0,1,2,3とidを決めている。trans_server のインスタンス変数がその対応を全て管理しているので別の問題
        expect(MjaiToMjx.new(absolutepos_id_hash).mjai_act_to_mjx_act(mjai_action, legal_actions)).to eq legal_actions[0]
    end
    it "tsumogiri" do 
        observation = observation_from_json(lines,25)
        legal_actions = observation.legal_actions
        mjai_action = {"type"=>"dahai", "actor"=>0, "pai"=>Mjai::Pai.new("W"), "tsumogiri"=>true} 
        expect(MjaiToMjx.new(absolutepos_id_hash).mjai_act_to_mjx_act(mjai_action, legal_actions)).to eq legal_actions[-1]
    end
    it "chi" do
        observation = observation_from_json(lines,9)
        legal_actions = observation.legal_actions
        mjai_action = {"type"=>"chi", "actor"=>0, "target"=>3, "pai"=>Mjai::Pai.new("3m"), "consumed"=>[Mjai::Pai.new("2m"), Mjai::Pai.new("4m")]}
        expect(MjaiToMjx.new(absolutepos_id_hash).mjai_act_to_mjx_act(mjai_action, legal_actions)).to eq legal_actions[0]
    end
    it "pon" do
        observation = observation_from_json(lines,5)
        legal_actions = observation.legal_actions
        mjai_action = {"type"=>"pon", "actor"=>0, "target"=>1, "pai"=>Mjai::Pai.new("4p"), "consumed"=>[Mjai::Pai.new("4p"), Mjai::Pai.new("4p")]}
        expect(MjaiToMjx.new(absolutepos_id_hash).mjai_act_to_mjx_act(mjai_action, legal_actions)).to eq legal_actions[0]
    end
    it "kakan" do
        observation = observation_from_json(lines,33)
        legal_actions = observation.legal_actions
        mjai_action = {"type"=>"kakan","actor"=>0,"pai"=>Mjai::Pai.new("N"),"consumed"=>[Mjai::Pai.new("N"), Mjai::Pai.new("N"), Mjai::Pai.new("N")]}
        expect(MjaiToMjx.new(absolutepos_id_hash).mjai_act_to_mjx_act(mjai_action, legal_actions)).to eq legal_actions[0]
    end
    it "daiminkan" do
        observation = observation_from_json(lines,22)
        legal_actions = observation.legal_actions
        mjai_action = {"type"=>"daiminkan", "actor"=>0, "target"=>2, "pai"=>Mjai::Pai.new("2p"), "consumed"=>[Mjai::Pai.new("2p"), Mjai::Pai.new("2p"), Mjai::Pai.new("2p")]}
        expect(MjaiToMjx.new(absolutepos_id_hash).mjai_act_to_mjx_act(mjai_action, legal_actions)).to eq legal_actions[1]
    end
    it "ankan" do
        observation = observation_from_json(lines_1,29)
        legal_actions = observation.legal_actions
        mjai_action = {"type"=>"ankan","actor"=>1,"consumed"=>[Mjai::Pai.new("P"), Mjai::Pai.new("P"), Mjai::Pai.new("P"), Mjai::Pai.new("P")]}
        expect(MjaiToMjx.new(absolutepos_id_hash).mjai_act_to_mjx_act(mjai_action, legal_actions)).to eq legal_actions[0]
    end
    it "riichi" do
        observation = observation_from_json(lines,129)
        legal_actions = observation.legal_actions
        mjai_action = {"type"=>"reach","actor"=>0}
        expect(MjaiToMjx.new(absolutepos_id_hash).mjai_act_to_mjx_act(mjai_action, legal_actions)).to eq legal_actions[0]
    end
    it "tsumo" do
        observation = observation_from_json(lines,153)
        legal_actions = observation.legal_actions
        mjai_action = {"type"=>"hora","actor"=>0,"target"=>0,"pai"=>Mjai::Pai.new("8s")}
        expect(MjaiToMjx.new(absolutepos_id_hash).mjai_act_to_mjx_act(mjai_action, legal_actions)).to eq legal_actions[0]
    end
    it "ron" do
        observation = observation_from_json(lines,53)
        legal_actions = observation.legal_actions
        mjai_action = {"type"=>"hora","actor"=>0,"target"=>3,"pai"=>Mjai::Pai.new("7m")}
        expect(MjaiToMjx.new(absolutepos_id_hash).mjai_act_to_mjx_act(mjai_action, legal_actions)).to eq legal_actions[0]
    end
    it "none" do
        observation = observation_from_json(lines,5)
        legal_actions = observation.legal_actions
        mjai_action = {"type"=>"none"}
        expect(MjaiToMjx.new(absolutepos_id_hash).mjai_act_to_mjx_act(mjai_action, legal_actions)).to eq legal_actions[-1]
    end
end