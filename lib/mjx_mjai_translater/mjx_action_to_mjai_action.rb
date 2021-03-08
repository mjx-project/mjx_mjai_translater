# possibleactionsをmjaiのactionのフォーマットに変換する
#require "./open_converter.rb"


class MjxActToMjaiAct

  def initialize(proto_possible_actions)
    @proto_acitons = proto_possible_actions
  end


  def proto_tile_to_mjai_tile(proto_tile)  # 他のクラスに
    reds_in_proto = [16, 52, 88]
    reds_dict = {16 => "5mr", 52 => "5sr", 88 => "5pr"}
    if reds_in_proto.include?(proto_tile)
      return reds_dict[proto_tile]
    end
  end
end
