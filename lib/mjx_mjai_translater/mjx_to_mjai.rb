# possibleactionsをmjaiのactionのフォーマットに変換する
$LOAD_PATH.unshift(__dir__) unless $LOAD_PATH.include?(__dir__)
require "open_converter.rb"
this_dir = __dir__
lib_dir = File.join(this_dir, '../mjxproto')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)
require './lib/mjxproto/mjx/internal/mjx_pb'
require './lib/mjxproto/mjx/internal/mjx_services_pb'
require 'google/protobuf'
require "minitest"

include Minitest::Assertions


class MjxYakuToMjaiYaku
  def initialize()
    @mjai_yaku_list = [
      "menzenchin_tsumo",
      "reach",
      "ippatsu",
      "chankan",
      "rinshankaiho",
      "haiteiraoyue",
      "hoteiraoyue",
      "pinfu",
      "tanyaochu",
      "ipeko",
      "jikaze",
      "jikaze",
      "jikaze",
      "jikaze",
      "bakaze",
      "bakaze",
      "bakaze",
      "bakaze",
      "sangenpai",
      "sangenpai",
      "sangenpai",
      "double_reach",
      "chitoitsu",
      "honchantaiyao",
      "ikkitsukan",
      "sansyokudojun",
      "sanshokudoko",
      "sankantsu",
      "toitoiho",
      "sananko",
      "shosangen",
      "honroto",
      "ryanpeko",
      "junchantaiyao",
      "honiso",
      "chiniso",
      "renho",  # 天鳳は人和なし
      "tenho",
      "chiho",
      "daisangen",
      "suanko",
      "suanko",
      "tsuiso",
      "ryuiso",
      "chinroto",
      "churenpoton",
      "churenpoton",
      "kokushimuso",
      "kokushimuso",
      "daisushi",
      "shosushi",
      "sukantsu",
      "dora",
      "uradora",
      "akadora",
  ]
  end

  def mjai_yaku(mjx_yaku_idx)
    @mjai_yaku_list[mjx_yaku_idx]
  end
end


