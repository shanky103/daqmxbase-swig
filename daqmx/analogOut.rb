# Ruby Example program:
#    acquireNScans.rb
#
# Example Category:
#    AI
#
# Description:
#    This example demonstrates how to acquire a finite amount of data
#    using the DAQ device's internal clock.
#
# Instructions for Running:
#    1. Select the physical channel to correspond to where your signal
#       is input on the DAQ device.
#    2. Enter the minimum and maximum voltage range.
#       Note: For better accuracy try to match the input range to the
#       expected voltage level of the measured signal.
#    3. Set the number of samples to acquire per channel.
#    4. Set the rate of the acquisiton.
#       Note: The rate should be AT LEAST twice as fast as the maximum
#       frequency component of the signal being acquired.
#
# Steps:
#    1. Create a task.
#    2. Create an analog input voltage channel.
#    3. Set the rate for the sample clock. Additionally, define the
#       sample mode to be finite.
#    4. Call the Start function to start the acquistion.
#    5. Read all of the waveform data.
#    6. Call the Clear Task function to stop the acquistion.
#    7. Display an error if any.
#
# I/O Connections Overview:
#    Make sure your signal input terminal matches the Physical Channel
#    I/O Control. In this case wire your signal to the ai0 pin on your
#    DAQ Device. By default, this will also be the signal used as the
#    analog start trigger.
#
# Recommended use:
#    Call Configure and Start functions.
#    Call Read function.
#    Call Stop function at the end.
#

$suppressStderr = false
BEGIN { $stderr.reopen("/dev/null") if $suppressStderr }

require 'daqmxbase'

# Task parameters
task = nil

# Channel parameters
chan = "Dev1/ao0"
terminalConfig = Daqmxbase::VAL_CFG_DEFAULT
min = 0.0
max = 5.0
units = Daqmxbase::VAL_VOLTS

# Data write parameters
data = [ 0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 4.0, 3.0, 2.0, 1.0 ] * 1000
fillMode = Daqmxbase::VAL_GROUP_BY_CHANNEL # or Daqmxbase::VAL_GROUP_BY_SCAN_NUMBER
samplesPerChan = data.size
timeout = (data.size / 150.0) * 2

begin
  task = Daqmxbase::Task.new(nil)
  task.create_aovoltage_chan(chan, min, max, units) 
  task.start()

	while true
  startTime = Time.now
  (errorCode, samplesPerChanRead) = task.write_analog_f64(samplesPerChan, 0, timeout, fillMode, data)
  endTime = Time.now
	rate = samplesPerChanRead/(endTime-startTime)
	$stdout.puts "error #{errorCode}, write #{samplesPerChanRead}, total time: #{endTime - startTime}, rate: #{rate}"
	end

rescue  Exception => e
  $stderr.reopen($stdout) if $suppressStderr
  raise
else
	$stderr.reopen($stdout) if $suppressStderr
end

# vim: ft=ruby ts=2 sw=2 et
