require './lib/mjx_mjai_translater/open_converter'

#テストケースは全てmjx/mjconvert/mjconvert/open_converter.pyのfileからとってきている


RSpec.describe "event_type" do
    it "ポン" do
        open_converter = OpenConverter.new(47723)
        expect(open_converter.open_event_type()).to eq "pon" 
    end
    it "チー" do
        open_converter = OpenConverter.new(49495)
        expect(open_converter.open_event_type()).to eq "chi" 
    end
    it "カカン" do
        open_converter = OpenConverter.new(28722)
        expect(open_converter.open_event_type()).to eq "kakan" 
    end
end


RSpec.describe "open_from" do   # 誰から鳴いたのか必要なのはpon chi daiminkanのみ
    it "対面" do
        open_converter = OpenConverter.new(51306)
        expect(open_converter.open_from()).to eq Mjxproto::RelativePos::RELATIVE_POS_MID
    end
    it "上家" do
        open_converter = OpenConverter.new(49495)
        expect(open_converter.open_from()).to eq Mjxproto::RelativePos::RELATIVE_POS_LEFT
    end
end


RSpec.describe "red" do
    it "has red" do
        open_converter = OpenConverter.new(52503)
        expect(open_converter.has_red()).to eq true
    end
    it "transform_red" do
        open_converter = OpenConverter.new(52503)
        expect(open_converter.transform_red_open([21, 22, 23], "chi")).to eq [21, 53, 23]
    end
end


RSpec.describe "open_stolen_tile_type" do
    it "1s" do
        open_converter = OpenConverter.new(28722)
        expect(open_converter.open_stolen_tile_type()).to eq 18
    end
    it "3s" do
        open_converter = OpenConverter.new(49495)
        expect(open_converter.open_stolen_tile_type()).to eq 20
    end
    it "C" do
        open_converter = OpenConverter.new(51306)
        expect(open_converter.open_stolen_tile_type()).to eq 33
    end
    it "P" do
        open_converter = OpenConverter.new(31744)
        expect(open_converter.open_stolen_tile_type()).to eq 31
    end
end



RSpec.describe "open_tile_types" do
    it "pon C" do
        open_converter = OpenConverter.new(51306)
        expect(open_converter.open_tile_types()).to eq [33, 33, 33]
    end
    it "chi 3s4s5s" do
        open_converter = OpenConverter.new(49495)
        expect(open_converter.open_tile_types()).to eq [20, 21, 22]
    end
    it "kakan 1s" do
        open_converter = OpenConverter.new(28722)
        expect(open_converter.open_tile_types()).to eq [18, 18, 18, 18]
    end
    it "ankan P" do
        open_converter = OpenConverter.new(31744)
        expect(open_converter.open_tile_types()).to eq [31, 31, 31, 31]
    end
end


RSpec.describe "open_to_mjai_tile" do  # openからmjaiのtileへの変換のテスト
    it "1s" do
        open_converter = OpenConverter.new(31744)
        expect(open_converter.open_to_mjai_tile(9)).to eq "1p"
    end
    it "5s" do
        open_converter = OpenConverter.new(31744)
        expect(open_converter.open_to_mjai_tile(22)).to eq "5s"
    end
    it "P" do
        open_converter = OpenConverter.new(31744)
        expect(open_converter.open_to_mjai_tile(31)).to eq "P"
    end
    it "red" do
        open_converter = OpenConverter.new(31744)
        expect(open_converter.open_to_mjai_tile(51)).to eq "5mr"
    end
end


RSpec.describe "mjai_stolen" do  # 鳴いた牌のmjaiのformatへの変換
    it "pon C" do
        open_converter = OpenConverter.new(51306)
        expect(open_converter.mjai_stolen()).to eq  "C"
    end
    it "chi 3s4s5s" do
        open_converter = OpenConverter.new(49495)
        expect(open_converter.mjai_stolen()).to eq  "3s"
   end
end


RSpec.describe "mjai_consumed" do # 晒した牌のmjaiのformatへの変換
     it "pon C" do
         open_converter = OpenConverter.new(51306)
         expect(open_converter.mjai_consumed()).to eq  ["C", "C"]
     end
     it "chi 3s4s5s" do
         open_converter = OpenConverter.new(49495)
         expect(open_converter.mjai_consumed()).to eq  ["4s", "5s"]
    end
end