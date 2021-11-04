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
        [:oya, :number],
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

      def self._from_json(json)
        plain = JSON.parse(json)
        begin
          return _from_plain(plain, nil)
        rescue ValidationError => ex
          raise(ValidationError, "%s JSON: %s" % [ex.message, json])
        end
      end

      def self._from_plain(plain, name)
        validate(plain.is_a?(Hash), "%s must be an object." % (name || "The response"))
        fields = {}
        for field_name, type in @@field_specs
          field_plain = plain[field_name.to_s()]
          next if field_plain == nil
          fields[field_name] = _plain_to_obj(
              field_plain, type, name ? "#{name}.#{field_name}" : field_name.to_s())
        end
        return new(fields)
      end
      
      def self._plain_to_obj(plain, type, name)
        case type
          when :number
            validate_class(plain, Integer, name)
            return plain
          when :string
            validate_class(plain, String, name)
            return plain
          when :string_or_null
            validate(plain.is_a?(String) || plain == nil, "#{name} must be String or null.")
            return plain
          when :boolean
            validate(
                plain.is_a?(TrueClass) || plain.is_a?(FalseClass),
                "#{name} must be either true or false.")
            return plain
          when :symbol
            validate_class(plain, String, name)
            validate(!plain.empty?, "#{name} must not be empty.")
            return plain.intern()
          when :player
            validate_class(plain, Integer, name)
            validate((0...4).include?(plain), "#{name} must be either 0, 1, 2 or 3.")
            return plain
          when :pai
            validate_class(plain, String, name)
            begin
              return Mjai::Pai.new(plain)
            rescue ArgumentError => ex
              raise(ValidationError, "Error in %s: %s" % [name, ex.message])
            end
          when :yaku
            validate_class(plain, Array, name)
            validate(
                plain.size == 2 && plain[0].is_a?(String) && plain[1].is_a?(Integer),
                "#{name} must be an array of [String, Integer].")
            validate(!plain[0].empty?, "#{name}[0] must not be empty.")
            return [plain[0].intern(), plain[1]]
          when :action
            return _from_plain(plain, name)
          when :numbers
            return _plains_to_objs(plain, :number, name)
          when :strings
            return _plains_to_objs(plain, :string, name)
          when :strings_or_nulls
            return _plains_to_objs(plain, :string_or_null, name)
          when :booleans
            return _plains_to_objs(plain, :boolean, name)
          when :symbols
            return _plains_to_objs(plain, :symbol, name)
          when :pais
            return _plains_to_objs(plain, :pai, name)
          when :pais_list
            return _plains_to_objs(plain, :pais, name)
          when :yakus
            return _plains_to_objs(plain, :yaku, name)
          when :actions
            return _plains_to_objs(plain, :action, name)
          else
            raise("unknown type")
        end
      end
      
      def _plains_to_objs(plains, type, name)
        validate_class(plains, Array, name)
        return plains.each_with_index().map() do |c, i|
          plain_to_obj(c, type, "#{name}[#{i}]")
        end
      end
      
end