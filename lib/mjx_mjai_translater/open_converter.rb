this_dir = __dir__
lib_dir = File.join(this_dir, '../mjxproto')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)
require_relative '../mjxproto/mjx/internal/mjx_pb'
require_relative '../mjxproto/mjx/internal/mjx_services_pb'
require 'google/protobuf'

class RelativePos

    def _self()
        return 0
    end

    def right()
        return 1
    end

    def mid()
        return 2
    end

    def left()
        return 3
    end
end


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


  def open_event_type()  # eventのtype
    relative_pos = RelativePos.new()
    if (1 << 2 & @bits) != 0  # rubyでは0はfalseを意味しない
      return :chi
    elsif 1 << 3 & @bits != 0
      return :pon
    elsif 1 << 4 & @bits != 0
      return :kakan
    else
      if relative_pos._self() == @bits & 3
          return :ankan
      else
          return :daiminkan
      end
    end
  end


  def open_from()  # 誰から鳴いたか
    relative_pos = RelativePos.new()
    event_type = open_event_type()
    if event_type == :chi
        return relative_pos.left()
    elsif event_type == :pon or event_type == :daiminkan  or event_type == :kakan
        return @bits & 3 # ポンチーダイミンカンの場合はrelativeposは3通り
    else
        return relative_pos._self()
    end
  end


  def _min_tile_chi()
    x = (@bits >> 10).div(3)  # 0~21
    min_tile = (x.div(7)) * 9 + x % 7  # 0~33 base 9
    return min_tile
  end


  def is_stolen_red(stolen_tile_kind)
      fives = [4, 13, 22]
      reds = [14, 52, 88]
      event_type = open_event_type()
      if !fives.include?(stolen_tile_kind)
          return false
      end
      if event_type == :chi
          stolen_tile_mod3 = (@bits >> 10) % 3  # 鳴いた牌のindex
          stolen_tile_id_mod4 = (@bits >> (3 + 2 * stolen_tile_mod3)) % 4  # 鳴いた牌のi
          return stolen_tile_id_mod4 == 0  # 鳴いた牌のid mod 4=0→赤
      elsif event_type == :pon || event_type == :kakan
          unused_id_mod4 = (@bits >> 5) % 4  # 未使用牌のid mod 4
          stolen_tile_mod3 = (@bits >> 9) % 3  # 鳴いた牌のindex
          return unused_id_mod4 != 0 && stolen_tile_mod3 == 0  # 未使用牌が赤でなく、鳴いた牌のインデックスが0の時→赤
      else
          return reds.include?((@bits >> 8))
      end
    end


  def is_unused_red()
      unused_id_mod4 = (@bits >> 5) % 4
      return unused_id_mod4 == 0
  end


  def has_red_chi()  # chiが赤を持っているか
      min_starts_include5_mod9 = [2, 3, 4]
      min_tile = _min_tile_chi()
      if !min_starts_include5_mod9.include?(min_tile % 9)
          false
      else
          start_from3 = min_tile % 9 == 2  # min_tile で場合分け
          start_from4 = min_tile % 9 == 3
          start_from5 = min_tile % 9 == 4
          if start_from3  # 3から始まる→3番目の牌のid mod 4 =0 →赤
              return (@bits >> 7) % 4 == 0
          elsif start_from4
              return (@bits >> 5) % 4 == 0
          elsif start_from5
              return (@bits >> 3) % 4 == 0
          else
              assert false
          end
      end
  end


  def has_red_pon_kan_added()  # ponが赤を持っているか
      fives = [4, 13, 22, 51, 52, 53]
      stolen_tile_kind = open_stolen_tile_type()
      if fives.include?(stolen_tile_kind)
          unused_id_mod4 = (@bits >> 5) % 4
          return unused_id_mod4 != 0
      else
          return false
      end
  end


  def has_red_kan_closed_kan_opend()
      fives = [4, 13, 22, 51, 52, 53]
      stolen_tile_kind = open_stolen_tile_type()
      return fives.include?(stolen_tile_kind)
  end


  def has_red()  # 赤を持っているか
    event_type = open_event_type()
    if event_type == :chi
        return has_red_chi()
    elsif event_type == :pon or event_type == :kakan
        return has_red_pon_kan_added()
    else
        return has_red_kan_closed_kan_opend()  # ダイミンカンとアンカンは必ず赤を含む
    end
