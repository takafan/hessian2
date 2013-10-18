require 'uri'
require 'net/http'
require 'em-synchrony/em-http'
require 'hessian2'

module Hessian2
  class Client
    attr_accessor :user, :password
    attr_reader :scheme, :host, :port, :path, :proxy

    def initialize(url, options = {})
      uri = URI.parse(url)
      @scheme, @host, @port, @path = uri.scheme, uri.host, uri.port, uri.path.empty? ? '/' : uri.path
      @path += "?#{uri.query}" if uri.query
      raise "Unsupported Hessian protocol: #{@scheme}" unless %w(http https).include?(@scheme)
      @async = options.delete(:async)
      @fiber_aware = options.delete(:fiber_aware)
      @proxy = options
    end


    def method_missing(id, *args)
      return invoke(id.id2name, args)
    end

    private
    
    def invoke(method, args)
      req_head = { 'Content-Type' => 'application/binary' }
      req_body = Hessian2.call(method, args)

      if @async
        EM::HttpRequest.new("#{@scheme}://#{@host}:#{@port}#{@path}").apost(body: req_body, head: req_head)
      elsif @fiber_aware
        http = EM::HttpRequest.new("#{@scheme}://#{@host}:#{@port}#{@path}").post(body: req_body, head: req_head)
        Hessian2.parse_rpc(http.response)
      else
        req = Net::HTTP::Post.new(@path, req_head)
        req.basic_auth @user, @password if @user
        conn = Net::HTTP.new(@host, @port, *@proxy.values_at(:host, :port, :user, :password))
        conn.use_ssl = true and conn.verify_mode = OpenSSL::SSL::VERIFY_NONE if @scheme == 'https'
        conn.start do |http|
          res = http.request(req, req_body)
          Hessian2.parse_rpc(res.body)
        end
      end
    end

  end
end
