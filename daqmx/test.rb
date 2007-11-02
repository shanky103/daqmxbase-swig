require "daqmxbase"

def decodeError(errCode)
  return "SUCCESS" if errCode.zero? 
  pat = errCode < 0 ? /^ERR/ : /^WAR/
  matching = Daqmxbase.constants.select { |n| v=Daqmxbase.const_get(n); v==errCode && pat.match(n) }
  return matching[0] || "error #{errCode} not found"
end

def printOne(msg, errCode, other="")
  puts "#{msg} result: #{errCode} (#{decodeError(errCode)}) #{other}"
end

def testOne
  err_code = nil
  chan = "Dev1/ai0"
  points_to_read = 1
  task_handle = nil
  timeout = 10.0
  samples_per_chan = 1
  data = nil
  points_read = nil

  task = Daqmxbase::Task.new

  errCode = Daqmxbase::create_task("", task)
  printOne("create task", errCode,  "task=#{task.inspect}")

  errCode = task.create_aivoltage_chan("Dev1/ai0","",Daqmxbase::VAL_CFG_DEFAULT,-10.0,10.0,Daqmxbase::VAL_VOLTS,"")
  printOne("create aivoltage channel", errCode)

  errCode = task.start_task()
  printOne("start task", errCode)

  (err_code, data, points_read) = task.read_analog_f64(points_to_read, timeout, Daqmxbase::VAL_GROUP_BY_CHANNEL, samples_per_chan)
  printOne("read", errCode, "data=#{data.inspect}, points_read=#{points_read.inspect}")

  errCode = task.stop_task()
  printOne("stop task", errCode)

  errCode = task.clear_task()
  printOne("clear tast", errCode)
end

testOne()
