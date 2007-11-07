$suppressStderr = false

BEGIN { $stderr.reopen("/dev/null") if $suppressStderr }

require 'daqmxbase'

# Task parameters
task = nil

# Channel parameters
chan = "Dev1/port0/line0:3" # all 8 bits in this port

# Data read parameters
timeout = 10.0
fillMode = Daqmxbase::VAL_GROUP_BY_CHANNEL
autoStart = 0
outData = (0..7).to_a.collect { |n| 2**n }
numSampsPerChan = 1

begin
  task = Daqmxbase::Task.new()
  task.create_dochan(chan);
  task.start()

  4.times {
  outData.each { |n| 
    written = task.write_digital_u32(numSampsPerChan, autoStart, timeout, fillMode, n)
    printf "%#x ", n
    p written if written != numSampsPerChan
  }
  }

rescue  Exception => e
  $stderr.reopen($stdout) if $suppressStderr
  raise
else
 $stderr.reopen($stdout) if $suppressStderr
end

# vim: ft=ruby ts=2 sw=2 et
