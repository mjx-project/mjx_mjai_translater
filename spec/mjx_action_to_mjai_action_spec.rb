require "./lib/mjx_mjai_translater/mjx_to_mjai"


RSpec.describe  MjxToMjai do  # tile変換のテスト
  it "protoの赤tileがmjaiのtileに変換できること" do
    expect(MjxToMjai.new({}).proto_tile_to_mjai_tile(16)).to eq "5mr"
  end
  it "protoの赤以外の数牌をmjaiのtileに変換できること" do
    expect(MjxToMjai.new({}).proto_tile_to_mjai_tile(17)).to eq "5m"
  end
  it "protoの字牌をmjaiのtileに変換できるか" do
    expect(MjxToMjai.new({}).proto_tile_to_mjai_tile(131)).to eq "F"
  end
  it "protoの字牌をmjaiのtileに変換できるか" do
    expect(MjxToMjai.new({}).proto_tile_to_mjai_tile(121)).to eq "N"
  end
end

RSpec.describe  MjxToMjai do
  it "打牌" do
  end
  it "チー" do
  end
  it "ポン" do
  end
  it "カカン" do
  end
  it "ダイミンカン" do 
  end
  it "アンカン" do
  end
  it "リーチ" do
  end
  it "ロン" do
  end
  it "ツモ" do
  end
  it "no" do
  end
end
