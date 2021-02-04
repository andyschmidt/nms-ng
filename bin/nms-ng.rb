if $0 == __FILE__
  inc_path = File.expand_path(File.join(File.dirname(__FILE__), "..", "lib")) # this is the same as rubygems would do
  $: << inc_path
end

require 'nms-ng'
require 'optimist'

OPTS = Optimist::options do
  version "#{$0} 1.0 (c) 2021 Andreas Schmidt"
  opt :width, "chars width", :type => :integer, :default => TTY::Screen.width
  opt :height, "chars height", :type => :integer, :default => TTY::Screen.height
  opt :center, "horizontal center", :default => false
  opt :duration, "duration", :type => :integer, :default => 5000
  opt :tfgc, "foreground color of terminal", :type => :string, :default => 'green'
  opt :secret_colors, "colors of secret text, can be multiple. respect order of filenames", :type => :string, :multi => true
#  opt :options, "Order options: ruby array, filename or string", :type => :string, :default => ''
#  opt :ebics, "EBICS version, e.g. 3, 25 [default]", :type => :string, :default => '25'
end

file = ARGV[0]
NMS_NG::DURATION = OPTS[:duration]
NMS_NG::SCREEN_CENTERED = OPTS[:center]
NMS_NG::SCREEN_WIDTH = OPTS[:width]
NMS_NG::SCREEN_HEIGHT = OPTS[:height]
NMS_NG::TERMINAL_COLOR = OPTS[:tfgc]
NMS_NG::PRINTABLES = ["!", "\"", "#", "$", "%", "&", "'", "(", ")", "*", "+", ",", "-", "~",
                      ".", "/", ":", ";", "<", "=", ">", "?", "[", "\\", "]", "_", "{", "}",
                      "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
                      "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
                      "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
                      "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
                      "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
                      "\xc3\x87", "\xc3\xbc", "\xc3\xa9", "\xc3\xa2", "\xc3\xa4", "\xc3\xa0",
                      "\xc3\xa5", "\xc3\xa7", "\xc3\xaa", "\xc3\xab", "\xc3\xa8", "\xc3\xaf",
                      "\xc3\xae", "\xc3\xac", "\xc3\x84", "\xc3\x85", "\xc3\x89", "\xc3\xa6",
                      "\xc3\x86", "\xc3\xb4", "\xc3\xb6", "\xc3\xb2", "\xc3\xbb", "\xc3\xb9",
                      "\xc3\xbf", "\xc3\x96", "\xc3\x9c", "\xc2\xa2", "\xc2\xa3", "\xc2\xa5",
                      "\xc6\x92", "\xc3\xa1", "\xc3\xad", "\xc3\xb3", "\xc3\xba", "\xc3\xb1",
                      "\xc3\x91", "\xc2\xaa", "\xc2\xba", "\xc2\xbf", "\xc2\xac", "\xc2\xbd",
                      "\xc2\xbc", "\xc2\xa1", "\xc2\xab", "\xc2\xbb", "\xce\xb1", "\xc3\x9f",
                      "\xce\x93", "\xcf\x80", "\xce\xa3", "\xcf\x83", "\xc2\xb5", "\xcf\x84",
                      "\xce\xa6", "\xce\x98", "\xce\xa9", "\xce\xb4", "\xcf\x86", "\xce\xb5",
                      "\xc2\xb1", "\xc3\xb7", "\xc2\xb0", "\xc2\xb7", "\xc2\xb2", "\xc2\xb6",
                      "\xe2\x8c\x90", "\xe2\x82\xa7", "\xe2\x96\x91", "\xe2\x96\x92",
                      "\xe2\x96\x93", "\xe2\x94\x82", "\xe2\x94\xa4", "\xe2\x95\xa1",
                      "\xe2\x95\xa2", "\xe2\x95\x96", "\xe2\x95\x95", "\xe2\x95\xa3",
                      "\xe2\x95\x91", "\xe2\x95\x97", "\xe2\x95\x9d", "\xe2\x95\x9c",
                      "\xe2\x95\x9b", "\xe2\x94\x90", "\xe2\x94\x94", "\xe2\x94\xb4",
                      "\xe2\x94\xac", "\xe2\x94\x9c", "\xe2\x94\x80", "\xe2\x94\xbc",
                      "\xe2\x95\x9e", "\xe2\x95\x9f", "\xe2\x95\x9a", "\xe2\x95\x94",
                      "\xe2\x95\xa9", "\xe2\x95\xa6", "\xe2\x95\xa0", "\xe2\x95\x90",
                      "\xe2\x95\xac", "\xe2\x95\xa7", "\xe2\x95\xa8", "\xe2\x95\xa4",
                      "\xe2\x95\xa7", "\xe2\x95\x99", "\xe2\x95\x98", "\xe2\x95\x92",
                      "\xe2\x95\x93", "\xe2\x95\xab", "\xe2\x95\xaa", "\xe2\x94\x98",
                      "\xe2\x94\x8c", "\xe2\x96\x88", "\xe2\x96\x84", "\xe2\x96\x8c",
                      "\xe2\x96\x90", "\xe2\x96\x80", "\xe2\x88\x9e", "\xe2\x88\xa9",
                      "\xe2\x89\xa1", "\xe2\x89\xa5", "\xe2\x89\xa4", "\xe2\x8c\xa0",
                      "\xe2\x8c\xa1", "\xe2\x89\x88", "\xe2\x88\x99", "\xe2\x88\x9a",
                      "\xe2\x81\xbf", "\xe2\x96\xa0"]

#screen = NMS_NG::Screen.new file, color: NMS_NG::TERMINAL_COLOR
@screen = nil
puts "ARGV"
puts ARGV[0]
ARGV.each_with_index do |file, i|
  sec_color = !!OPTS[:secret_colors][i] ? OPTS[:secret_colors][i].to_sym : NMS_NG::TERMINAL_COLOR
  if i == 0
    puts "create first"
    @screen = NMS_NG::Screen.new file, sec_color: sec_color
  else
    puts 'append'
    @screen.concat NMS_NG::Screen.new(file, sec_color: sec_color)
  end
end
@screen.finish
fx = NMS_NG::DecryptFx.new(@screen)
#exit
fx.type_chars
fx.run






