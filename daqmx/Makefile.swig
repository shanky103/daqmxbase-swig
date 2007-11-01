# $Id$
#
SWIG=/opt/local/bin/swig
RUBY=/opt/local/bin/ruby

SPACE:= # space at end
QUOTED_SPACE:=\ # space at end
NI_DIR:=/Applications/National Instruments/NI-DAQmx Base
NI_INC_DIR:=$(NI_DIR)/includes
NI_HEADER:=/Applications/National\ Instruments/NI-DAQmx\ Base/includes/NIDAQmxBase.h
# NI_HEADER:=$(subst $(SPACE),$(QUOTED_SPACE),$(NI_INC_DIR))/NIDAQmxBase.h

SWIG_OPTS+=-v -ruby -Wall -w+322  -Fstandard
CPPFLAGS+=-I \"$(NI_INC_DIR)\"
CFLAGS+=-g -Wall -Wno-redundant-decls
LIBS=-framework nidaqmxbase -framework nidaqmxbaselv

MODULE=daqmxbase
FEATURE=Daqmxbase

INTERFACE=$(MODULE).i
WRAPPER=$(MODULE)_wrap.c
BUNDLE=$(FEATURE).bundle
DECLS=$(MODULE)_decls.i
 
.PHONY: all install clean test debug

all: $(BUNDLE)

$(BUNDLE): Makefile
	make $@

install: Makefile
	make install

Makefile: $(WRAPPER) extconf.rb
	$(RUBY) -r mkmf extconf.rb

$(WRAPPER): $(DECLS) $(INTERFACE)
	$(SWIG) $(SWIG_OPTS) "-I$(NI_INC_DIR)" -o $@ $(INTERFACE)

$(DECLS): rewrite.rb $(NI_HEADER)
	ruby rewrite.rb $(NI_HEADER) > $@

extconf.rb: $(MAKEFILE_LIST)
	echo 'require "mkmf"' > $@
	echo '$$CPPFLAGS<<" $(CPPFLAGS) "' >> $@
	echo '$$CFLAGS<<" $(CFLAGS) "' >> $@
	echo '$$LDFLAGS<<" $(LDFLAGS) "' >> $@
	echo '$$LIBS<<" $(LIBS) "' >> $@
	echo 'create_makefile("$(FEATURE)")' >> $@

clean:
	@if [ -f Makefile ] ; then\
		make -f Makefile clean;\
	fi
	rm -f Makefile $(WRAPPER)
	rm -f extconf.rb .gdbinit

test: $(BUNDLE) testload.rb
	$(RUBY) -w testload.rb

debug: $(BUNDLE) testload.rb .gdbinit 

.gdbinit: $(MAKEFILE_LIST)
	echo > $@ "set args testload.rb"
	echo >>$@ "set print demangle"
	echo >>$@ "handle SIGABRT stop"
	gdb -x $@ $(RUBY)

# vim: filetype=make
