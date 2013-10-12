require "em-synchrony"
require "em-synchrony/em-http"
EM.synchrony do
  multi = EM::Synchrony::Multi.new
  multi.add :a, EM::HttpRequest.new("http://127.0.0.1:8080/asleep").aget
  multi.add :b, EM::HttpRequest.new("http://127.0.0.1:8080/asleep").aget
  res = multi.perform

  p "Look ma, no callbacks, and parallel HTTP requests!"
  p res

  EM.stop
end
