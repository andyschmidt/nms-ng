module NMS_NG
  class Screen
    attr :rows

    ANSI_ESCAPE = /((?:\e(?:[ -\/]+.|[\]PX^_][^\a\e]*|\[[0-?]*.|.))*)(.?)/m
    INCOMPLETE_ESCAPE = /\e(?:[ -\/]*|[\]PX^_][^\a\e]*|\[[0-?]*)$/

    def rainbow(freq, i)
      red   = Math.sin(freq*i + 0) * 127 + 128
      green = Math.sin(freq*i + 2*Math::PI/3) * 127 + 128
      blue  = Math.sin(freq*i + 4*Math::PI/3) * 127 + 128
      "#%02X%02X%02X" % [ red, green, blue ]
    end

    def revealed?
      @rows.each do |row|
        row.each do |chr|
          return false unless chr.revealed?
        end
      end
      true
    end

    def empty_row
      row = []
      NMS_NG::SCREEN_WIDTH.times do
        row << NMS_NG::CharFx.new(' ', color: :black)
      end
      row
    end
    #
    def finish(opts={})
      while @rows.length < NMS_NG::SCREEN_HEIGHT
        @rows << empty_row
      end

    end

    def concat(screen)
      screen.rows.each do |row|
        @rows << row
      end
    end

    def initialize(file, opts = {})
      @raw = File.readlines(file)
      @rows_max = NMS_NG::SCREEN_HEIGHT
      @cols_max = NMS_NG::SCREEN_WIDTH
      @rows = []

      @color = opts[:color]
      @sec_color = opts[:sec_color]
      @effects = opts[:effects]
      @align_center = !!opts[:center] ? opts[:center] : NMS_NG::SCREEN_CENTERED

      if $VERBOSE
        puts "Create Screen Centered: #{ @align_center ? "Y" : "N"}"
        puts "Screen Width: #{@cols_max}"
        puts "Screen Height: #{@rows_max}"
      end

      # first we need to get the longest lines without trailing whitespaces
      max_len = @raw.map{ |l| l.rstrip.length }.max

      @raw.each do |line|
        @rows << []
        cols = @rows.last
        puts "Length: #{line.length}"
        # calculate the fill chars if output is centered
        if NMS_NG::SCREEN_CENTERED
          fill_chars = ' ' * ((@cols_max - max_len) / 2)
          sline = fill_chars.dup
          sline << line.rstrip.dup
          sline << ' ' * (max_len - line.rstrip.length)
          sline << fill_chars.dup
          while sline.length < @cols_max
            sline << ' '
          end

        else
          fill_chars = ' ' * (@cols_max - line.length)
          sline = line.chomp
          sline << fill_chars
        end

        sline.each_char do |ch|
          cols << NMS_NG::CharFx.new(ch, color: @sec_color)
        end

      end
    end
  end
end