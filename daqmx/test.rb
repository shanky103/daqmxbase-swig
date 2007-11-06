require "daqmxbase"

def testOne
  chan = "Dev1/ai0:2"
  points_to_read = 3
  timeout = 10.0
  samples_per_chan = 10

  task = Daqmxbase::Task.new("")
print "create_aivoltage_chan: "
  p *task.create_aivoltage_chan("Dev1/ai0",Daqmxbase::VAL_CFG_DEFAULT,-1.0,1.0,Daqmxbase::VAL_VOLTS)
print "start: "
  p *task.start()
print "read_analog_f64: " 
  p *task.read_analog_f64(points_to_read, timeout, Daqmxbase::VAL_GROUP_BY_SCAN_NUMBER, samples_per_chan)
puts "done"
end

testOne()
