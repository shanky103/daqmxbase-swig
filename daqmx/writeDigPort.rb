$suppressStderr = false

BEGIN { $stderr.reopen("/dev/null") if $suppressStderr }

require 'daqmxbase'

# Task parameters
task = nil

# Channel parameters
chan = "Dev1/port0" # all 8 bits in this port

# Data read parameters
timeout = 10.0
fillMode = Daqmxbase::VAL_GROUP_BY_CHANNEL
numSampsPerChan = 1
autoStart = 0
outData = (0..255).to_a

begin
  task = Daqmxbase::Task.new()
  task.create_dochan(chan);
  task.start()

  while true
    (0..7).to_a.collect { |n| 2**n }.each  do |n|
    task.write_digital_scalar_u32(autoStart, timeout, n)
#    task.write_digital_scalar_u32(autoStart, timeout, 0xFF)
#    task.write_digital_u8(numSampsPerChan, autoStart, timeout, fillMode, outData)
#    task.write_digital_u32(numSampsPerChan, autoStart, timeout, fillMode, outData)
    end
  end

  puts("")

rescue  Exception => e
  $stderr.reopen($stdout) if $suppressStderr
  raise
else
 $stderr.reopen($stdout) if $suppressStderr
end

# vim: ft=ruby ts=2 sw=2 et