class MjxToMjai   #  mjxからmjaiへの変換関数をまとめる。　クラスじゃなくても良いかも
  attr_accessor :assertions
  def initialize(absolutepos_id)
    @absolutepos_id_hash = absolutepos_id
    @absolute_pos = [0,1,2, 3]
    self.assertions = 0
  end


  def proto_tile_to_mjai_tile(proto_tile)
    reds_in_proto = [16, 52, 88]
    reds_dict = {16 => "5mr", 52 => "5pr", 88 => "5sr"}
    mod36_kind_dict = {0 => "m", 1 => "p", 2 => "s"}
    num_zihai_dict = {0 => "E", 1 => "S", 2 => "W", 3 => "N", 4 => "P", 5 => "F", 6 => "C"}
    if reds_in_proto.include?(proto_tile)  # 赤
      return reds_dict[proto_tile]
    end
    if proto_tile.div(36) <= 2  #数牌
      return ((proto_tile % 36 ).div(4) + 1).to_i.to_s + mod36_kind_dict[proto_tile.div(36)]
    end
    return num_zihai_dict[(proto_tile % 36).div(4)]  #字牌
  end


  def proto_tiles_to_mjai_tiles(proto_tiles)
    mjai_tiles = []
    proto_tiles.length.times do |i|
      mjai_tiles.push(proto_tile_to_mjai_tile(proto_tiles[i]))
    end
    return mjai_tiles
  end


  def mjx_event_to_mjai_action(event, observation, players)  # observationはreach_accepted, ron tsumoの時しか使わない。
    if event.type == :EVENT_TYPE_DRAW
      return {"type"=>"tsumo","actor"=>@absolutepos_id_hash[event.who],"pai"=>"?"}  # ツモ牌 全て？で統一
    end
    if event.type == :EVENT_TYPE_DISCARD
      return {"type"=>"dahai", "actor"=>@absolutepos_id_hash[event.who], "pai"=>proto_tile_to_mjai_tile(event.tile), "tsumogiri"=>false}
    end
    if event.type == :EVENT_TYPE_TSUMOGIRI
      return {"type"=>"dahai", "actor"=>@absolutepos_id_hash[event.who], "pai"=>proto_tile_to_mjai_tile(event.tile), "tsumogiri"=>true}
    end 
    if event.type == :EVENT_TYPE_CHI || event.type == :EVENT_TYPE_PON || event.type == :EVENT_TYPE_OPEN_KAN  # pon, chi, daiminkan
      open_converter = OpenConverter.new(event.open)
      type = open_converter.open_event_type()
      current_pos = event.who
      pos_index = @absolute_pos.find_index(current_pos)
      relative_pos = open_converter.open_from()
      target_index = (pos_index + relative_pos) % 4
      target = @absolute_pos[target_index] # absolute_posを表すsymbol object
      stolen_tile = open_converter.mjai_stolen()
      consumed_tile = open_converter.mjai_consumed()
      return {"type"=>type, "actor"=>@absolutepos_id_hash[event.who], "target"=>@absolutepos_id_hash[target], "pai"=>stolen_tile, "consumed"=>consumed_tile}
    end
    if event.type == :EVENT_TYPE_ADDED_KAN  # kakan
      open_converter = OpenConverter.new(event.open)
      type = open_converter.open_event_type()
      stolen_tile = open_converter.mjai_stolen()
      consumed_tile = open_converter.mjai_consumed()
      return {"type"=>type, "actor"=>@absolutepos_id_hash[event.who], "pai"=>stolen_tile, "consumed"=>consumed_tile}
    end
    if event.type == :EVENT_TYPE_CLOSED_KAN  # ankan
      open_converter = OpenConverter.new(event.open)
      type = open_converter.open_event_type()
      consumed_tile = open_converter.mjai_consumed()
      return {"type"=>type, "actor"=>@absolutepos_id_hash[event.who],"consumed"=>consumed_tile}
    end
    if event.type == :EVENT_TYPE_NEW_DORA
      return{"type"=>"dora", "dora_marker"=>proto_tile_to_mjai_tile(event.tile)}
    end
    if event.type == :EVENT_TYPE_RIICHI
      return {"type"=>"reach", "actor"=>@absolutepos_id_hash[event.who]}
    end
    if event.type == :EVENT_TYPE_RIICHI_SCORE_CHANGE
        ten_change = [0,0,0,0]
        pos_index = @absolute_pos.find_index(event.who)
        ten_change[pos_index] = -1000
        scores = observation.public_observation.init_score.tens
        scores[pos_index] -= 1000
        return  {"type"=>"reach_accepted","actor"=>@absolutepos_id_hash[event.who], "deltas"=>ten_change, "scores"=>scores}
    end
    if observation.round_terminal != nil
      assert_types = [:EVENT_TYPE_RON, :EVENT_TYPE_TSUMO]
      assert_includes assert_types, event.type
      return mjx_win_terminal_to_mjai_action(observation)
    end
  end

  def mjx_act_to_mjai_act(mjx_act, public_observatoin) 
    # この関数はtrans_serverの内部で実行されるのでprevious_historyは問題なく手に入る 
    #　またこの関数が実行される際には@_mjx_public_observatoinが最新のものに更新されているので欲しいactionが含まれていないという心配もない
    action_type = mjx_act.type
    who = mjx_act.who
    if action_type == :ACTION_TYPE_DISCARD #新しいprotoを待つ
      tile = mjx_act.tile
      return {"type"=>"dahai", "actor"=>@absolutepos_id_hash[who], "pai"=>proto_tile_to_mjai_tile(tile), "tsumogiri"=>false}
    end
    if action_type == :ACTION_TYPE_TSUMOGIRI
      tile = mjx_act.tile
      return {"type"=>"dahai", "actor"=>@absolutepos_id_hash[who], "pai"=>proto_tile_to_mjai_tile(tile), "tsumogiri"=>true}
    end
    if action_type == :ACTION_TYPE_CHI || action_type == :ACTION_TYPE_PON || action_type == :ACTION_TYPE_OPEN_KAN
      open_converter = OpenConverter.new(mjx_act.open)
      type = open_converter.open_event_type()
      current_pos = who
      pos_index = @absolute_pos.find_index(current_pos)
      relative_pos = open_converter.open_from()
      target_index = (pos_index + relative_pos) % 4
      target = @absolute_pos[target_index] # absolute_posを表すsymbol object
      stolen_tile = open_converter.mjai_stolen()
      consumed_tile = open_converter.mjai_consumed()
      return {"type"=>type, "actor"=>@absolutepos_id_hash[who], "target"=>@absolutepos_id_hash[target], "pai"=>stolen_tile, "consumed"=>consumed_tile}
    end
    if action_type == :ACTION_TYPE_ADDED_KAN  # kakan
      open_converter = OpenConverter.new(mjx_act.open)
      type = open_converter.open_event_type()
      stolen_tile = open_converter.mjai_stolen()
      consumed_tile = open_converter.mjai_consumed()
      return {"type"=>type, "actor"=>@absolutepos_id_hash[who], "pai"=>stolen_tile, "consumed"=>consumed_tile}
    end
    if action_type == :ACTION_TYPE_CLOSED_KAN  # ankan
      open_converter = OpenConverter.new(mjx_act.open)
      type = open_converter.open_event_type()
      consumed_tile = open_converter.mjai_consumed()
      return {"type"=>type, "actor"=>@absolutepos_id_hash[who],"consumed"=>consumed_tile}
    end
    if action_type == :ACTION_TYPE_RIICHI
      return {"type"=>"reach", "actor"=>@absolutepos_id_hash[who]}
    end
    if action_type == :ACTION_TYPE_RON || action_type == :ACTION_TYPE_TSUMO # trans_serverが持っている previous_public_observatoinの情報を使う
      last_event = public_observatoin[-1]
      assert_types = [:EVENT_TYPE_TSUMOGIRI, :EVENT_TYPE_DISCARD, :EVENT_TYPE_DRAW, :EVENT_TYPE_ADDED_KAN]
      assert_includes assert_types, last_event.type
      target = last_event.who
      hora_tile = mjx_act.tile
      return {"type"=>"hora","actor"=>@absolutepos_id_hash[who],"target"=>@absolutepos_id_hash[target],"pai"=>proto_tile_to_mjai_tile(hora_tile)}
    end
    if action_type == :ACTION_TYPE_NO
      return {"type"=>"none"}
    end
  end


  def mjx_terminal_to_mjai_action(event, observation)
    terminal_info = observation.round_terminal.wins
    if terminal_info != nil
      return mjx_win_terminal_to_mjai_action(observation)
    end

  end


  def mjx_no_win_terminal_to_mjai_action(event, observation)
    return nil
  end

  def _terminal_hand(terminal_info)
    tenpais = terminal_info.no_winner.tenpais
    
  end

  def mjx_win_terminal_to_mjai_action(observation)  # winnerがいる場合
    terminal_info = observation.round_terminal.wins[0]
    final_score = observation.round_terminal.final_score.tens
    who = terminal_info.who
    from_who = terminal_info.from_who
    hand = terminal_info.hand.closed_tiles
    win_tile = terminal_info.win_tile
    fu = terminal_info.fu
    fans = terminal_info.fans
    ten = terminal_info.ten
    ten_changes = terminal_info.ten_changes
    yakus = terminal_info.yakus
    yakumans = terminal_info.yakumans
    ura_dora_indicators = terminal_info.ura_dora_indicators
    return {"type"=>"hora","actor"=>@absolutepos_id_hash[who],"target"=>@absolutepos_id_hash[from_who],"pai"=>proto_tile_to_mjai_tile(win_tile),"uradora_markers"=>proto_tiles_to_mjai_tiles(ura_dora_indicators),"hora_tehais"=>proto_tiles_to_mjai_tiles(hand),
    "yakus"=>_to_mjai_yakus(fans, yakus, yakumans),"fu"=>fu,"fan"=>fans.sum(),"hora_points"=>ten,"deltas"=>ten_changes,"scores"=>final_score}
  end

  def _to_mjai_yakus(fans, mjx_yakus, mjx_yakumans)
    mjai_yakus = []
    mjx_yaku_to_mjai_yaku = MjxYakuToMjaiYaku.new()
    if mjx_yakumans.length >0  # 役満の時
      mjx_yakumans.length.times do |i|
        mjx_yakuman_idx = mjx_yakumans[i]  # mjxでは役は数字で定義されている。
        mjai_yakumans = mjx_yaku_to_mjai_yaku.mjai_yaku(mjx_yakuman_idx)
        mjai_yakus.push([mjai_yaku,1])
        return mjai_yaku
      end
    end
    fans.length.times do |i|
      fan = fans[i]
      mjx_yaku_idx = mjx_yakus[i]
      mjai_yaku = mjx_yaku_to_mjai_yaku.mjai_yaku(mjx_yaku_idx)
      if fan>0
        mjai_yakus.push([mjai_yaku, fan])
      end
    end
    return mjai_yakus
  end
end