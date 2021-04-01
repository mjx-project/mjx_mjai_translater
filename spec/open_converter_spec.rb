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