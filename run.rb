#!/usr/bin/env ruby
#===============================================================================================================================
# Run some pathfinding tests:
# Solve a puzzle to test the A_StarPath object's ability with text file based map navigation.
#===============================================================================================================================
require 'benchmark' # https://ruby-doc.org/stdlib-1.9.3/libdoc/benchmark/rdoc/Benchmark.html
# https://blog.appsignal.com/2018/02/27/benchmarking-ruby-code.html

require 'set' # A much faster method added after Ruby 2.4 for searching a collection of unique objects.
require "./Logger"
require "./AstarPath"

#===============================================================================================================================
BASIC_MAP = false  # use the map that is programically created at the end of this file.
if BASIC_MAP
  puzzle_map_string = []
  puzzle_map_string << "X*^^^"  #  @ = User start
  puzzle_map_string << "~~*~."  
  puzzle_map_string << "**..."
  puzzle_map_string << "^..*~"
  puzzle_map_string << "~~*~@"  #  X = The goal tile
  
  pathfinder = AstarPath.new()
  pathfinder.do_string_file_solution(puzzle_map_string)
  pathfinder.clear_map_data()

  return
end

#===============================================================================================================================
# Now find a path from a larger map.
pathfinder = AstarPath.new()
puzzle_map_string = []

begin
  case ARGV.first
  when "--map"
    loadTextmap = "./StringMaps/" + ARGV[ARGV.index(ARGV.first) + 1]
  when nil
    loadTextmap = "./StringMaps/big_edge.txt" # A_StarPath_middle.txt
  end
  puts("Using map to pathfind in: '#{loadTextmap}'")
  file = File.open(loadTextmap).read()
  file.each_line do |line|
    puzzle_map_string << line
  end
rescue => error
  puts "There was an error reading '#{loadTextmap}',\n(#{error.inspect})"
  return
end
#-------------------------------------------------------------------------------------------------------------------------------
puts("------------------------------------------------------------------\n")
puts("Speed Test:")
puts("------------------------------------------------------------------\n")
s = Benchmark.measure { 
  pathfinder.do_string_file_solution(puzzle_map_string)
}
puts("------------------------------------------------------------------\n")
puts("\t\t\tuser\tsystem\ttotal\t(  real)\n")
puts("Work time taken: #{s}")
pathfinder.dispose()
puts("------------------------------------------------------------------\n")
