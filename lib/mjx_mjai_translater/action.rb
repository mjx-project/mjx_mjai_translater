require_relative "../../mjai/lib/mjai/jsonizable"

class MjaiAction < Mjai::JSONizable  # remove :player
    define_fields([
        [:type, :symbol],
        [:reason, :symbol],
        [:actor, :number],
        [:target, :number],
        [:pao, :number],
        [:pai, :pai],
        [:consumed, :pais],
        [:pais, :pais],
        [:tsumogiri, :boolean],
        [:possible_actions, :actions],
        [:cannot_dahai, :pais],
        [:id, :number],
        [:bakaze, :pai],
        [:kyoku, :number],
        [:honba, :number],
        [:kyotaku, :number],
        [:oya, :player],
        [:dora_marker, :pai],
        [:uradora_markers, :pais],
        [:tehais, :pais_list],
        [:uri, :string],
        [:names, :strings],
        [:hora_tehais, :pais],
        [:yakus, :yakus],
        [:fu, :number],
        [:fan, :number],
        [:hora_points, :number],
        [:tenpais, :booleans],
        [:deltas, :numbers],
        [:scores, :numbers],
        [:text, :string],
        [:message, :string],
        [:log, :string_or_null],
        [:logs, :strings_or_nulls],
      ])
end