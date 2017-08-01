module EgovUtils

  class AuthSourceException < Exception; end
  class AuthSourceTimeoutException < AuthSourceException; end

  class AuthSource

    NETWORK_EXCEPTIONS = [
      Net::LDAP::LdapError,
      Errno::ECONNABORTED, Errno::ECONNREFUSED, Errno::ECONNRESET,
      Errno::EHOSTDOWN, Errno::EHOSTUNREACH,
      SocketError
    ]

    def self.config
      YAML.load_file(Rails.root.join('config', 'config.yml'))['ldap']
    end

    def self.providers
      config.keys
    end

    def self.authenticate(login, password)
      providers.collect{|p| AuthSource.new(p).get_user_dn(login, password) }.compact.first
    end

    attr_accessor :provider

    def initialize(provider)
      require 'net-ldap'
      @provider = provider
    end

    def options
      @options ||= self.class.config[provider].dup
    end

    def host
      options['host']
    end

    def port
      options['port']
    end

    def encryption
      case options['method'].to_s
      when 'ssl'
        :simple_tls
      when 'tls'
        :start_tls
      else
        nil
      end
    end

    def authenticate(login, password)
      return nil if login.blank? || password.blank?

      with_timeout do
        attrs = get_user_dn(login, password)
        if attrs && attrs[:dn] && authenticate_dn(attrs[:dn], password)
          Rails.logger.debug "Authentication successful for '#{login}'" if Rails.logger && Rails.logger.debug?
          return attrs.except(:dn)
        end
      end
    rescue *NETWORK_EXCEPTIONS => e
      raise AuthSourceException.new(e.message)
    end

    def base_filter
      Net::LDAP::Filter.eq("objectClass", "*")
    end

    # Check if a DN (user record) authenticates with the password
    def authenticate_dn(dn, password)
      if dn.present? && password.present?
        initialize_ldap_con(dn, password).bind
      end
    end

    # Searches the source for users and returns an array of results
    def search(q, by_login=false)
      q = q.to_s.strip
      return [] unless q.present?

      results = []
      search_filter = base_filter & user_search_filters(q)
      ldap_con = initialize_ldap_con(options['bind_dn'], options['password'])
      ldap_con.search(:base => options['base'],
                      :filter => search_filter,
                      :attributes => search_attributes,
                      :size => 10) do |entry|
        pp entry
        attrs = get_user_attributes_from_ldap_entry(entry)
        if attrs
          attrs[:login] = get_attr(entry, options['attributes']['username'])
          results << attrs
        end
      end
      results
    rescue *NETWORK_EXCEPTIONS => e
      raise AuthSourceException.new(e.message)
    end

    private
      def with_timeout(&block)
        timeout = 20
        Timeout.timeout(timeout) do
          return yield
        end
      rescue Timeout::Error => e
        raise AuthSourceTimeoutException.new(e.message)
      end

      def initialize_ldap_con(ldap_user, ldap_password)
        options = { :host => self.host,
                    :port => self.port,
                    :encryption => encryption
                  }
        options.merge!(:auth => { :method => :simple, :username => ldap_user, :password => ldap_password }) unless ldap_user.blank? && ldap_password.blank?
        Net::LDAP.new options
      end

      def onthefly_register?
        false
      end

      def get_user_attributes_from_ldap_entry(entry)
        {
         :dn => entry.dn,
         :firstname => get_attr(entry, options['attributes']['first_name']),
         :lastname => get_attr(entry, options['attributes']['last_name']),
         :mail => get_attr(entry, options['attributes']['email']),
         :provider => provider
        }
      end

      # Return the attributes needed for the LDAP search.  It will only
      # include the user attributes if on-the-fly registration is enabled
      def search_attributes
        ['dn'] + options['attributes']['username'] + options['attributes']['email'] + [options['attributes']['name'], options['attributes']['first_name'], options['attributes']['last_name']]
      end
      def login_attributes
        if onthefly_register?
          search_attributes
        else
          ['dn']
        end
      end

      def get_user_dn(login, password=nil)
        ldap_con = nil
        if options['bind_dn'].include?("$login")
          ldap_con = initialize_ldap_con(options['bind_dn'].sub("$login", Net::LDAP::DN.escape(login)), password)
        else
          ldap_con = initialize_ldap_con(options['bind_dn'], options['password'])
        end
        attrs = nil
        search_filter = login_filters(login) #base_filter & Net::LDAP::Filter.eq(self.attr_login, login)
        ldap_con.search( :base => options['base'],
                         :filter => search_filter,
                         :attributes=> search_attributes) do |entry|
          if onthefly_register?
            attrs = get_user_attributes_from_ldap_entry(entry)
          else
            attrs = {:dn => entry.dn}
          end
          Rails.logger.debug "DN found for #{login}: #{attrs[:dn]}" if Rails.logger && Rails.logger.debug?
        end
        attrs
      end

      def login_filters(login)
        filters = options['attributes']['username'].collect{|un| Net::LDAP::Filter.eq(un, login)}
        filters[1..-1].inject(filters.first){|filter, lf| filter | lf }
      end

      def login_search_filters(q)
        filters = options['attributes']['username'].collect{|un| Net::LDAP::Filter.begins(un, q)}
        filters[1..-1].inject(filters.first){|filter, lf| filter | lf }
      end

      def user_search_filters(q)
        Net::LDAP::Filter.begins(options['attributes']['first_name'], q) | Net::LDAP::Filter.begins(options['attributes']['last_name'], q)
      end

      def get_attr(entry, attr_name)
        if attr_name.is_a? Array
          attr_name.collect{|an| get_attr(entry, an).presence }.compact.first.to_s
        elsif !attr_name.blank?
          value = entry[attr_name].is_a?(Array) ? entry[attr_name].first : entry[attr_name]
          value.to_s.force_encoding('UTF-8')
        end
      end

  end
end
