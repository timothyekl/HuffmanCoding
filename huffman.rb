#!/usr/bin/env ruby
#
# Huffman encoder/decoder. See:
# http://en.nerdaholyc.com/huffman-coding-on-a-string/

require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: huffman.rb [options]"

  opts.on("-m", "--mode MODE", [:encode, :decode], "Set the mode: encode/decode") do |m|
    options['mode'] = m
  end
end.parse!

if options['mode'].nil?
  puts "You must specify a mode: encode/decode"
  Kernel::exit(FALSE)
end

puts "Mode is #{options['mode']}"
