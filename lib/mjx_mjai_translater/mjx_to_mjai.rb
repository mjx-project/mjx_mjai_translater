# possibleactionsをmjaiのactionのフォーマットに変換する
$LOAD_PATH.unshift(__dir__) unless $LOAD_PATH.include?(__dir__)
require "open_converter.rb"
this_dir = __dir__
lib_dir = File.join(this_dir, '../mjxproto')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)
require 'mjx_pb'
require 'mjx_services_pb'
require 'google/protobuf'


class MjxToMjai   #  mjxからmjaiへの変換関数をまとめる。　クラスじゃなくても良いかも

  def initialize(absolutepos_id)
    @absolutepos_id_hash = absolutepos_id
    @absolute_pos = [:ABSOLUTE_POS_INIT_EAST,:ABSOLUTE_POS_INIT_SOUTH,
    :ABSOLUTE_POS_INIT_WEST, :ABSOLUTE_POS_INIT_NORTH]
  end


  def proto_tile_to_mjai_tile(proto_tile)  # 他のクラスに
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


  def mjx_event_to_mjai_action(event,scores)  # observationはreach_accepted, ron tsumoの時しか使わない。
    if event.type == :EVENT_TYPE_DRAW
      return {"type"=>"tsumo","actor"=>@absolutepos_id_hash[event.who],"pai"=>"?"}  # ツモ牌 全て？で統一
    end
    if event.type == :EVENT_TYPE_DISCARD_FROM_HAND
      return {"type"=>"dahai", "actor"=>@absolutepos_id_hash[event.who], "pai"=>proto_tile_to_mjai_tile(event.tile), "tsumogiri"=>false}
    end
    if event.type == :EVENT_TYPE_DISCARD_DRAWN_TILE
      return {"type"=>"dahai", "actor"=>@absolutepos_id_hash[event.who], "pai"=>proto_tile_to_mjai_tile(event.tile), "tsumogiri"=>true}
    end 
    if event.type == :EVENT_TYPE_CHI || event.type == :EVENT_TYPE_PON || event.type == :EVENT_TYPE_KAN_OPEND  # pon, chi, daiminkan
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
    if event.type == :EVENT_TYPE_KAN_ADDED  # kakan
      open_converter = OpenConverter.new(event.open)
      type = open_converter.open_event_type()
      stolen_tile = open_converter.mjai_stolen()
      return {"type"=>type, "actor"=>@absolutepos_id_hash[event.who], "pai"=>stolen_tile, "consumed"=>consumed_tile}
    end
    if event.type == :EVENT_TYPE_KAN_CLOSED  # ankan
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
        scores[pos_index] -= 1000
        return  {"type"=>"reach_accepted","actor"=>@absolutepos_id_hash[event.who], "deltas"=>ten_change, "scoers"=>scores}
    end
  end
end

a = MjxToMjai.new({})
p a.proto_tile_to_mjai_tile(121)