end


  def transform_red_stolen(stolen_tile) 
      red_dict = { 4=> 51, 13=> 52, 22=> 53 } # openの5:mjscoreの赤５
      if is_stolen_red(stolen_tile)
          return red_dict[stolen_tile]
      else
          return stolen_tile
      end
  end


  def replace_array_by_hash(array_, hash_)
    hash_.keys.each do |key|
        if array_.include?(key)
            array_[array_.find_index(key)] = hash_[key]
        end
    end
    return array_
  end


  def transform_red_open(open, event_type)
      red_dict = { 4=>51, 13=>52, 22=>53 }
      fives = [4, 13, 22]
      if !has_red()
          return open
      end
      if event_type == :chi
          return replace_array_by_hash(open, red_dict)
      else
          open[-1] = red_dict[open[-1]]
          return open
      end
  end
  


  def open_stolen_tile_type()  # 鳴いた牌
      event_type = open_event_type()
      if event_type == :chi
          min_tile = _min_tile_chi()
          stolen_tile_kind = min_tile + (@bits >> 10) % 3
          return transform_red_stolen(stolen_tile_kind)
      elsif event_type == :pon or event_type == :kakan
          stolen_tile_kind = (@bits >> 9).div(3)
          return transform_red_stolen(stolen_tile_kind)
      else
          stolen_tile_kind = (@bits >> 8).div(4)
          return transform_red_stolen(stolen_tile_kind)
      end
  end


  def open_tile_types() # 鳴いた牌全ての情報
    reds = [51, 52, 53]
    red_five_dict = { 51=>4, 52=>13, 53=>22 }
    event_type = open_event_type()
    if event_type == :chi
        min_tile = _min_tile_chi()
        open = [min_tile, min_tile + 1, min_tile + 2]
        return transform_red_open(open, event_type)
    end
    stolen_tile_kind = open_stolen_tile_type()
    if reds.include?(stolen_tile_kind)  # 赤だった場合はopenのformatに置換しないと、複数の同じ赤を持ったopenが生成される。
        stolen_tile_kind = red_five_dict[stolen_tile_kind]
    else
        nil
    end
    if event_type == :pon
        open = [stolen_tile_kind] * 3
        return transform_red_open(open, event_type)
    else
        open = [stolen_tile_kind] * 4
        return transform_red_open(open, event_type)
    end
  end


  def open_to_mjai_tile(open)  # openをmjai_tileに変換する。
    open_red_mjai_tile_dict = {51=>"5mr", 52=>"5pr", 53=>"5sr"}
    mod9_kind_dict = {0 => "m", 1 => "p", 2 => "s"}
    num_zihai_dict = {0 => "E", 1 => "S", 2 => "W", 3 => "N", 4 => "P", 5 => "F", 6 => "C"}
    if open_red_mjai_tile_dict.include?(open)
        return Mjai::Pai.new(open_red_mjai_tile_dict[open])
    end
    if open.div(9) <= 2
        return Mjai::Pai.new(((open % 9) + 1).to_i.to_s + mod9_kind_dict[open.div(9)])
    end
    return Mjai::Pai.new(num_zihai_dict[open % 9])
  end 


  def mjai_stolen()  # 鳴いたはいをmjaiのformatで返すtrans_serverへのinterface
    open_stolen_tile = open_stolen_tile_type()
    mjai_tile = open_to_mjai_tile(open_stolen_tile)
    return mjai_tile
  end


  def mjai_consumed()  # 晒した牌
    open_stolen_tile = open_stolen_tile_type()
    open_tiles = open_tile_types()
    event_type = open_event_type()
    if event_type == :ankan
        return open_tiles.map {|x| open_to_mjai_tile(x)}
    elsif is_stolen_red(open_stolen_tile) || event_type == :chi
        open_tiles.delete(open_stolen_tile)  # 鳴いたはいを削除する。
        consumed_tiles = open_tiles.map {|x| open_to_mjai_tile(x)}
        return consumed_tiles
    else
        consumed_tiles = open_tiles[1..-1].map {|x| open_to_mjai_tile(x)} # pon, kanは晒した牌に赤があってもopenの最初のを除けば良い:赤は最後にくる
        return consumed_tiles
    end
  end
end


