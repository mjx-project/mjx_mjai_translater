require "../lib/mjx_mjai_translater/mjx_action_to_mjai_action"


Rspec.describe  MjxActToMjaiAct do
  it "protoのtileがmjaiのtileに変換できること" do
    expect(MjxActToMjaiAct.new({}).proto_tile_to_mjai_tile(16)).to eq "5mr"
  end
end
