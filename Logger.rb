#===============================================================================================================================
# Mostly to make the terminal debugging look more apealing.
#===============================================================================================================================
module Logger
  module TermOps
    CLEAR = "\033[2J"
  end
  #---------------------------------------------------------------------------------------------------------
  module TermColor
    NONE         = "\e[0m"
    BLACK        = "\e[0;30m"
    GRAY         = "\e[1;30m"
    RED          = "\e[0;31m"
    LIGHT_RED    = "\e[1;31m"
    GREEN        = "\e[0;32m"
    LIGHT_GREEN  = "\e[1;32m"
    BROWN        = "\e[0;33m"
    YELLOW       = "\e[1;33m"
    BLUE         = "\e[0;34m"
    LIGHT_BLUE   = "\e[1;34m"
    PURPLE       = "\e[0;35m"
    LIGHT_PURPLE = "\e[1;35m"
    CYAN         = "\e[0;36m"
    LIGHT_CYAN   = "\e[1;36m"
    LIGHT_GRAY   = "\e[0;37m"
    WHITE        = "\e[1;37m"
  end
  #---------------------------------------------------------------------------------------------------------
  # Show all the font characters by dumping them to file. 'OCR-A' graphenes
  #---------------------------------------------------------------------------------------------------------
  module UNICODE
    # Ranges of known Unicode groups
    CONTROL_PICTURES = 0x2400..0x243f
    ARROWS           = 0x2190..0x21ff
    BOX_DRAWING      = 0x2500..0x257f
    DINGBATS         = 0x2700..0x27bf
    BLOCK_ELEMENTS   = 0x2580..0x259f
    GEOMETRIC_SHAPES = 0x25a0..0x25ff
    MISC_TECHNICAL   = 0x2300..0x23ff
    IDEOGRAPHIC      = 0x2ff0..0x2fff
    MISC_SYMBOLS     = 0x2600..0x26ff
    ENCLOSED_ALPHANUMERICS = 0x2460..0x24ff
    # search by section sybol
    Section = {
      :control_pictures => CONTROL_PICTURES,
      :arrows           => ARROWS,
      :box_drawing      => BOX_DRAWING,
      :dingbats         => DINGBATS,
      :block_elements   => BLOCK_ELEMENTS,
      :geometric_shapes => GEOMETRIC_SHAPES,
      :misc_technical   => MISC_TECHNICAL,
      :ideographic      => IDEOGRAPHIC,
      :misc_symbols     => MISC_SYMBOLS,
      :enclosed_alphanumerics => ENCLOSED_ALPHANUMERICS
    }
  end
  #---------------------------------------------------------------------------------------------------------
  def self.dump_graphenes()
    UNICODE::Section.each() { |key, range|
      message = "#{key.inspect} Characters\n\tIndex |\tGraphene  |\tHex   |\r"
      size = range.max() - range.min()
      size.times() { |c|
        i = range.min() + c
        index = "#{i}".ljust(7, " ")
        character = "#{[i].pack("U*")}"
        hex_value = "0x#{i.to_s(16).rjust(4, "0")}".center(4, " ")
        message += "#{index} |\t#{character.center(9, " ")} |\t#{hex_value} |\r"
      }
      File.open("./graphenes/OCR-A_graphenes(#{key.to_s()}).txt", 'wb') {|l| l.write(message) } # 'wb' 'a'
    }
  end
  #---------------------------------------------------------------------------------------------------------
  # Show all the font characters by dumping them to file. 'ASCII'
  #---------------------------------------------------------------------------------------------------------
  def self.dump_asci_tileset()
    message = "ASCII Characters\n\tIndex |\tCharacter  |\tHex   |\r"
    256.times() { |i|
      index = "#{i}".ljust(7, " ")
      character = "#{i.chr()}"
      if i == 9
        character = "TAB" # line indent
      elsif i == 10
        character = "-lF" # line feed
      elsif i == 13
        character = "-cR" # carrage return
      end
      hex_value = "0x#{i.to_s(16)}".center(4, " ")
      message += "#{index} |\t#{character.center(9, " ")} |\t#{hex_value} |\r"
    }
    File.open("./graphenes/ASCII_characters.txt", 'wb') {|l| l.write(message) } # 'wb' 'a'
  end
  #---------------------------------------------------------------------------------------------------------
  def self.show_path_sofar(map, node_path, paths_tried, avaliable_moves)
    path = []
    node_path.flatten.each_slice(2) { |i, j| path << [i, j] }
    outarr = map.split(/\n/)
    path.each() { |row, col| outarr[row][col] = "#" }
    map_string = outarr.join("\n")
    puts("Took #{path.size} steps, paths tried:(#{paths_tried}) #{avaliable_moves}\n")
    map_string = AstarPath.apply_terminal_colors(map_string) # add color
    puts(map_string)
    await_step = gets()
    puts("#{TermOps::CLEAR}")
  end
end
