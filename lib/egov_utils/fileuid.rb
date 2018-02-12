module EgovUtils
  class Fileuid

    Snippet = Struct.new(:name, :type, :length, :mandatory) do

      def mandatory?
        mandatory.nil? ? true : mandatory
      end

      def static?
        type == :static
      end

      def type_to_regex_part
        case type
        when String
          type
        when :integer
          "\\d"
        when :word
          "\\w"
        when :static
          name
        else
          raise "Unsuported fileuid snippet type #{type}"
        end
      end

      def length_to_regex_part
        case length
        when 1, nil
          ''
        when :any
          mandatory? ? "+" : "*"
        when Array
          "{#{length[0]},#{length[1]}}"
        when Numeric
          "{#{length}}"
        else
          length
        end
      end

      def to_regex_s
        type_to_regex_part + length_to_regex_part
      end
    end

    class Type
      attr_reader :snippets

      def initialize(*attrs)
        @snippets = attrs
      end

      def snippet_names
        snippets.select{|s| !s.static? }.collect{|s| s.name}
      end

      def validate!
        raise "Snippet names for file uid type has to be uniq!" unless snippet_names.length == snippet_names.uniq.length
      end

      def to_regex_s
        snippets.collect{|s| (s.type == :static ? s.to_regex_s : "(#{s.to_regex_s})") }.join()
      end

      def to_regex
        /\A#{to_regex_s}\z/
      end

      def file_uid_to_s(fileuid)
        snippets.collect{|snippet| snippet.static? ? snippet.name : fileuid.public_send(snippet.name) }.join
      end

    end

    DASH_SNIPPET        = Snippet.new('-', :static)
    SLASH_SNIPPET       = Snippet.new('/', :static)
    BC_SNIPPET          = Snippet.new('bc', :integer, :any)
    YEAR_SNIPPET        = Snippet.new('year', :integer, 4)
    REGISTER_SNIPPET    = Snippet.new('agenda', '[-a-zA-Z]', [1,10])
    COURT_AGEND_SNIPPET = Snippet.new('agenda', :word, [1,4])
    COURT_SENAT_SNIPPET = Snippet.new('senat', :integer, :any)

    TYPES = {
      'court' => Type.new(COURT_SENAT_SNIPPET, DASH_SNIPPET, COURT_AGEND_SNIPPET, DASH_SNIPPET, BC_SNIPPET, SLASH_SNIPPET, YEAR_SNIPPET),
      'msp'   => Type.new(BC_SNIPPET, SLASH_SNIPPET, YEAR_SNIPPET, DASH_SNIPPET, REGISTER_SNIPPET)
    }

    # Used for `serialize` method in ActiveRecord
    class Coder

      def initialize(attr_name, type)
        @attr_name = attr_name
        @type = type
      end

      def dump(obj)
        return if obj.nil?
        obj = Fileuid.new(obj, type: @type) if obj.is_a?(String)
        unless obj.is_a?(Fileuid)
          raise ::ActiveRecord::SerializationTypeMismatch,
            "Attribute was supposed to be a #{self}, but was a #{obj.class}. -- #{obj.inspect}"
        end
        obj.to_s
      end

      def load(source)
        Fileuid.new(source)
      end
    end

    AVAILABLE_ATTRIBUTES = [:bc, :agenda, :senat, :year, :document_number]

    attr_accessor *AVAILABLE_ATTRIBUTES

    def ==(other)
      other.is_a?(Fileuid) && AVAILABLE_ATTRIBUTES.all?{|a| self.public_send(a) == other.public_send(a) }
    end

    def type
      @type ||= @options['type']
    end

    def type_definition
      TYPES[type]
    end

    def invalid?
      !type || @invalid
    end

    def initialize(str_val, **options)
      @options = options.stringify_keys
      @str_val = str_val
      parse_str!(str_val) if str_val.is_a?(String)
    end

    def parse_str!(str_val, type=self.type)
      type ||= determine_type(str_val)
      @type = type
      return if invalid?
      match_data = str_val.match(type_definition.to_regex)
      if match_data
        type_definition.snippet_names.each_with_index{|s_name, idx| self.send(s_name+'=', match_data[idx+1]) }
      else
        @invalid = true
      end
    end

    def determine_type(str_val)
      TYPES.each do |k, type|
        return k if str_val =~ type.to_regex
      end
      nil
    end

    def as_json(**options)
      invalid? ? nil : to_s
    end

    def to_s
      if invalid?
        @str_val.to_s
      else
        type_definition.file_uid_to_s(self)
      end
    end

  end
end
