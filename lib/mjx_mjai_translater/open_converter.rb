class OpenConverter
  def initialize(open)
    @bits = open
  end
#必要な情報
# ポン,チー,ダイミンカン 
# target: 誰から鳴いたか
# pai: 何を鳴いたか
# consumed: 晒した牌 
# カカン
# pai: 何を鳴いたか
# consumed: 晒した牌 
# アンカン
# consumed: 晒した牌


  def open_event_type()  # rubyでは0はfalseを意味しない
    if (1 << 2 & @bits) != 0
      return "chi"
    elsif 1 << 3 & @bits != 0
      return "pon"
    elsif 1 << 4 & @bits != 0
      return "kakan"
    else
      if Mjxproto::RelativePos::RELATIVE_POS_SELF == @bits & 3
          return "ankan"
      else
          return "daiminkan"
      end
    end
  end


  def open_from()
    p Mjxproto::RelativePos::RELATIVE_POS_LEFT
    event_type = open_event_type()
    if event_type == "chi"
        return Mjxproto::RelativePos::RELATIVE_POS_LEFT
    elsif event_type == "pon" or event_type == "daiminkan"  or event_type == "kakan"
        return @bits & 3 # ポンチーダイミンカンの場合はrelativeposは3通り
    else
        return Mjxproto::RelativePos::RELATIVE_POS_SELF
    end
  end


  def open_stolen_tile(open)
  end
  
  
  def open_tiles(open)
  end

end
