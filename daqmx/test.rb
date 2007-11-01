require "daqmxbase"

class MyTest

  def self.daqmx_err_chk(retcode)
    return 0 if retcode.zero?
    err_buff = " " * 2048
    err_buff = Daqmxbase::daqmx_base_get_extended_error_info(err_buff.size)
    if retcode < 0
      printf("Error %d: %s\n", retcode, err_buff)
      exit(1)
    elsif retcode > 0
      printf("Warning %d: %s\n", retcode, err_buff)
    end
    return retcode
  end

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

    (err_code, task_handle) = Daqmxbase::daqmx_base_create_task("")

    daqmx_err_chk(err_code)

    daqmx_err_chk(Daqmxbase::daqmx_base_create_aivoltage_chan(task_handle,chan,"",Daqmxbase::DAQMX_VAL_CFG_DEFAULT,min,max,Daqmxbase::DAQMX_VAL_VOLTS, nil))

    daqmx_err_chk(Daqmxbase::daqmx_base_start_task(task_handle))
    (err_code, data, points_read) = Daqmxbase::daqmx_base_read_analog_f_64(task_handle, points_to_read, timeout, Daqmxbase::DAQMX_VAL_GROUPBYCHANNEL, samples_per_chan)
    daqmx_err_chk(err_code)
    printf("Acquired reading: %f\n", data)

    if task_handle
      Daqmxbase::daqmx_base_stop_task(task_handle)
      Daqmxbase::daqmx_base_clear_task(task_handle)
    end
  end

end

MyTest::testOne()
