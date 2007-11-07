require "daqmxbase"

def testOne
  deviceName = "Dev1"
  chan = deviceName + "/ai0:2"
  points_to_read = 3
  timeout = 10.0
  samples_per_chan = 10
  minVal = -1.0
  maxVal = 1.0

  Daqmxbase::reset_device(deviceName)
  task = Daqmxbase::Task.new
  print "create_aivoltage_chan: "
  p task.create_aivoltage_chan(chan,Daqmxbase::VAL_CFG_DEFAULT,minVal,maxVal,Daqmxbase::VAL_VOLTS)
  print "start: "
  p task.start()
  print "read_analog_f64: " 
  (data, pointsRead) = task.read_analog_f64(points_to_read, timeout, Daqmxbase::VAL_GROUP_BY_SCAN_NUMBER, samples_per_chan)
  p [data, pointsRead]
  puts "done"
end

testOne()
