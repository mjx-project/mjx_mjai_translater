require "./lib/mjx_mjai_translater/mjx_to_mjai"


RSpec.describe  MjxToMjai do  # tile変換のテスト
  it "protoの赤tileがmjaiのtileに変換できること" do
    expect(MjxToMjai.new().proto_tile_to_mjai_tile(16)).to eq "5mr"
  end
  it "protoの赤以外の数牌をmjaiのtileに変換できること" do
    expect(MjxToMjai.new().proto_tile_to_mjai_tile(17)).to eq "5m"
  end
  it "protoの字牌をmjaiのtileに変換できるか" do
    expect(MjxToMjai.new().proto_tile_to_mjai_tile(131)).to eq "F"
  end
end
