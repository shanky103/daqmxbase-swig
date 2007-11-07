$suppressStderr = false

BEGIN { $stderr.reopen("/dev/null") if $suppressStderr }

require 'daqmxbase'

# Task parameters
task = nil

# You can set up the port voltages
# using the NI-DAQmx Base Task Configuration utility
# 3.3v is push/pull
# 5V is open drain
taskName = "dio write port"

# Channel parameters
chan = "Dev1/port0" # all 8 bits in this port
# chan = "Dev1/port0:1" # all 12 bits in both ports

# Data read parameters
timeout = 10.0
# fillMode = Daqmxbase::VAL_GROUP_BY_CHANNEL
fillMode = Daqmxbase::VAL_GROUP_BY_SCAN_NUMBER
autoStart = 0
outData = (0..31).to_a.collect { |n| 2**n }
numSampsPerChan = outData.size
p [ outData, numSampsPerChan ]

begin
  task = Daqmxbase::Task.new(taskName)
  task.create_dochan(chan)
  task.start()

  while true do
    task.write_digital_scalar_u32(autoStart, timeout, 0x01)
    (errorCode, nWritten) = task.write_digital_u8(numSampsPerChan, autoStart, timeout, fillMode, outData)
#    p [ errorCode, numSampsPerChan, nWritten  ]
    (errorCode, nWritten) = task.write_digital_u32(numSampsPerChan, autoStart, timeout, fillMode, outData)
#    p [ errorCode, numSampsPerChan, nWritten  ]
  end

  puts("")

rescue  Exception => e
  $stderr.reopen($stdout) if $suppressStderr
  raise
else
 $stderr.reopen($stdout) if $suppressStderr
end

# vim: ft=ruby ts=2 sw=2 et
