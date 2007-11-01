#! ruby
# rewrite NIDAQmxBase.h for SWIG

BEGIN {
  puts <<EOF
# Note that TaskHandle is typedef'd as uInt32*
  %inline {
    struct Task { uInt32 handle; };
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
    puts "%rename(#{prefix}#{suffix}) #{rubyname}"
    next
  }

  # Functions
  line.sub(/^int32 DllExport __CFUNC (DAQmxBase_?)([_[:alnum:]]+) *\((.*)\) *; *$/) do |m|
    prefix = $1
    suffix = $2
    args = $3.gsub(/  */,' ').split(/ *, */)
    puts "# #{prefix + suffix}(#{args.join(", ")})"
    hasSelf = (args[0] == "TaskHandle taskHandle")
    args.shift if hasSelf

    callArgs = args.collect { |arg|
      arg.sub(/^(.*[ *])([_[:alnum:]]+)( ?\[\] ?)?$/, '\2')
    }
    if hasSelf
      callArgs.unshift('$self')
    end

    rubyname = suffix.gsub(/([a-z])([A-Z])/, '\1_\2').downcase

    puts <<EOF
    #{ hasSelf ? "%extend Task" : "%inline" } {
      int32 #{rubyname}(#{args.join(", ")}) {
        int32 result = #{prefix}#{suffix}(#{callArgs.join(", ")});
        if (result) handle_error("#{rubyname}", result);
        return result;
      }
    };
EOF
    next
  end
end

  # vim: ai ts=2 sw=2 et
