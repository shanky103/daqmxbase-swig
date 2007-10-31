# $Id$
#
SWIG=/opt/local/bin/swig
RUBY=/opt/local/bin/ruby

NI_DIR=/Applications/National Instruments/NI-DAQmx Base
NI_INC_DIR=$(NI_DIR)/includes

SWIG_OPTS+=-Wall
CPPFLAGS+=-I \"$(NI_INC_DIR)\"
CFLAGS+=-Wall -Wno-redundant-decls
LIBS=-framework nidaqmxbase -framework nidaqmxbaselv

MODULE=dAQmxBase
FEATURE=DAQmxBase

INTERFACE=$(MODULE).i
WRAPPER=$(MODULE)_wrap.c
BUNDLE=$(MODULE).bundle

all: Makefile $(WRAPPER)
	make all

install: Makefile
	make install

Makefile: extconf.rb
	$(RUBY) extconf.rb

$(WRAPPER): $(INTERFACE)
	$(SWIG) $(SWIG_OPTS) -ruby "-I$(NI_INC_DIR)" -o $@ $(INTERFACE)

extconf.rb: $(MAKEFILE_LIST)
	echo 'require "mkmf"' > $@
	echo '$$CPPFLAGS="$(CPPFLAGS)"' >> $@
	echo '$$LIBS="$(LIBS)"' >> $@
	echo 'create_makefile("$(MODULE)")' >> $@

clean:
	@if [ -f Makefile ] ; then\
		make -f Makefile clean;\
	fi
	rm -f Makefile $(WRAPPER)
	rm -f extconf.rb

test: all
	$(RUBY) -r $(MODULE) -e '$$stdout.sync=true; puts "\nNew methods"; p $(PREFIX)$(FEATURE).methods - Module.methods; puts ""'

# vim: filetype=make
