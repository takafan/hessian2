require 'uri'
require 'em-synchrony'
require 'em-synchrony/em-http'
require 'hessian2'

module Hessian2
  class EmClient
    attr_accessor :user, :password
    attr_reader :scheme, :host, :port, :path, :proxy

    def initialize(url, proxy = {})
      uri = URI.parse(url)
      @scheme, @host, @port, @path = uri.scheme, uri.host, uri.port, uri.path.empty? ? '/' : uri.path
      @path += "?#{uri.query}" if uri.query
      raise "Unsupported Hessian protocol: #{@scheme}" unless @scheme == 'http'
      @proxy = proxy
    end


    def method_missing(id, *args)
      return invoke(id.id2name, args)
    end


    private

    def invoke(method, args)

      result = nil
      block = lambda do
        EM::Synchrony.sync(
          EM::HttpRequest.new("http://#{@host}:#{@port}", :connect_timeout => 5, :inactivity_timeout => 60).apost(
            path: @path,
            head: {'Content-Type' => 'application/binary; charset=utf-8'},
            body: Hessian2.call(method, args)
          )
        )
      end

      unless EM.reactor_running?
        puts 'not running'
        EM.synchrony do
          result = Hessian2.parse_rpc(block.call.response)
          EM.stop
        end
      else
        puts 'running'
        result = Hessian2.parse_rpc(block.call.response)
      end

      result
    end

  end
end
