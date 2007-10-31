require "mkmf"
$CPPFLAGS="-I \"/Applications/National Instruments/NI-DAQmx Base/includes\""
$LIBS="-framework nidaqmxbase -framework nidaqmxbaselv"
create_makefile("daqmxbase")
