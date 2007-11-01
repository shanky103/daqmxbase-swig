require "daqmxbase"

class MyTest

  def self.testOne
    err_code = nil
    chan = "Dev1/ai0"
    min = -10.0
    max = 10.0
    points_to_read = 1
    task_handle = nil
    timeout = 10.0
    samples_per_chan = 1
    data = nil
    points_read = nil

    task = Daqmxbase::Task.new

    errCode = Daqmxbase::create_task("", task)
    p errCode, task

    task.create_aivoltage_chan(chan,"",Daqmxbase::VAL_CFG_DEFAULT,min,max,Daqmxbase::VAL_VOLTS, nil)
    task.start_task()

    (err_code, data, points_read) = task.read_analog_f64(points_to_read, timeout, Daqmxbase::VAL_GROUP_BY_CHANNEL, samples_per_chan)
    printf("Acquired reading: %f\n", data)

    task.stop_task()
    task.clear_task()
  end

end

MyTest::testOne()
