require 'uri'
# require 'net/http'
# require 'net/https'
require "em-synchrony"
require "em-synchrony/em-http"
require 'hessian2'

module Hessian2
  class Client
    attr_accessor :user, :password
    attr_reader :scheme, :host, :port, :path, :proxy

    def initialize(url, proxy = {})
      uri = URI.parse(url)
      @scheme, @host, @port, @path = uri.scheme, uri.host, uri.port, uri.path.empty? ? '/' : uri.path
      @path += "?#{uri.query}" if uri.query
      raise "Unsupported Hessian protocol: #{@scheme}" unless %w(http https).include?(@scheme)
      @proxy = proxy
    end


    def method_missing(id, *args)
      return invoke(id.id2name, args)
    end


    private
    
    def invoke(method, args)
      # puts 'invoke'
      # req = Net::HTTP::Post.new(@path, { 'Content-Type' => 'application/binary' })
      # req.basic_auth @user, @password if @user
      # conn = Net::HTTP.new(@host, @port, *@proxy.values_at(:host, :port, :user, :password))
      # conn.use_ssl = true and conn.verify_mode = OpenSSL::SSL::VERIFY_NONE if @scheme == 'https'
      # conn.start do |http|
      #   Hessian2.parse_rpc(http.request(req, Hessian2.call(method, args)).body)
      # end

      url = "#{@scheme}://#{@host}:#{@port}#{@path}"

      # f = Fiber.current
      # http = EventMachine::HttpRequest.new(url, :connect_timeout => 10, :inactivity_timeout => 20).post(body: Hessian2.call(method, args), head: { 'Content-Type' => 'application/binary' })

      # http.callback { f.resume(http) }
      # http.errback  { f.resume(http) }

      # Fiber.yield

      # if http.error
      #   p [:HTTP_ERROR, http.error]
      # end

      # Hessian2.parse_rpc(http.response)
      
      EM.synchrony do
        http = EventMachine::HttpRequest.new(url, :connect_timeout => 10, :inactivity_timeout => 20).post(body: Hessian2.call(method, args), head: { 'Content-Type' => 'application/binary' })

        return Hessian2.parse_rpc(http.response)

        EM.stop
      end

      # res = nil
      # EM.synchrony do
      #   # pass a callback enabled client to sync to automatically resume it when callback fires
      #   http = EM::Synchrony.sync EventMachine::HttpRequest.new().post(body: Hessian2.call(method, args), head: { 'Content-Type' => 'application/binary' })
      #   res = Hessian2.parse_rpc(http.response)

      #   EM.stop
      # end

      
    end

  end
end
