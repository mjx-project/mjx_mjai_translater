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
  end


  def proto_tile_to_mjai_tile(proto_tile)  # 他のクラスに
    reds_in_proto = [16, 52, 88]
    reds_dict = {16 => "5mr", 52 => "5sr", 88 => "5pr"}
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


  def mjx_event_to_mjai_action(event)
    if event.type == :EVENT_TYPE_DRAW
      return {"type"=>"tsumo","actor"=>@absolutepos_id_hash[event.who],"pai"=>"?"}  # ツモ牌 全て？で統一
    end
    if event.type == :EVENT_TYPE_DISCARD_FROM_HAND
      return {"type"=>"dahai", "actor"=>@absolutepos_id_hash[event.who], "pai"=>proto_tile_to_mjai_tile(event.tile), "tsumogiri"=>false}
    end
    if event.type == :EVENT_TYPE_DISCARD_DRAWN_TILE
      return {"type"=>"dahai", "actor"=>@absolutepos_id_hash[event.who], "pai"=>proto_tile_to_mjai_tile(event.tile), "tsumogiri"=>true}
    end 
    if event.type == :EVENT_TYPE_PON || event.type == :EVENT_TYPE_PON || event.type == :EVENT_TYPE_KAN_OPEND  # pon, chi, daiminkan
      open_converter = OpenConverter.new(event.open)
      type = open_converter.event_type()
      target = open_converter.open_from() # absolute_posを表すsymbol object
      stolen_tile = open_converter.stolen_tile()
      consumed_tile = open_converter.consumed_tile()
      return {"type"=>type, "actor"=>@absolutepos_id_hash[event.who], "target"=>@absolutepos_id_hash[target], "pai"=>stolen_tile, "consumed_tile"=>consumed_tile}
    end
    if event.type = :EVENT_TYPE_KAN_ADDED  # kakan
      type = open_converter.event_type()
      stolen_tile = open_converter.stolen_tile()
      consumed_tile = open_converter.consumed_tile()
      return {"type"=>type, "actor"=>@absolutepos_id_hash[event.who], "pai"=>stolen_tile, "consumed_tile"=>consumed_tile}
    end
    if event.type = :EVENT_TYPE_KAN_CLOSED  # ankan
      type = open_converter.event_type()
      consumed_tile = open_converter.consumed_tile()
      return {"type"=>type, "actor"=>@absolutepos_id_hash[event.who],"consumed_tile"=>consumed_tile}
    end
  end
end
