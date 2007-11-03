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

require 'daqmxbase'

# Task parameters
task = nil

# Channel parameters
chan = "Dev1/ai0"
nameToAssignToChannel = ""
terminalConfig = Daqmxbase::VAL_CFG_DEFAULT
min = -10.0
max = 10.0
units = Daqmxbase::VAL_VOLTS
customScaleName = ""

# Timing parameters
source = "OnboardClock"
sampleRate = 10000.0
activeEdge = Daqmxbase::VAL_RISING
sampleMode = Daqmxbase::VAL_FINITE_SAMPS
samplesPerChan = 1000

# Data read parameters
numSampsPerChan = Daqmxbase::VAL_CFG_DEFAULT # will wait and then acquire
timeout = 10.0
fillMode = Daqmxbase::VAL_GROUP_BY_CHANNEL # or Daqmxbase::VAL_GROUP_BY_SCAN_NUMBER
bufferSize = 1000

task = Daqmxbase::Task.new(nil)
task.create_aivoltage_chan(chan, nameToAssignToChannel, terminalConfig, min, max, units, customScaleName) 
task.cfg_samp_clk_timing(source, sampleRate, activeEdge, sampleMode, samplesPerChan)
task.start()

(errorCode, data, sampsPerChanRead) = task.read_analog_f64(numSampsPerChan, timeout, fillMode, bufferSize)
puts "Acquired #{pointsRead} samples"

# Just print out the first 10 points
puts data[0,10].inspect_string
