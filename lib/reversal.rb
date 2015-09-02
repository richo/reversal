##
# reversal.rb: decompiling YARV instruction sequences
#
# Copyright 2010 Michael J. Edgar, michael.j.edgar@dartmouth.edu
#
# MIT License, see LICENSE file in gem package

STDERR.puts "Loading reversal!"

module Reversal
  LOADED = false
end

$:.unshift(File.dirname(__FILE__))

module Reversal
  autoload :Instructions, "reversal/instructions"
end

require 'reversal/ir'
require 'reversal/iseq'
require 'reversal/reverser'


module Reversal
  VERSION = "0.9.0"
  def decompile(iseq, klass = nil)
    puts klass.inspect if klass
    Reverser.new(iseq).to_ir.to_s
  end
  module_function :decompile

end

module Reversal
  LOADED = true # Whatever
end

STDERR.puts "Done loading reversal!"
