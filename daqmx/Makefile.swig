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

SWIG?=swig
# TODO: how to find for WinNT distro?
SWIGLIB?=$(shell $(SWIG) -swiglib)
RUBY?=ruby
CYGWIN_VIM?=no

# for .vimrc:
#
RUBYPATH?=$(shell ruby -e 'print $$:.join(",")')
SWIGPATH?=$(SWIGLIB)/ruby,$(SWIGLIB)

ifeq ($(OS),Windows_NT) # Win32
	NI_WIN_DIR?=$(PROGRAMFILES)/National Instruments/NI-DAQmx Base
	NI_WIN_INC_DIR?=$(NI_WIN_DIR)/Include
	LDFLAGS+= -Wl,--export-all-symbols -Wl,-L\"$(NI_DIR)/Lib\" -Wl,--dll-search-prefix=\"\" \"-Wl,--exclude-symbols,\x7fnidaqmxbase_NULL_THUNK_DATA\" --enable-extra-pe-debug 
	LIBS+= -lnidaqmxbase
	OSTYPE?=$(shell uname -o)
	NI_INC_DIR=$(NI_DIR)/Include
	ifeq ($(OSTYPE),Cygwin)
		# Cygwin Win32
		NI_DIR?=$(shell cygpath -u "$(NI_WIN_DIR)")
		CFLAGS+= -mcygwin
		NI_HEADER:=$(shell cygpath -u "$(NI_INC_DIR)/NIDAQmxBase.h")
		ifeq ($(CYGWIN_VIM),no)
			RUBYPATH:=$(shell cygpath -m $(shell ruby -e 'print $$:.join(" ")') | tr '\n' ',')
			SWIGPATH:=$(shell cygpath -m $(SWIGLIB)/ruby $(SWIGLIB) | tr '\n' ',')
		endif	# not CYGWIN_VIM
	else	# OSTYPE not Cygwin, but still Win32
		NI_DIR?=$(NI_WIN_DIR)
		CFLAGS+= -mno-cygwin
	endif	# OSTYPE Cygwin
else # not Windows_NT
	OSTYPE?=$(shell uname -s)
	ifeq ($(OSTYPE),Darwin)
		# Mac OS/X
		NI_DIR?=/Applications/National Instruments/NI-DAQmx Base
		NI_INC_DIR=$(NI_DIR)/includes
		LIBS+= -framework nidaqmxbase -framework nidaqmxbaselv
	else # OS not Windows_NT, not Darwin either
	endif # OSTYPE Darwin
endif # OS Windows_NT

# quote spaces
NI_DIR:=$(subst /\,,$(patsubst %,%\,$(NI_DIR)/))
NI_WIN_INC_DIR:=$(subst :\,:/,$(subst /\,,$(patsubst %,%\,$(NI_WIN_INC_DIR)/)))
SPACE= #space here

NI_HEADER:=$(subst /\,,$(patsubst %,%\,$(NI_HEADER)/))

# -debug_typemap -Wall -w322
SWIG_OPTS+= -v -ruby -Fstandard  -dump_typedef -dump_classes
CPPFLAGS+= -I \"$(NI_INC_DIR)\"
CFLAGS+= -g -Wall -Wno-redundant-decls

MODULE=daqmxbase
FEATURE=Daqmxbase
SPACE= #space
INTERFACE=$(MODULE).i
WRAPPER=$(MODULE)_wrap.c
DECLS=$(MODULE)_decls.i
 
.PHONY: all install clean test debug dll
.PRECIOUS: $(DECLS) .vimrc

all: dll .vimrc

.vimrc: $(MAKEFILE_LIST)
ifeq ($(CYGWIN_VIM),no)
	echo  >$@ 'set path+=$(subst \ ,\\ ,$(subst \,\\,$(NI_WIN_INC_DIR)))'
else
	echo  >$@ 'set path+=$(subst \,\\\,$(NI_INC_DIR))'
endif
	echo >>$@ 'set path+=$(RUBYPATH)'
	echo >>$@ 'set path+=$(SWIGPATH)'
	echo >>$@ 'set makeprg=make\ -f\ Makefile.swig'
	echo >>$@ 'set isfname+=\ '
	echo >>$@ 'set errorformat^=%f:%l:\ %m'
	echo >>$@ 'au BufNewFile,BufRead Makefile* setf make'
	echo >>$@ 'au BufNewFile,BufRead *.i setf swig'

dll: Makefile
	$(MAKE) all

install: Makefile
	$(MAKE) install

Makefile: $(WRAPPER) extconf.rb
	$(RUBY) -r mkmf extconf.rb

$(WRAPPER): $(DECLS) $(INTERFACE)
	$(SWIG) $(SWIG_OPTS) -I$(NI_INC_DIR) -o $@ $(INTERFACE)

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
		$(MAKE) -f Makefile clean;\
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

# vim: ft=make ts=2 sw=2
