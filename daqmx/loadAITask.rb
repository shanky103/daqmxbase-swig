# Ruby example program:
#    loadAITask.rb
#
# Example Category:
#    AI & Task Loading
#
# Description:
#    This example demonstrates how to load a task created with the
#    NI-DAQmx Base Task Configuration Utility.
#
# Instructions for Running:
#    1. Run the NI-DAQmx Base Task Configuration Utility executable.
#    2  Create/modify a task.
#    3. Select the created/modified task to load.
#
# Steps:
#    1. Load a task.
#    2. Start the task.
#    3. Use the Read function to read data from the task.
#       Set a timeout so an error is returned if the sample is
#       not returned in the specified time limit.
#    4. Stop the task.
#    5. Display an error if any.
#
# I/O Connections Overview:
#    Make sure your input and output signals match the
#    created/modified task.
#
# Recommended Use:
#    Loading a specialized task that was created using the
#    NI-DAQmx Base Task Configuration Utility.
#

require 'daqmxbase'

# Task parameters
taskName = "ai finite buffered"
task = nil

# Data read parameters
arraySizeInSamps = 1000
# numSampsPerChan = Daqmxbase::VAL_CFG_DEFAULT
numSampsPerChan = 1
fillMode = Daqmxbase::VAL_GROUP_BY_CHANNEL
timeout = 10.0

# data read outputs
task = Daqmxbase::Task.new(taskName)  # does LoadTask too
task.start()

now = Time.now

(data, sampsPerChanRead) = task.read_analog_f64(numSampsPerChan, timeout, fillMode, arraySizeInSamps) 

puts("elapsed: #{Time.now - now} seconds")
printf("Acquired %d samples\n", sampsPerChanRead)

# Just print out the first 10 points
10.times { |i| printf("data[%d] = %f\n", i, data[i]) }
