#!/usr/bin/env ruby
#
# Huffman encoder/decoder. See:
# http://en.nerdaholyc.com/huffman-coding-on-a-string/

require 'optparse'
require 'pp'

require './coder.rb'

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

if ARGV.length == 0
  puts "You must specify some text to #{options['mode']}"
  Kernel::exit(FALSE)
end

case options['mode']
  when :encode
    encoded = HuffmanCoder::encode(ARGV.join(" "))
    puts encoded.to_s # encoded binary string
  when :decode
    puts HuffmanCoder::decode(ARGV.join(" ")).plaintext
  else
    puts "Invalid mode"
    Kernel::exit(FALSE)
end
