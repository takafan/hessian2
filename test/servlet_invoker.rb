require 'net/http'

HEADER = { 'Content-Type' => 'application/binary' }

call = %w(c 0 1 m).pack('ahha')
methods = %w(
  getInt getLong getDouble getFalse getTrue getString getNull
  getDate getIntArray getObjectArray getArrayInList getMap
)

methods.each do |m|
  Net::HTTP.start('localhost', 8080) do |http|
    res = http.send_request('POST', '/test',
      call + [ m.length, m ].pack('na*') + 'z', HEADER)
    p res.body
  end
end
