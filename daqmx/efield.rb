require 'daqmx'

class Efield
  # electrode addresses
  INT_SRC = 0
  E1 = 1; E2 = 2; E3 = 3; E4 = 4; E5 = 5; E6 = 6; E7 = 7; E8 = 8; E9 = 9
  REF_A = 10; REF_B = 11
  INT_OSC = 12; INT_OSC_AFTER_R = 13; INT_GND = 14; RESERVED=15
  # misc
  MIN_LEVEL = 0.0 # V
  MAX_LEVEL = 2.0 # V
  TIMEOUT = 1.0
  SAMPLES_TO_AVERAGE = 10
  SAMPLE_RATE = 600.0

  def aiChanName
    [@devName,@levelInput].join("/")
  end

  def doChanName
    [@devName,@selectOutputs].join("/")
  end

  def createAITask
    task = USB600x::Task.new()
    task.create_aivoltage_chan(aiChanName, Daqmxbase::VAL_RSE, MIN_LEVEL, MAX_LEVEL, Daqmxbase::VAL_VOLTS)
    if SAMPLES_TO_AVERAGE > 1
      task.cfg_samp_clk_timing("OnboardClock", SAMPLE_RATE, Daqmxbase::VAL_RISING, Daqmxbase::VAL_FINITE_SAMPS, SAMPLES_TO_AVERAGE)
    end
    task
  end

  def createDOTask
    task = USB600x::Task.new()
    task.create_dochan(doChanName)
    task
  end

  def readRawChannelLevel(channelAddress)
    (errCode, sampsWritten) = @digitalOutputTask.write_digital_u8(1, 0, TIMEOUT, Daqmxbase::VAL_GROUP_BY_CHANNEL, channelAddress)
    p [ errCode, sampsWritten ]
    # read all the samples; wait till done
    (errorCode, data, samplesPerChanRead) =  @analogInputTask.read_analog_f64(Daqmxbase::VAL_AUTO, TIMEOUT, Daqmxbase::VAL_GROUP_BY_CHANNEL, SAMPLES_TO_AVERAGE)
    if SAMPLES_TO_AVERAGE > 1
      return data.inject(0) { |s,i| s + i} / data.size
    else
      return data[0]
    end
  end

  # REFA = 10pF
  # REFB = 56pF
  def readReferences
    @refA = readRawChannelLevel(REF_A)
    @refB = readRawChannelLevel(REF_B)
  end

  def initialize
    @devName = "Dev1"
    @levelInput = "ai0"
    @selectOutputs = "port0/line0:3"
    @analogInputTask = createAITask()
    @digitalOutputTask = createDOTask()
  end

  def references
    self.readReferences if @refA.nil? or @refB.nil?
    [ @refA, @refB ]
  end
end

begin
ef = Efield.new
p ef.references

rescue Exception => e
  $stderr.print(e.to_str)
  raise
end
