SWIG=/opt/local/bin/swig
NI_DIR=/Applications/National Instruments/NI-DAQmx Base
NI_INC_DIR=$(NI_DIR)/includes
DAQMXBASE=daqmxbase
CPPFLAGS=-I \"$(NI_INC_DIR)\"
LIBS=-framework nidaqmxbase -framework nidaqmxbaselv
RUBY=/usr/bin/ruby

all: $(DAQMXBASE).bundle

install: Makefile
	make install

Makefile: extconf.rb
	ruby extconf.rb 

$(DAQMXBASE).bundle: Makefile $(DAQMXBASE).c
	make

$(DAQMXBASE).c: $(DAQMXBASE).i
	$(SWIG) -ruby "-I$(NI_INC_DIR)" $<

extconf.rb: $(MAKEFILE_LIST)
	echo 'require "mkmf"' > $@
	echo '$$CPPFLAGS="$(CPPFLAGS)"' >> $@
	echo '$$LIBS="$(LIBS)"' >> $@
	echo 'create_makefile("$(DAQMXBASE)")' >> $@

clean:
	rm extconf.rb Makefile *.o *.bundle

test: $(DAQMXBASE).bundle
	$(RUBY) -r ./daqmxbase -e '$$stdout.sync=true; p Daqmxbase.methods - Module.methods'
