require 'daqmxbase'

# Dev1/ai0 .. Dev1/ai7 (rse)
# Dev1/ai0 .. Dev1/ai4 (diff)
# Dev1/port0 (8 bits)
# Dev1/port0:1 (12 bits)
# Dev1/port1 (4 bits)
# Dev1/port1/line0:3 (4 bits, same as above)
# Dev1/port0/line0:3 (4 bits)
# Dev1/ctr0

class DAQmx
include Daqmxbase

end

p DAQmx.ancestors
p DAQmx.instance_methods - Class.instance_methods
p DAQmx.methods - Class.methods
p DAQmx.constants.reject { |c| /^(ERROR_|WARNING_|VAL_)/.match(c) }
