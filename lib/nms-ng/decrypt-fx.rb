module NMS_NG
  class DecryptFx

    attr :screen

    # @return elapsed time in ms
    def elapsed
      return 0 if @t_start == 0
      t_now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      (t_now - @t_start) * 1000
    end

    def finished?
      elapsed > NMS_NG::DURATION
    end

    def paint(char, x, y, t_elapsed = 0)
      print @cursor.move_to(x, y)
      #  print "#{x}, #{y}"
      chr = char.get(t_elapsed)
      if char.revealed?
        color = char.color
      else
        color = NMS_NG::TERMINAL_COLOR
      end
      print Paint[chr, color, :bold]
    end

    def type_chars
      system('clear')
      print @cursor.hide
      @t_start = 0
      t_sleep = 0.0008

      screen.rows.each_with_index { |row, y|
        row.each_with_index { |ch, x|
          #print ch.get(elapsed)
          paint ch, x, y, elapsed
          sleep t_sleep
        }
      }

    end

    def run
      #system('clear')
      #print @cursor.hide
      @t_start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      t_sleep = 0.01


      while !screen.revealed?
        screen.rows.each_with_index { |row, y|
          row.each_with_index { |ch, x|
            #print ch.get(elapsed)
            paint ch, x, y, elapsed
          }
        }
      end

      sleep 3
      print @cursor.show
    end

    def initialize(screen, opts = {})
      @screen = screen
      @cursor = TTY::Cursor

    end

  end
end