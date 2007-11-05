# $Id$
#
# Makefile to generate C wrappers using SWIG
# usage:
# 	make -f Makefile.swig
# 	make -f Makefile.swig install
# 	make -f Makefile.swig clean
#
# ruby-daqmxbase: A SWIG interface for Ruby and the NI-DAQmx Base data
# acquisition library.
# 
# Copyright (C) 2007 Ned Konz
# 
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License.  You may obtain a copy
# of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations under
# the License.
#
SWIG=/opt/local/bin/swig
RUBY=/opt/local/bin/ruby

NI_DIR:=/Applications/National Instruments/NI-DAQmx Base
NI_INC_DIR:=$(NI_DIR)/includes
NI_HEADER:=/Applications/National\ Instruments/NI-DAQmx\ Base/includes/NIDAQmxBase.h

# -debug_typemap -Wall -w322
SWIG_OPTS+=-ruby -Fstandard 
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
.PRECIOUS: $(DECLS)

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
