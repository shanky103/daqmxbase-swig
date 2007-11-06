$suppressStderr = false

BEGIN { $stderr.reopen("/dev/null") if $suppressStderr }

require 'daqmxbase'

# Task parameters
task = nil

# Channel parameters
chan = "Dev1/port0"	# all 8 bits in this port

# Data read parameters
timeout = 10.0
fillMode = Daqmxbase::VAL_GROUP_BY_CHANNEL
bufferSize = 100
numSampsPerChan = bufferSize

begin
  task = Daqmxbase::Task.new(nil)
  task.create_dichan(chan);
  task.start()

  (errorCode, data) = task.read_digital_scalar_u32(timeout)
  printf("read_digital_scalar_u32: 0x%x\n", data)

  (errorCode, data, sampsPerChanRead) = task.read_digital_u32(numSampsPerChan, timeout, fillMode, bufferSize)
  printf("read_digital_u32 read %d samps/chan: ", sampsPerChanRead)
  data.each { |d| printf(" 0x%x", d) }

  (errorCode, data, sampsPerChanRead) = task.read_digital_u8(numSampsPerChan, timeout, fillMode, bufferSize)
  printf("\nread_digital_u8 read %d samps/chan: ", sampsPerChanRead)
  data.each { |d| printf(" 0x%x", d) }
  puts("")

rescue  Exception => e
  $stderr.reopen($stdout) if $suppressStderr
  raise
else
 $stderr.reopen($stdout) if $suppressStderr
end
