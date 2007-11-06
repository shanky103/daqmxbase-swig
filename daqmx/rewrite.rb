#! ruby
# rewrite.rb: Prepares SWIG declarations from NIDAQmxBase.h
# $Id$

# ruby-daqmxbase: A SWIG interface for Ruby and the NI-DAQmx Base data
# acquisition library.
# 
# Copyright (C) 2007 Ned Konz
# 
# Licensed under the Apache License, Version 2.0 (the "License"); you
# may not use this file except in compliance with the License.  You may
# obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.  See the License for the specific language governing
# permissions and limitations under the License.

# Does a few things:
# * generates %rename statements for the constants
# * filters out non-wrapped calls using %ignore
# * generates trivial wrappers for supported calls
#

BEGIN {
  # these calls will not be wrapped, because they're not yet supported.
  $ignored = %w{
    DAQmxBaseReadBinaryI16 DAQmxBaseReadBinaryI32
    DAQmxBaseReadDigitalU8 DAQmxBaseReadDigitalU32
    DAQmxBaseReadCounterF64 DAQmxBaseReadCounterU32
    }
  puts("# Automatically generated from NIDAQmxBase.h header file.")
  puts("# Do not edit.")
}

ARGF.each_line do |line|
  line.chomp!
  line.gsub!(/\s+/, ' ')
  line.gsub!(/DAQmxReadBinaryI32/, "DAQmxBaseReadBinaryI32")  # patch typo

  # Constants
  line.sub(/^#define\s+(DAQmx_?)([_[:alnum:]]+)\s.*/) { |m|
    prefix = $1
    suffix = $2
    rubyname = suffix.gsub(/([a-z])([A-Z])/, '\1_\2').upcase
    puts "%rename(\"#{rubyname}\") #{prefix + suffix};"
    next
  }

  # Functions
  line.sub(/^int32\s+DllExport\s+__CFUNC\s+(DAQmxBase_?)([_[:alnum:]]+)\s*\((.*)\)\s*;\s*$/) do |m|
    prefix = $1
    suffix = $2
    libname = prefix + suffix
    args = $3.gsub(/\s+/,' ').split(/\s*,\s*/)
    callArgs = args.collect { |arg| arg.sub(/.*?([[:alnum:]_]+)[^[:alnum:]_]*$/, '\1') }
    callArgs.delete("taskHandle")
    puts "// extern int32 #{libname}(#{args.join(", ")});"
    hasSelf = (args[0] == "TaskHandle taskHandle")
    args.shift if hasSelf

    rubyname = suffix.gsub(/([a-z])([A-Z])/, '\1_\2').downcase

    if hasSelf
      rubyname = rubyname.sub(/_task$/, '')
      callArgs.unshift("(TaskHandle)(void *)$self")
    end

    # if we haven't figured out how to handle it yet, just skip it
    if $ignored.include?(libname)
      puts "%ignore #{libname};"
      next
    end

    if hasSelf
      puts <<EOF
%ignore #{libname};
%extend Task {
  int32 #{rubyname}(#{args.join(", ")})
    { return #{libname}(#{callArgs.join(", ")}); }
};
EOF
    else
      puts <<EOF
%rename(\"#{rubyname}\") #{libname};
%inline { int32 #{libname}(#{args.join(", ")}); };
EOF
    end

    next
  end
end

# vim: ai ts=2 sw=2 et
