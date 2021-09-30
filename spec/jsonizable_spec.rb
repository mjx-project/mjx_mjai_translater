require './lib/mjx_mjai_translater/action'
require 'json'


RSpec.describe "between action and json" do
    it "to_json" do
        action = MjaiAction.new({:type=>:dahai, :actor=>0, :pai=>Mjai::Pai.new("1m"), :tsumogiri=>false})
        expected_action = JSON[{"type"=>"dahai", "actor"=>0, "pai"=>"1m", "tsumogiri"=>false}]
        expect(action.to_json()).to eq expected_action
    end
    it "from_json" do
        action = JSON[{"type"=>"dahai", "actor"=>0, "pai"=>"1m", "tsumogiri"=>false}]
        expected_action = MjaiAction.new({:type=>:dahai, :actor=>0, :pai=>Mjai::Pai.new("1m"), :tsumogiri=>false})
        expect(MjaiAction.from_json(action)).to eq expected_action
    end
end