#===============================================================================================================================
# Synopsis:
#   It finds a path in a text file, compairing text characters to move weights displaying an example of dynamic path finding
#   in a 2 demensional plane of ground passablity tiles.
#
#   Run with:   '     ruby AstarPath.rb      '     (or)      '     ruby AstarPath.rb --map <file_path>    '
#      ruby AstarPath.rb --map ./Media/A_StarPath_big.txt
#
# Information:   http://rubyquiz.com/quiz98.html
#   This was a quiz tutorial taken from the RubyQuiz site from the learning experance. The documentation there provided.
#
# Movement Cost for Terrain:
#   Non-walkable:
#     N/A = Water     (~)
#   Walkable:
#      0  = A node  (@ or X)
#      1  = Flatlands (.)
#      2  = Forest    (*)
#      3  = Mountain  (^)
#   
#   Test Map:
#     @*^^^    @ = User start
#     ~~*~.
#     **...
#     ^..*~
#     ~~*~X    X = The goal tile
#
#===============================================================================================================================
# The Class Container for path finding in 2d Planes.
#===============================================================================================================================
class AstarPath
  MAX_GIVEUP   = 5_000  # max tries until just giving up at finding a path. This helps avoid a 'Stack To Deep' error. 
  STEP_THROUGH = false  # print out the steps taken to find the path to the console to watch.

  attr_reader :node_path, :trys
  #---------------------------------------------------------------------------------------------------------
  def initialize()
    @trys = 0
    @mapData    = []  # load a map, then share it when locating paths accross entities.
    @mapWidth   = 0   # width of the map, also used to avoid using an Array as a two deminsional table.
    @mapHeight  = 0   # the height of the map.
    @node_path  = nil # the solved path to from the start in steps to the goal node.
    @close_enough = 2
    @input_str  = ""
    @string_map = ""
  end
  #---------------------------------------------------------------------------------------------------------
  #D: Take a string, convert it into move weights and stick it into an Array 2 deminsional table.
  #---------------------------------------------------------------------------------------------------------
  def buildmap_weightdata(puzzle_map_string)
    input_str = ""
    column = 0
    # split into characters
    puzzle_map_string.each { |rowstr|
      next if rowstr =~ /^\s*$/
      # only use characters that match terrian types:
      rowstr.gsub!(/[^.@~X*^]/,'')
      # check for column ends, build return route string.
      input_str += rowstr + "\n"
      # convert char flag into move wheight value
      rowstr.scan(/[.@~X*^]/) { |terrain|
        case terrain
        when /[@X]/  then @mapData << 0   #  0  = Nodes        (@ or X)
        when /[.]/   then @mapData << 1   #  1  = Flatlands      (.)
        when /[*]/   then @mapData << 2   #  2  = Forest         (*)
        when /\^/    then @mapData << 3   #  3  = Mountain       (^)
        else 
          @mapData << nil # nil = no pass, water (~)
        end
      }
      @mapWidth = @mapData.length if @mapWidth == 0
      # locate starting/end position in map string data
      aind = rowstr.index('@') # start node
      @start_node = [column, aind] if (aind)
      xind = rowstr.index('X') # end node
      @goal_node = [column, xind] if (xind)
      # keep up with column index, Y
      column += 1
    }
    @mapHeight = column
    # not required, but add some style to the displayed map so its not looking so dull
    puts("Map tile weights calculated. [#{@mapWidth}, #{@mapHeight}] s(#{@start_node}) G(#{@goal_node})")
    row = ""
    @mapData.each() { |tile|
      case tile # not required, but dress it up a bit so its nicer to look at
      when 0 then row += "⏺"
      when 1 then row += " "
      when 2 then row += "⇞"
      when 3 then row += "△"
      else
        row += "⏦"
      end
      if row.length() >= @mapWidth
        @string_map += "#{row}\n"
        row = ""
      end
    }
    # return the map initialize string
    return input_str
  end
  #---------------------------------------------------------------------------------------------------------
  # Not required, but it looks nice. :)
  #---------------------------------------------------------------------------------------------------------
  def self.apply_terminal_colors(string_map)
    string_map.gsub!("#", 
      "#{Logger::TermColor::PURPLE}##{Logger::TermColor::NONE}"
    )
    string_map.gsub!("⏦", 
      "#{Logger::TermColor::LIGHT_BLUE}⏦#{Logger::TermColor::NONE}"
    )
    string_map.gsub!("⇞", 
      "#{Logger::TermColor::GREEN}⇞#{Logger::TermColor::NONE}"
    )
    string_map.gsub!("△", 
      "#{Logger::TermColor::BROWN}△#{Logger::TermColor::NONE}"
    )
    return string_map
  end
  #---------------------------------------------------------------------------------------------------------
  #D: Using a String locate route from 'X' to '@'
  #---------------------------------------------------------------------------------------------------------
  def do_string_file_solution(puzzle_map_string)
    @input_str = buildmap_weightdata(puzzle_map_string)
    if find_path(@start_node, @goal_node)
      # using the input string, convert the path index chars to display answer.
      outarr = @string_map.split(/\n/)
      @node_path.each() { |y, x|
        outarr[y][x] = "#"   # write over path taken from goal to end.
      }
      # print the input map string with the string drawn over with the path anwser.
      answer_path_string = outarr.join("\n")
      answer_path_string = AstarPath.apply_terminal_colors(answer_path_string) # <- add color to make it 'pop'
      puts("Path was located in (#{@node_path.size}) steps and (#{@trys}) tries. MAP:\n\n")
      puts(answer_path_string + "\n\n")
      return answer_path_string
    else
      return nil
    end
  end
  #---------------------------------------------------------------------------------------------------------
  #D: Daniel's way, with his PriorityQueue Array instead of a Ruby Heap.
  #---------------------------------------------------------------------------------------------------------
  def find_path(start_node, goal_node)
    been_there = Set.new()
    initial_progress = [start_node, [], 1] # [current_location, current_path, current_cost]
    qued_path = [1, 1, initial_progress]   # [priority, qued_path_index, progress_nodes]
    pqueue = [qued_path]
    @trys = 0
    while !pqueue.empty? && @trys < AstarPath::MAX_GIVEUP
      # out of the current paths being tried, remove the first attempt
      # from the qued list and continue trying with it, if progress add
      # it back into the que with the new 'step' nodes included.
      spot, path_so_far, cost_so_far = pqueue.shift[2]
      newpath = [path_so_far, spot]
      # if reached the end, return the path nodes to take
      dist_left = (spot[0] - goal_node[0]).abs() + (spot[1] - goal_node[1]).abs()
      if (spot == goal_node || dist_left <= @close_enough)
        @node_path = []
        newpath.flatten.each_slice(2) { |i, j| @node_path << [i, j] }
        return @node_path
      end
      next unless been_there.add?(spot[1] * @mapWidth + spot[0])
      # if not at the end yet, keep searching for a path to it.
      # check if the solution is required to move up or left
      vertadds  = [0, 1]
      horizadds = [0, 1]
      vertadds  << -1 if spot[0] > 0
      horizadds << -1 if spot[1] > 0
      # go threw avaliable move options:
      path_options = []
      vertadds.each{ |v|
        next if v == 0
          horizadds.each{ |h|
          next if h == 0
          new_spot = [spot[0] + v, spot[1] + h]
          # only add if the new_spot exists in the map data set
          # only if the tile can be traversed should its spot be added as a move location
          path_options.push(new_spot) if ( @mapData[new_spot[1] * @mapWidth + new_spot[0]] )
        }
      }
      # debugging
      if STEP_THROUGH
        puts("Dinstance away from target: #{dist_left}")
        Logger.show_path_sofar(@string_map, newpath, pqueue.size(), path_options) 
      end
      # after looking around, check which spot is the best to move onto
      path_options.each { |newspot|
        map_tileid = newspot[1] * @mapWidth + newspot[0]
        next if been_there.include?(map_tileid)
        move_cost = @mapData[map_tileid]
        newcost = (cost_so_far + move_cost) + [
          (newspot[0] - @goal_node[0]).abs(),
          (newspot[1] - @goal_node[1]).abs()
        ].max()
        pqueue.push([newcost, pqueue.size(), [newspot, newpath, newcost]])
        pqueue.sort!
      }
      # give up after too long of trying to avoid a stack too deep error
      @trys += 1
    end
    # did not find a path, tried too hard
    if @trys >= AstarPath::MAX_GIVEUP
      puts("Gave up trying to find a path after trys:(#{@trys})")
    else
      # ran out of path options
      puts("Gave up trying:(#{@trys}) to find a path, PriorityQueue is empty. (#{pqueue.inspect})")
    end
    return nil # no path was found
  end
  #---------------------------------------------------------------------------------------------------------
  def dispose()
    @mapData = []
    @mapWidth = 0
    @input_str = ""
    @string_map = ""
    @node_path = nil
    @disposed = true
  end
end
