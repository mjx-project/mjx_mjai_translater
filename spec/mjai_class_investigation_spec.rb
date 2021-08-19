require_relative "../mjai/lib/mjai/shanten_player"

RSpec.describe  "TransServer" do
    it "二つのクラスの比較" do
        shanten_player = Mjai::ShantenPlayer.new({:use_furo => true})
        tcp_player =  Mjai::TCPPlayer.new(nil, nil)
        expect(shanten_player == tcp_player).to eq true
    end
    
end