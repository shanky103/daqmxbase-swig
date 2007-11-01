#! ruby
# rewrite NIDAQmxBase.h for SWIG

BEGIN {
 puts <<EOF
// Note that TaskHandle is typedef'd as uInt32*
%inline{
  struct Task { uInt32 handle; };
};
%{
# include <string.h>
# include <stdlib.h>

  int32 handle_DAQmx_error(const char *funcName, int32 errCode)
  {
    static const char errorSeparator[] = ": ERROR : ";
    static const char warningSeparator[] = ": WARNING : ";
    static const char *separator;
    size_t errorBufferSize;
    size_t prefixLength;
    char *errorBuffer;

    separator = errCode < 0 ? errorSeparator : warningSeparator;
    errorBufferSize = (size_t)DAQmxBaseGetExtendedErrorInfo(NULL, 0);
    prefixLength = strlen(funcName) + strlen(separator);
    errorBuffer = malloc(prefixLength + errorBufferSize);
    strcpy(errorBuffer, funcName);
    strcat(errorBuffer, separator);
    int32 status = DAQmxBaseGetExtendedErrorInfo(errorBuffer + prefixLength,
      (uInt32)errorBufferSize);
    return errCode;
  }
%};
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

    puts "%ignore #{prefix + suffix};"

    puts <<EOF
    #{ hasSelf ? "%extend Task" : "%inline" } {
      int32 #{rubyname}(#{args.join(", ")}) {
        int32 result = #{prefix}#{suffix}(#{callArgs.join(", ")});
        if (result) handle_DAQmx_error("#{rubyname}", result);
        return result;
      }
    };
EOF
    next
  end
end

  # vim: ai ts=2 sw=2 et
