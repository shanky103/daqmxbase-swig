#! ruby
# rewrite NIDAQmxBase.h for SWIG

BEGIN {
 puts <<'EOF'
// $Id$
// Note that TaskHandle is typedef'd as uInt32*
// so here &someTask is equivalent to a TaskHandle.
%inline{
  typedef struct Task { uInt32 handle; } Task;
};
%{
# include <string.h>
# include <stdlib.h>
# include "ruby.h"

  int32 handle_DAQmx_error(int32 errCode)
  {
    static const char errorSeparator[] = "ERROR : ";
    static const char warningSeparator[] = "WARNING : ";
    static const char *separator;
    size_t errorBufferSize;
    size_t prefixLength;
    char *errorBuffer;

    if (errCode == 0)
      return 0;

    separator = errCode < 0 ? errorSeparator : warningSeparator;
    errorBufferSize = (size_t)DAQmxBaseGetExtendedErrorInfo(NULL, 0);
    prefixLength = strlen(separator);
    errorBuffer = malloc(prefixLength + errorBufferSize);
    strcat(errorBuffer, separator);
    DAQmxBaseGetExtendedErrorInfo(errorBuffer + prefixLength, (uInt32)errorBufferSize);
    if (errCode < 0)
      rb_raise(rb_eRuntimeError, errorBuffer);
    else if (errCode > 0)
      rb_raise(rb_eException, errorBuffer);

    return errCode;
  }
%};

// pass string and size to C function
%typemap(in) (char *str, int len) {
  $1 = STR2CSTR($input);
  $2 = (int) RSTRING($input)->len;
};

// pass array and size to C function
%typemap(in) (float64 readArray[], uInt32 arraySizeInSamps) {
  $1 = (float64 *) RARRAY($input)->ptr;
  $2 = (uInt32) RARRAY($input)->len;
};

%extend Task {
  // if you give a non-empty name, you get LoadTask, else CreateTask.
  Task(const char taskName[]) {
    Task *t = (Task *)calloc(1, sizeof(Task));
    int32 result;
    if (&taskName[0] == NULL || taskName[0] == '\0')
      result = DAQmxBaseCreateTask(taskName, (TaskHandle *)&t);
    else
      result = DAQmxBaseLoadTask(taskName, (TaskHandle *)&t);
    if (result) handle_DAQmx_error(result);
    return t;
  }
  ~Task() {
    int32 result = DAQmxBaseStopTask((TaskHandle)$self);
    result = DAQmxBaseClearTask((TaskHandle)$self);
    free($self);
  }
};
EOF
}

ARGF.each_line do |line|
  line.gsub!(/[[:blank:]]+/, ' ')

  # Constants
  line.sub(/^#define (DAQmx_?)([_[:alnum:]]+) .*/) { |m|
    prefix = $1
    suffix = $2
    rubyname = suffix.gsub(/([a-z])([A-Z])/, '\1_\2').upcase
    puts "%rename(\"#{rubyname}\") #{prefix + suffix};"
    next
  }

  # Functions
  line.sub(/^int32 DllExport __CFUNC (DAQmxBase_?)([_[:alnum:]]+) *\((.*)\) *; *$/) do |m|
    prefix = $1
    suffix = $2
    args = $3.gsub(/  */,' ').split(/ *, */)
    puts "// #{prefix + suffix}(#{args.join(", ")})"
    hasSelf = (args[0] == "TaskHandle taskHandle")
    args.shift if hasSelf

    callArgs = args.collect { |arg|
      arg.sub(/^(.*[ *])([_[:alnum:]]+)( ?\[\] ?)?$/, '\2')
    }
    if hasSelf
      callArgs.unshift('(TaskHandle)$self')
    end

    rubyname = suffix.gsub(/([a-z])([A-Z])/, '\1_\2').downcase

    if hasSelf
      rubyname = rubyname.sub(/_task$/, '')
    end

    puts "%ignore #{prefix + suffix};"

    puts <<EOF
    #{ hasSelf ? "%extend Task" : "%inline" } {
      int32 #{rubyname}(#{args.join(", ")}) {
        int32 result = #{prefix}#{suffix}(#{callArgs.join(", ")});
        if (result) handle_DAQmx_error(result);
        return result;
      }
    };
EOF
    next
  end
end

# vim: ai ts=2 sw=2 et
