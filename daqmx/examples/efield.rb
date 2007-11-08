# $Id$
#
# efield.rb: drive the channel select  lines of a MC33794 eval board and
# sample the levels.
#
# Unfortunately, the turnaround between the digital and analog causes
# this to go about 300msec/chan max speed.
#
# But it's a working example anyway.
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
  TIMEOUT = 10.0
  SAMPLES_TO_AVERAGE = 100
  SAMPLE_RATE = 6000

  def createAITask
    task = Task.new()
    task.create_aivoltage_chan(@devName+"/"+@levelInput, VAL_DIFF, MIN_LEVEL, MAX_LEVEL, VAL_VOLTS)
    if SAMPLES_TO_AVERAGE > 1
      task.cfg_samp_clk_timing("OnboardClock", SAMPLE_RATE, VAL_RISING, VAL_FINITE_SAMPS, SAMPLES_TO_AVERAGE)
    end
    task
  end

  def createDOTask
    task = Task.new()
    task.create_dochan(@devName+"/"+@selectOutputs)
    task.start
    task
  end

  def readRawChannelLevel(channelAddress)
    @digitalOutputTask.write_digital_scalar_u32(0, TIMEOUT, channelAddress)
    # read all the samples; wait till done
    @analogInputTask.start
    (data, samplesPerChanRead) =
    @analogInputTask.read_analog_f64(VAL_AUTO, TIMEOUT,
      VAL_GROUP_BY_CHANNEL, SAMPLES_TO_AVERAGE)
    @analogInputTask.stop
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
  end

  def references
    self.readReferences if @refA.nil? or @refB.nil?
    [ @refA, @refB ]
  end

  def self.testRun
    ef = self.new
    baseline = (E1..E9).to_a.collect { |cn| lev = ef.readRawChannelLevel(cn) }
    scale = (ef.references[1] - ef.references[0]) / 46 # pf
    min = ef.references[0]
    baseline = baseline.collect { |v| v - min }

    while true
      values = (E1..E9).to_a.collect { |cn| lev = ef.readRawChannelLevel(cn) - min }
      diffs = values.zip(baseline).collect { |a| diff = (a[0] - a[1]) / scale }
      diffs.each { |d| printf "% 6.3f ", d }
      print "\r"
      $stdout.flush
    end
  end
end

Efield.testRun

# vim: ft=ruby ts=2 sw=2 et ai
