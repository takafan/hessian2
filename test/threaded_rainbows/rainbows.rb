Rainbows! do
  use :ThreadSpawn
end

worker_processes 1

timeout 30

pid '/tmp/monkey.pid'

preload_app true
GC.respond_to?(:copy_on_write_friendly=) and
  GC.copy_on_write_friendly = true
