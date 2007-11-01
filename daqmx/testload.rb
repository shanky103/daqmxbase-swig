# $Id$

require "daqmxbase"
$stdout.sync=true

def printDerived(klass)
  puts "\n#{klass.name} has parents #{klass.ancestors.inspect}"

  puts "\nNew #{klass.name} methods"
  p klass.methods - klass.class.methods
  puts ""

  puts "\nNew #{klass.name} instance methods"
  p klass.instance_methods - klass.class.instance_methods
  puts ""

  puts "\nNew #{klass.name} constants"
  p klass.constants - klass.class.constants
  puts ""
end

printDerived(Daqmxbase)
printDerived(Daqmxbase::Task)
