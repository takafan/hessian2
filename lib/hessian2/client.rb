require 'uri'
require 'net/http'
require 'net/https'
require 'hessian2/parser'
require 'hessian2/writer'

module Hessian2
  class Client
    attr_accessor :user, :password
    attr_reader :scheme, :host, :port, :path, :proxy

    include Writer

    def initialize(url, proxy = {})
      uri = URI.parse(url)
      @scheme, @host, @port, @path = uri.scheme, uri.host, uri.port, uri.path
      raise "Unsupported Hessian protocol: #{@scheme}" unless %w(http https).include? @scheme
      @proxy = proxy
    end

    def method_missing(id, *args)
      return invoke(id.id2name, args)
    end

    private
    def invoke(method, args)
      req = Net::HTTP::Post.new(@path, { 'Content-Type' => 'application/binary' })
      req.basic_auth @user, @password if @user
      conn = Net::HTTP.new(@host, @port, *@proxy.values_at(:host, :port, :user, :password))
      conn.use_ssl = true and conn.verify_mode = OpenSSL::SSL::VERIFY_NONE if @scheme == 'https'
      conn.start do |http|
        body = http.request(req, call(method, args)).body
        t0 = Time.new
        data = Hessian2::Parser.parse(body)
        puts "#{Time.new - t0}s"
        data
      end
    end

  end
end
