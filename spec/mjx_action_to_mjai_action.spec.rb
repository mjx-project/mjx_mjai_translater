require_relative "../lib/mjx_mjai_translater/mjx_action_to_mjai_action"


RSpec.describe  MjxActToMjaiAct do
  it "protoの赤tileがmjaiのtileに変換できること" do
    expect(MjxActToMjaiAct.new({}).proto_tile_to_mjai_tile(16)).to eq "5mr"
  end
  it "protoの赤以外の数牌をmjaiのtileに変換できること" do
    expect(MjxActToMjaiAct.new({}).proto_tile_to_mjai_tile(17)).to eq "5m"
  end
  it "protoの字牌をmjaiのtileに変換できるか" do
    expect(MjxActToMjaiAct.new({}).proto_tile_to_mjai_tile(131)).to eq "F"
  end
end
