# http://eventmachine.rubyforge.org/EventMachine.html#watch-class_method
require 'uri'
require 'net/http'
require 'em-synchrony/em-http'
require 'hessian2'

module Hessian2
  class Client
    attr_accessor :user, :password
    attr_reader :scheme, :host, :port, :path, :proxy

    include EventMachine::Deferrable

    module Watcher
      def initialize(client, deferable)
        @client = client
        @deferable = deferable
      end

      def notify_readable
        puts 'notify_readable'
        detach
        begin
          result = @client.async_result
        rescue Exception => e
          @deferable.fail(e)
        else
          @deferable.succeed(result)
        end
      end
    end

    def initialize(url, options = {})
      uri = URI.parse(url)
      @scheme, @host, @port, @path = uri.scheme, uri.host, uri.port, uri.path.empty? ? '/' : uri.path
      @path += "?#{uri.query}" if uri.query
      raise "Unsupported Hessian protocol: #{@scheme}" unless %w(http https).include?(@scheme)
      @fiber_aware = options.delete(:fiber_aware)
      @async = options.delete(:async)
      @async_result = nil
      @proxy = options
    end


    def method_missing(id, *args)
      return invoke(id.id2name, args)
    end

    private
    
    def invoke(method, args)
      req_head = { 'Content-Type' => 'application/binary' }
      req_body = Hessian2.call(method, args)
      unless @fiber_aware
        req = Net::HTTP::Post.new(@path, req_head)
        req.basic_auth @user, @password if @user
        conn = Net::HTTP.new(@host, @port, *@proxy.values_at(:host, :port, :user, :password))
        conn.use_ssl = true and conn.verify_mode = OpenSSL::SSL::VERIFY_NONE if @scheme == 'https'
        conn.start do |http|
          res = http.request(req, req_body)
          Hessian2.parse_rpc(res.body)
        end
      else
        req_url = "#{@scheme}://#{@host}:#{@port}#{@path}"
        if @async
          http = EM::HttpRequest.new(req_url).apost(body: req_body, head: req_head)
          http.callback do |r|
            puts 'callback'
            @async_result = Hessian2.parse_rpc(r.response)
          end

          http.errback do |r|
            puts 'errback'
            @async_result = Hessian2.write_fault(Fault.new r.error)
          end

          # if ::EM.reactor_running?
          deferable = ::EM::DefaultDeferrable.new
          @watch = ::EM.watch(@port, Watcher, self, deferable)
          @watch.notify_readable = true
          deferable

          # req = EventMachine::HttpRequest.new(env[:url], connection_config(env))
          # req.setup_request(:post, { body: req_body, head: req_head }).callback { |client|
          #   save_response(env, client.response_header.status, client.response) do |resp_headers|
          #     client.response_header.each do |name, value|
          #       resp_headers[name.to_sym] = value
          #     end
          #   end
          # }
          # puts 'async'
          # http = EM::Synchrony.sync EM::HttpRequest.new(req_url).apost(body: req_body, head: req_head)
          # Hessian2.parse_rpc(http.response)
        else
          http = EM::HttpRequest.new(req_url).post(body: req_body, head: req_head)
          Hessian2.parse_rpc(http.response)
        end
      end
    end

  end
end
