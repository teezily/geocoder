require "geocoder/lookups/test"

module Geocoder
  module Lookup
    extend self

    ##
    # Array of valid Lookup service names.
    #
    def all_services
      street_services + ip_services
    end

    ##
    # Array of valid Lookup service names, excluding :test.
    #
    def all_services_except_test
      all_services - [:test]
    end

    ##
    # All street address lookup services, default first.
    #
    def street_services
      @street_services ||= [
        :location_iq,
        :dstk,
        :esri,
        :google,
        :google_premier,
        :google_places_details,
        :google_places_search,
        :bing,
        :geocoder_ca,
        :geocoder_us,
        :yandex,
        :nominatim,
        :mapbox,
        :mapquest,
        :mapzen,
        :opencagedata,
        :ovi,
        :pelias,
        :pickpoint,
        :here,
        :baidu,
        :geocodio,
        :smarty_streets,
        :okf,
        :postcode_anywhere_uk,
        :geoportail_lu,
        :ban_data_gouv_fr,
        :test,
        :latlon,
        :amap
      ]
    end

    ##
    # All IP address lookup services, default first.
    #
    def ip_services
      @ip_services ||= [
        :baidu_ip,
        :freegeoip,
        :geoip2,
        :maxmind,
        :maxmind_local,
        :telize,
        :pointpin,
        :maxmind_geoip2,
        :ipinfo_io,
        :ipapi_com,
        :db_ip_com
      ]
    end

    attr_writer :street_services, :ip_services

    ##
    # Retrieve a Lookup object from the store.
    # Use this instead of Geocoder::Lookup::X.new to get an
    # already-configured Lookup object.
    #
    def get(name)
      @services = {} unless defined?(@services)
      @services[name] = spawn(name) unless @services.include?(name)
      @services[name]
    end


    private # -----------------------------------------------------------------

    ##
    # Spawn a Lookup of the given name.
    #
    def spawn(name)
      if all_services.include?(name)
        name = name.to_s
        require "geocoder/lookups/#{name}"
        Geocoder::Lookup.const_get(classify_name(name)).new
      else
        valids = all_services.map(&:inspect).join(", ")
        raise ConfigurationError, "Please specify a valid lookup for Geocoder " +
          "(#{name.inspect} is not one of: #{valids})."
      end
    end

    ##
    # Convert an "underscore" version of a name into a "class" version.
    #
    def classify_name(filename)
      filename.to_s.split("_").map{ |i| i[0...1].upcase + i[1..-1] }.join
    end
  end
end
