require 'net-ldap'

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
      providers.collect{|p| AuthSource.new(p).authenticate(login, password) }.compact.first
    end

    def self.kerberos_providers
      config.select{|provider, config| config['kerberos']}.keys
    end

    def self.find_kerberos_user(login)
      kerberos_providers.collect{|p| AuthSource.new(p).get_kerberos_user_dn(login) }.compact.first
    end

    attr_accessor :provider

    def initialize(provider)
      require 'net-ldap'
      @provider = provider
      raise "EgovUtils::AuthSource#initialize - Non existing provider (#{provider.to_s})"  unless self.class.providers.include?(provider)
    end

    def options
      @options ||= self.class.config[provider].dup
    end

    # Resolves host name - it is used only if option <tt>:resolve_host</tt> is set to true and expect <tt>:domain</tt> to be defined as well.
    # ldap controller host is resolved by asking for the <tt>_ldap._tcp.<domain></tt> DNS record and takes first - solve the load balancing of ldap queries.
    def host_dns
      require 'resolv'
      @host_dns = Resolv::DNS.open do |dns|
                    dns.getresource('_ldap._tcp.'+options['domain'], Resolv::DNS::Resource::IN::SRV)
                  end
    end

    # Get host of ldap controller from options.
    #
    # * <tt>:host</tt> - this just give one host and EgovUtils just asks that host
    # * <tt>:domain</tt> with <tt>:resolve_host</tt> set to true. Domain should be domain for your ldap users.
    #     in this configuration ldap controller host is resolved by asking for the <tt>_ldap._tcp.<domain></tt> DNS record and takes first - solve the load balancing of ldap queries.
    def host
      if options['host']
        options['host']
      elsif options['resolve_host'] && options['domain']
        host_dns.target.to_s
      end
    end

    # Returns ldap controller port. If <tt>:resolve_host</tt> is set to true and option for port is not defined, it uses port from DNS response.
    def port
      options['resolve_host'] ? (options['port'] || host_dns.port.to_i) : options['port']
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
          Rails.logger.info "AuthSource#authenticate successful for '#{login}' on provider #{provider} - user found" if Rails.logger
          return attrs.except(:dn)
        end
      end
    rescue *NETWORK_EXCEPTIONS => e
      raise AuthSourceException.new(e.message)
    end

    def get_kerberos_user_dn(login)
      return nil if login.blank?

      with_timeout do
        search_user_dn(login)
      end
    rescue *NETWORK_EXCEPTIONS => e
      raise AuthSourceException.new(e.message)
    end

    def base_user_filter
      Net::LDAP::Filter.eq("objectClass", "user") & Net::LDAP::Filter.eq("objectCategory", "person")
    end

    def base_group_filter
      options['active_directory'] ? Net::LDAP::Filter.eq("objectClass", "group") : Net::LDAP::Filter.eq('objectClass', 'groupOfNames')
    end

    # Check if a DN (user record) authenticates with the password
    def authenticate_dn(dn, password)
      if dn.present? && password.present?
        initialize_ldap_con(dn, password).bind
      end
    end

    # Searches the source for users and returns an array of results
    def search_user(q, by_login=false)
      q = q.to_s.strip
      return [] unless q.present?

      results = []
      search_filter = base_user_filter & user_search_filters(q)
      ldap_con = initialize_ldap_con(options['bind_dn'], options['password'])
      ldap_con.search(:base => options['base'],
                      :filter => search_filter,
                      :attributes => user_search_attributes,
                      :size => 10) do |entry|
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

    def search_group(q, by_login=false)
      q = q.to_s.strip
      return [] unless q.present?

      results = []
      search_filter = base_group_filter & group_search_filters(q)
      ldap_con = initialize_ldap_con(options['bind_dn'], options['password'])
      ldap_con.search(:base => options['base'],
                      :filter => search_filter,
                      :attributes => group_search_attributes,
                      :size => 10) do |entry|
        attrs = get_group_attributes_from_ldap_entry(entry)
        results << attrs if attrs
      end
      results
    rescue *NETWORK_EXCEPTIONS => e
      raise AuthSourceException.new(e.message)
    end

    def member?(user_dn, group_dn)
      ldap_con = initialize_ldap_con(options['bind_dn'], options['password'])
      Rails.logger.debug("Membership in group (#{group_dn}) for (#{user_dn})")
      ldap_con.search(base: user_dn,
                        filter: base_user_filter & Net::LDAP::Filter.ex('memberOf:1.2.840.113556.1.4.1941', group_dn),
                        attributes: ['dn']) do |entry|
        return true
      end
      return false
    end

    def group_members(group_dn)
      ldap_con = initialize_ldap_con(options['bind_dn'], options['password'])
      results = []
      if group_dn
        ldap_con.search(base: options['base'],
                          filter: base_user_filter & Net::LDAP::Filter.ex('memberOf:1.2.840.113556.1.4.1941', group_dn),
                          attributes: user_search_attributes) do |entry|
          attrs = get_user_attributes_from_ldap_entry(entry)
          if attrs
            attrs[:login] = get_attr(entry, options['attributes']['username'])
            results << attrs
          end
        end
      end
      results
    end

    def onthefly_register?
      !!options['onthefly_register']
    end

    def register_members_only?
      options['onthefly_register'] == 'members'
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
        unless ldap_user.blank? && ldap_password.blank?
          options.merge!(:auth => { :method => :simple, :username => ldap_user, :password => ldap_password })
        else
          options.merge!(:auth => { :method => :anonymous })
        end
        Net::LDAP.new options
      end

      def get_user_attributes_from_ldap_entry(entry)
        {
         :dn => entry.dn,
         :login => get_attr(entry, options['attributes']['username']),
         :firstname => get_attr(entry, options['attributes']['first_name']),
         :lastname => get_attr(entry, options['attributes']['last_name']),
         :mail => get_attr(entry, options['attributes']['email']),
         :provider => provider
        }
      end

      def get_group_attributes_from_ldap_entry(entry)
        {
         :dn => entry.dn,
         :name => get_attr(entry, 'cn'),
         :provider => provider,
         :ldap_uid => get_sid_string( get_attr(entry, 'objectSID') ),
         :external_uid => entry.dn
        }
      end

      # Return the attributes needed for the LDAP search.  It will only
      # include the user attributes if on-the-fly registration is enabled
      def user_search_attributes
        ['dn'] + options['attributes']['username'] + options['attributes']['email'] + [options['attributes']['name'], options['attributes']['first_name'], options['attributes']['last_name']]
      end
      def login_attributes
        if onthefly_register?
          user_search_attributes
        else
          ['dn']
        end
      end

      def group_search_attributes
        ['dn', 'cn', 'objectSID']
      end

      def get_user_dn(login, password=nil)
        ldap_con = nil
        if options['bind_dn'].include?("$login")
          ldap_con = initialize_ldap_con(options['bind_dn'].sub("$login", Net::LDAP::DN.escape(login)), password)
        else
          ldap_con = initialize_ldap_con(options['bind_dn'], options['password'])
        end
        attrs = nil
        search_filter = base_user_filter & login_filters(login)
        ldap_con.search( :base => options['base'],
                         :filter => search_filter,
                         :attributes=> user_search_attributes) do |entry|
          if onthefly_register?
            attrs = get_user_attributes_from_ldap_entry(entry)
          else
            attrs = {:dn => entry.dn}
          end
          Rails.logger.debug "DN found for #{login}: #{attrs[:dn]}" if Rails.logger && Rails.logger.debug?
        end
        attrs
      end

      def get_group_dn(**options)
        ldap_con = initialize_ldap_con(options['bind_dn'], options['password'])
        ldap_con.search(base: options['base'],
                        filter: base_group_filter & ( options[:sid] ? Net::LDAP::Filter.eq('objectSID', options[:sid]) : group_search_filters(options[:name]) ),
                        attributes: ['dn']) do |entry|
          return get_attr(entry, 'dn')
        end
      end

      def search_user_dn(login, password=nil)
        ldap_con = nil
        if options['bind_dn'].include?("$login")
          ldap_con = initialize_ldap_con(options['bind_dn'].sub("$login", Net::LDAP::DN.escape(login)), password)
        else
          ldap_con = initialize_ldap_con(options['bind_dn'], options['password'])
        end
        attrs = nil
        search_filter = login_search_filters(login) #base_filter & Net::LDAP::Filter.eq(self.attr_login, login)
        ldap_con.search( :base => options['base'],
                         :filter => search_filter,
                         :attributes=> user_search_attributes) do |entry|
          attrs ||= get_user_attributes_from_ldap_entry(entry)
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
        Net::LDAP::Filter.begins(options['attributes']['name'], q) |
          Net::LDAP::Filter.begins(options['attributes']['first_name'], q) |
          Net::LDAP::Filter.begins(options['attributes']['last_name'], q) |
          Net::LDAP::Filter.begins(options['attributes']['username'].first, q) |
          Net::LDAP::Filter.begins(options['attributes']['email'].first, q)
      end

      def group_search_filters(q)
        Net::LDAP::Filter.begins('cn', q)
      end

      def get_attr(entry, attr_name)
        if attr_name.is_a? Array
          attr_name.collect{|an| get_attr(entry, an).presence }.compact.first.to_s
        elsif !attr_name.blank?
          value = entry[attr_name].is_a?(Array) ? entry[attr_name].first : entry[attr_name]
          value.to_s.force_encoding('UTF-8')
        end
      end

      # converts hex representation of SID returned by AD to its string representation
      def get_sid_string(data)
        return if data.nil?
        sid = data.unpack('b x nN V*')
        sid[1, 2] = Array[nil, b48_to_fixnum(sid[1], sid[2])]
        'S-' + sid.compact.join('-')
      end

      B32 = 2**32

      def b48_to_fixnum(i16, i32)
        i32 + (i16 * B32)
      end

  end
end
