# frozen_string_literal: true

# from https://raw.githubusercontent.com/rails/rails/main/actionpack/lib/action_dispatch/middleware/remote_ip.rb

require "ipaddr"

class RemoteIp
  class IpSpoofAttackError < StandardError; end

  TRUSTED_PROXIES = [
    "127.0.0.0/8",    # localhost IPv4 range, per RFC-3330
    "::1",            # localhost IPv6
    "fc00::/7",       # private IPv6 range fc00::/7
    "10.0.0.0/8",     # private IPv4 range 10.x.x.x
    "172.16.0.0/12",  # private IPv4 range 172.16.0.0 .. 172.31.255.255
    "192.168.0.0/16" # private IPv4 range 192.168.x.x
  ].map { |proxy| IPAddr.new(proxy) }

  attr_reader :check_ip, :proxies

  def initialize(rack_req_headers, ip_spoofing_check = true, custom_proxies = nil)
    @rack_req_headers = rack_req_headers
    @check_ip = ip_spoofing_check
    @proxies =
      if custom_proxies.blank?
        TRUSTED_PROXIES
      elsif custom_proxies.respond_to?(:any?)
        custom_proxies
      else
        raise(ArgumentError, "custom_proxies must be a array of IPAddr`s instances.")
      end
  end

  def call
    return @result if defined?(@result)

    @result = GetIp.new(@rack_req_headers, check_ip, proxies)
  end

  class GetIp
    def initialize(headers, check_ip, proxies)
      @headers = headers
      @check_ip = check_ip
      @proxies = proxies
    end

    def calculate_ip
      remote_addr = ips_from(@headers["REMOTE_ADDR"]).last

      client_ips    = ips_from(@headers["HTTP_CLIENT_IP"]).reverse!
      forwarded_ips = ips_from(@headers["HTTP_X_FORWARDED_FOR"]).reverse!

      should_check_ip = @check_ip && client_ips.last && forwarded_ips.last
      if should_check_ip && !forwarded_ips.include?(client_ips.last)
        raise(
          IpSpoofAttackError,
          "IP spoofing attack?! " \
          "HTTP_CLIENT_IP=#{@req.client_ip.inspect} " \
          "HTTP_X_FORWARDED_FOR=#{@req.x_forwarded_for.inspect}"
        )
      end

      ips = forwarded_ips + client_ips
      ips.compact!

      filter_proxies(ips + [remote_addr]).first || ips.last || remote_addr
    end

    def to_s
      @ip ||= calculate_ip
    end

    private

    def ips_from(header) # :doc:
      return [] unless header

      ips = header.strip.split(/[,\s]+/)
      ips.select! do |ip|
        range = IPAddr.new(ip).to_range
        range.begin == range.end
      rescue ArgumentError
        nil
      end
      ips
    end

    def filter_proxies(ips) # :doc:
      ips.reject do |ip|
        @proxies.any? { |proxy| proxy === ip }
      end
    end
  end
end
