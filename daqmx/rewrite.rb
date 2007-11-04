#! ruby
# rewrite NIDAQmxBase.h for SWIG

BEGIN {
  $ignored = %w{
    DAQmxBaseReadBinaryI16 DAQmxBaseReadBinaryI32
    DAQmxBaseReadDigitalU8 DAQmxBaseReadDigitalU32
    DAQmxBaseReadCounterF64 DAQmxBaseReadCounterU32
    }
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
    libname = prefix + suffix

    callArgs = args.collect { |arg|
      arg.sub(/^(.*[ *])([_[:alnum:]]+)( ?\[\] ?)?$/, '\2')
    }
    if hasSelf
      callArgs.unshift('(TaskHandle)$self')
    end
    if /reserved$/.match(args[-1])
      args.pop
      callArgs[-1] = "NULL"
    end

    rubyname = suffix.gsub(/([a-z])([A-Z])/, '\1_\2').downcase

    if hasSelf
      rubyname = rubyname.sub(/_task$/, '')
    end

    # if we haven't figured out how to handle it yet, just skip it
    next if $ignored.include?(libname)

    puts "%ignore #{libname};"

    puts <<EOF
    #{ hasSelf ? "%extend Task" : "%inline" } {
      int32 #{rubyname}(#{args.join(", ")}) {
        int32 result = #{libname}(#{callArgs.join(", ")});
        if (result) handle_DAQmx_error(result);
        return result;
      }
    };
EOF
    next
  end
end

# vim: ai ts=2 sw=2 et
