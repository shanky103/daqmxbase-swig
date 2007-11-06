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

# BEGIN { $stderr.reopen("/dev/null") }

require 'daqmxbase'

# Task parameters
task = nil

# Channel parameters
chan = "Dev1/ai0:7"
nameToAssignToChannel = ""
# differential:
# terminalConfig = Daqmxbase::VAL_CFG_DEFAULT
# single-ended: 
terminalConfig = Daqmxbase::VAL_RSE
min = -2.0
max = 2.0
units = Daqmxbase::VAL_VOLTS
customScaleName = ""

# Timing parameters
source = "OnboardClock"
sampleRate = 10.0
activeEdge = Daqmxbase::VAL_RISING
sampleMode = Daqmxbase::VAL_FINITE_SAMPS
samplesPerChan = 10

# Data read parameters
# numSamplsPerChan = Daqmxbase::VAL_CFG_DEFAULT # will wait and then acquire
numSamplesPerChan = 100
timeout = 10.0
fillMode = Daqmxbase::VAL_GROUP_BY_CHANNEL # or Daqmxbase::VAL_GROUP_BY_SCAN_NUMBER
bufferSize = 800

begin
  task = Daqmxbase::Task.new(nil)
  task.create_aivoltage_chan(chan, nameToAssignToChannel, terminalConfig, min, max, units, customScaleName) 
  task.cfg_samp_clk_timing(source, sampleRate, activeEdge, sampleMode, samplesPerChan)
  task.start()

  startTime = Time.now
  (errorCode, data, samplesPerChanRead) = task.read_analog_f64(numSamplesPerChan, timeout, fillMode, bufferSize)
  endTime = Time.now
# rescue  Exception => e
#  $stderr.reopen($stdout)
#  $stderr.puts e.message
# else
#  $stderr.reopen($stdout)
  p data
  $stdout.puts "error #{errorCode}, read #{samplesPerChanRead}, total time: #{endTime - startTime}, rate: #{samplesPerChanRead/(endTime-startTime)}"
end
