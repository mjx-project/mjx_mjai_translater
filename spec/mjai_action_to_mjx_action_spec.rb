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
        mjai_action = {"type"=>"dahai", "actor"=>0, "pai"=>"4m", "tsumoigri"=>false}  # 今は起家から順番に恣意的に0,1,2,3とidを決めている。trans_server のインスタンス変数がその対応を全て管理しているので別の問題
        expect(MjaiToMjx.new(absolutepos_id_hash).mjai_act_to_mjx_act(mjai_action, possible_actions)).to eq possible_actions[0]
    end
    it "tsumogiri" do 
        observation = observation_from_json(lines,2)
        possible_actions = observation.possible_actions
        mjai_action = {"type"=>"dahai", "actor"=>0, "pai"=>"6m", "tsumoigri"=>true} 
        expect(MjaiToMjx.new(absolutepos_id_hash).mjai_act_to_mjx_act(mjai_action, possible_actions)).to eq possible_actions[1]
    end
    it "chi" do
        observation = observation_from_json(lines,11)
        possible_actions = observation.possible_actions
        mjai_action = {"type"=>"chi", "actor"=>0, "target"=>3, "pai"=>"7s", "consumed"=>["8s", "9s"]}
        expect(MjaiToMjx.new(absolutepos_id_hash).mjai_act_to_mjx_act(mjai_action, possible_actions)).to eq possible_actions[0]
    end
    it "pon" do
        observation = observation_from_json(lines,5)
        possible_actions = observation.possible_actions
        mjai_action = {"type"=>"pon", "actor"=>0, "target"=>2, "pai"=>"9s", "consumed"=>["9s", "9s"]}
        expect(MjaiToMjx.new(absolutepos_id_hash).mjai_act_to_mjx_act(mjai_action, possible_actions)).to eq possible_actions[0]
    end
    it "kakan" do
        observation = observation_from_json(lines_1,43)
        possible_actions = observation.possible_actions
        mjai_action = {"type"=>"kakan","actor"=>1,"pai"=>"1s","consumed"=>["1s", "1s", "1s"]}
        expect(MjaiToMjx.new(absolutepos_id_hash).mjai_act_to_mjx_act(mjai_action, possible_actions)).to eq possible_actions[0]
    end
    it "daiminkan" do
        observation = observation_from_json(lines_2,112)
        possible_actions = observation.possible_actions
        mjai_action = {"type"=>"daiminkan", "actor"=>2, "target"=>3, "pai"=>"9p", "consumed"=>["9p", "9p", "9p"]}
        expect(MjaiToMjx.new(absolutepos_id_hash).mjai_act_to_mjx_act(mjai_action, possible_actions)).to eq possible_actions[1]
    end
    it "ankan" do
        observation = observation_from_json(lines,84)
        possible_actions = observation.possible_actions
        mjai_action = {"type"=>"ankan","actor"=>0,"consumed"=>["5s", "5s", "5s", "5sr"]}
        expect(MjaiToMjx.new(absolutepos_id_hash).mjai_act_to_mjx_act(mjai_action, possible_actions)).to eq possible_actions[0]
    end
    it "riichi" do
        observation = observation_from_json(lines,113)
        possible_actions = observation.possible_actions
        mjai_action = {"type"=>"reach","actor"=>0}
        expect(MjaiToMjx.new(absolutepos_id_hash).mjai_act_to_mjx_act(mjai_action, possible_actions)).to eq possible_actions[0]
    end
    it "tsumo" do
        observation = observation_from_json(lines_1,128)
        possible_actions = observation.possible_actions
        mjai_action = {"type"=>"hora","actor"=>1,"target"=>1,"pai"=>"7p","uradora_markers"=>["8p"],"hora_tehais"=>["1m","2m","3m","1p","2p","3p","3p","3p","5pr","6pr","1s","2s", "3s"],"yakus"=>[["akadora",1],["reach",1],["menzenchin_tsumoho",1],["ippatsu",1]],"fu":30,"fan":4,"hora_points"=>7900,"deltas"=>[-2100,9200,-2100,-4000],"scores"=>[22300,34200,14600,28900]}
        expect(MjaiToMjx.new(absolutepos_id_hash).mjai_act_to_mjx_act(mjai_action, possible_actions)).to eq possible_actions[0]
    end
    it "ron" do
        observation = observation_from_json(lines,87)
        possible_actions = observation.possible_actions
        mjai_action = {"type"=>"hora","actor"=>0,"target"=>2,"pai"=>"5p","uradora_markers"=>["8p"],"hora_tehais"=>["4p","4p","5pr","5p","5p","6p","7p","8p","7s","7s","7s","5s","5s","5s", "5sr"],"yakus"=>[["akadora",2],["pinfu",1],["dora",1]],"fu":40,"fan":4,"hora_points"=>8000,"deltas"=>[9600,0,-8600,0],"scores"=>[29300,33200,17400,20100]}
        expect(MjaiToMjx.new(absolutepos_id_hash).mjai_act_to_mjx_act(mjai_action, possible_actions)).to eq possible_actions[0]
    end
    it "none" do
        observation = observation_from_json(lines,5)
        possible_actions = observation.possible_actions
        mjai_action = {"type"=>"none"}
        expect(MjaiToMjx.new(absolutepos_id_hash).mjai_act_to_mjx_act(mjai_action, possible_actions)).to eq possible_actions[-1]
    end
end