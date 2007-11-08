# $Id$
#
# efield.rb: drive the channel select  lines of a MC33794 eval board and
# sample the levels.
#
# Changed to sample continuously.
#--------------------------------------------------------------------------------
# ruby-daqmxbase: A SWIG interface for Ruby and the NI-DAQmx Base data
# acquisition library.
# 
# Copyright (C) 2007 Ned Konz
# 
# Licensed under the Apache License, Version 2.0 (the "License"); you
# may not use this file except in compliance with the License.  You may
# obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.  See the License for the specific language governing
# permissions and limitations under the License.
#--------------------------------------------------------------------------------

require 'daqmxbase'

$stdout.sync = true

class Efield
  include Daqmxbase

  # electrode addresses
  INT_SRC = 0
  E1 = 1; E2 = 2; E3 = 3; E4 = 4; E5 = 5; E6 = 6; E7 = 7; E8 = 8; E9 = 9
  REF_A = 10; REF_B = 11
  INT_OSC = 12; INT_OSC_AFTER_R = 13; INT_GND = 14; RESERVED=15
  # misc
  MIN_LEVEL = 0.0 # V
  MAX_LEVEL = 5.0 # V

  SAMPLES_TO_AVERAGE = 200 # Shouldn't be more than 512
  SAMPLE_RATE = 60 * SAMPLES_TO_AVERAGE   # can't be more than 48KHz or so

  TIMEOUT = 0.5

  def createAITask
    task = Task.new()
    task.create_aivoltage_chan(@devName+"/"+@levelInput, VAL_DIFF, MIN_LEVEL, MAX_LEVEL, VAL_VOLTS)
    # configure for continuous sampling; must do a read before changing
    # channels.
    task.cfg_samp_clk_timing("OnboardClock", SAMPLE_RATE, VAL_RISING, VAL_CONT_SAMPS, 0)
    task.start
    task
  end

  def createDOTask
    task = Task.new()
    task.create_dochan(@devName+"/"+@selectOutputs)
    task.start
    task
  end

  def readRawChannelLevel(channelAddress)
    # don't re-write the same address
    if @lastAddress != channelAddress
      @changedAddressAt = Time.now
      @digitalOutputTask.write_digital_scalar_u32(0, TIMEOUT, channelAddress)
      @lastAddress = channelAddress
    end
    # ensure that the last SAMPLES_TO_AVERAGE samples came from the
    # current channel
    sleepyTime = (SAMPLES_TO_AVERAGE / SAMPLE_RATE) - (Time.now - @changedAddressAt)
    if sleepyTime > 0
      printf("sleep %f\n", sleepyTime)
      sleep(sleepyTime)
    end
    # read all the samples; wait till done
    (data, samplesPerChanRead) =
      @analogInputTask.read_analog_f64(SAMPLES_TO_AVERAGE, TIMEOUT, VAL_GROUP_BY_CHANNEL, SAMPLES_TO_AVERAGE)
    if samplesPerChanRead != SAMPLES_TO_AVERAGE
      printf("got %d, asked for %d\n", samplesPerChanRead, SAMPLES_TO_AVERAGE)
    end
    retval = data.inject(0.0) { |s,i| s + i} / data.size  # average
    if channelAddress == REF_A
      @refA = retval
    elsif channelAddress == REF_B
      @refB = retval
    end
    return retval
  end

  # REF_A = 10pF
  # REF_B = 56pF
  def readReferences
    @refA = readRawChannelLevel(REF_A)
    @refB = readRawChannelLevel(REF_B)
  end

  def refA
    self.references()[0]
  end

  def refB
    self.references()[1]
  end

  def initialize
    @devName = "Dev1"
    @levelInput = "ai0"
    @selectOutputs = "port0"
    @analogInputTask = createAITask()
    @digitalOutputTask = createDOTask()
    @changedAddressAt = nil
    @lastAddress = nil
  end

  def references
    self.readReferences if @refA.nil? or @refB.nil?
    [ @refA, @refB ]
  end

  def self.testRun
    channelRange = (E5..E7).to_a
    ef = self.new
    baseline = channelRange.to_a.collect { |cn| lev = ef.readRawChannelLevel(cn) }
    scale = (ef.references[1] - ef.references[0]) / 46 # pf
    min = ef.references[0]
    baseline = baseline.collect { |v| v - min }

    started = Time.now
    totalSamples = 0
    now = nil
    File.open("efield.csv", 'w') do |outfile|
      while (now = Time.now) - started < 10.0
        values = channelRange.to_a.collect { |cn| lev = ef.readRawChannelLevel(cn) - min }
        diffs = values.zip(baseline).collect { |a| diff = (a[0] - a[1]) / scale }
        outfile.puts((diffs.collect {|d| "%6.4f"% d }.push(totalSamples.to_s)).join(","))
        totalSamples = totalSamples + channelRange.size
      end
    end
    puts "\nelapsed: #{now-started} samples: #{totalSamples} rate: #{totalSamples/(now-started)}"
  end
end

Efield.testRun

# vim: ft=ruby ts=2 sw=2 et ai
