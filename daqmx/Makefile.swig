SWIG=/opt/local/bin/swig
RUBY=/opt/local/bin/ruby

NI_DIR=/Applications/National Instruments/NI-DAQmx Base
NI_INC_DIR=$(NI_DIR)/includes

SWIG_OPTS+=-Wall -Wredundant-decls
FEATURE=DAQMXBASE
MODULE=daqmxbase
CPPFLAGS=-I \"$(NI_INC_DIR)\"
LIBS=-framework nidaqmxbase -framework nidaqmxbaselv
RUBY=/usr/bin/ruby
INTERFACE=$(MODULE).i
WRAPPER=$(MODULE)_wrap.c
BUNDLE=$(MODULE).bundle

swigall: $(BUNDLE)

install: Makefile
	make install

Makefile: extconf.rb
	$(RUBY) extconf.rb

# 	@if [ -f Makefile ] ; then\
# 		echo "include Makefile.swig" >> Makefile;\
# 	fi

$(BUNDLE): Makefile $(WRAPPER)
	make

$(WRAPPER): $(INTERFACE)
	$(SWIG) $(SWIG_OPTS) -ruby "-I$(NI_INC_DIR)" -o $@ $(INTERFACE)

extconf.rb: $(MAKEFILE_LIST)
	echo 'require "mkmf"' > $@
	echo '$$CPPFLAGS="$(CPPFLAGS)"' >> $@
	echo '$$LIBS="$(LIBS)"' >> $@
	echo 'create_makefile("$(MODULE)")' >> $@

swigclean:
	@if [ -f Makefile ] ; then\
		make -f Makefile clean;\
	fi
	rm -f Makefile $(WRAPPER)
	rm -f extconf.rb *.o $(BUNDLE)

test: $(BUNDLE)
	$(RUBY) -r ./$(MODULE) -e '$$stdout.sync=true; p $(FEATURE).methods - Module.methods'

