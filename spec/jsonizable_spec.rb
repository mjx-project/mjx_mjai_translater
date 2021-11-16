require './lib/mjx_mjai_translater/action'
require 'json'


RSpec.describe "between action and json" do
    it "to_json" do
        action = MjaiAction.new({:type=>:dahai, :actor=>0, :pai=>Mjai::Pai.new("1m"), :tsumogiri=>false})
        expected_action = JSON[{"type"=>"dahai", "actor"=>0, "pai"=>"1m", "tsumogiri"=>false}]
        expect(action.to_json()).to eq expected_action
    end
    it "to_json reach_accepted" do
        action = MjaiAction.new({:type=>:reach_accepted,:actor=>3,:deltas=>[0,0,0,-1000],:scores=>[29100, 35000, 23000, 11900]})
        expected_action = JSON[{"type"=>"reach_accepted", "actor"=>3, "deltas"=>[0,0,0,-1000], "scores"=>[29100, 35000, 23000, 11900]}]
        p action.to_json
        expect(action.to_json()).to eq expected_action
    end
    it "to_json ryukyoku" do
        action = MjaiAction.new({:type=>:ryukyoku,:reason=>:fonpai,:tehais=>[[Mjai::Pai.new("1p"), Mjai::Pai.new("2p"), Mjai::Pai.new("3p"),Mjai::Pai.new("3p"), Mjai::Pai.new("4p"), Mjai::Pai.new("5p"), Mjai::Pai.new("C")],[Mjai::Pai.new("?"),Mjai::Pai.new("?"),Mjai::Pai.new("?"),Mjai::Pai.new("?"),Mjai::Pai.new("?"),Mjai::Pai.new("?"),Mjai::Pai.new("?"),Mjai::Pai.new("?"),Mjai::Pai.new("?"),Mjai::Pai.new("?"),Mjai::Pai.new("?"),Mjai::Pai.new("?"),Mjai::Pai.new("?")],[Mjai::Pai.new("?"),Mjai::Pai.new("?"),Mjai::Pai.new("?"),Mjai::Pai.new("?"),Mjai::Pai.new("?"),Mjai::Pai.new("?"),Mjai::Pai.new("?"),Mjai::Pai.new("?"),Mjai::Pai.new("?"),Mjai::Pai.new("?"),Mjai::Pai.new("?"),Mjai::Pai.new("?"),Mjai::Pai.new("?")],[Mjai::Pai.new("5mr"), Mjai::Pai.new("5m"), Mjai::Pai.new("7m"), Mjai::Pai.new("8m"), Mjai::Pai.new("9m"), Mjai::Pai.new("7s"), Mjai::Pai.new("7s")]],:tenpais=>[true,false,false,true],:deltas=>[1500,-1500,-1500,1500],:scores=>[37600,23900,4500,34000]})
        expected_action = JSON[{:type=>:ryukyoku,:reason=>:fonpai,:tehais=>[["1p", "2p", "3p", "3p", "4p", "5p", "C"],["?"]*13,["?"]*13,["5mr", "5m", "7m", "8m", "9m", "7s","7s"]],"tenpais"=>[true,false,false,true],"deltas"=>[1500,-1500,-1500,1500],"scores"=>[37600,23900,4500,34000]}]
        p action.to_json
        expect(action.to_json()).to eq expected_action
    end
    it "from_json" do
        action = JSON[{"type"=>"dahai", "actor"=>0, "pai"=>"1m", "tsumogiri"=>false}]
        expected_action = MjaiAction.new({:type=>:dahai, :actor=>0, :pai=>Mjai::Pai.new("1m"), :tsumogiri=>false})
        expect(MjaiAction._from_json(action)).to eq expected_action
    end
end