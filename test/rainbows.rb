Rainbows! do
  use :EventMachine
end

worker_processes 1

app = 'monkey'

timeout 30

pid "/tmp/#{app}.pid"

preload_app true
GC.respond_to?(:copy_on_write_friendly=) and
  GC.copy_on_write_friendly = true
