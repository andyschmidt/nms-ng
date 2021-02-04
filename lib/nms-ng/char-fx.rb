module NMS_NG
  class CharFx

    attr :color

    def get(progress)
      if progress > @tdecrypt
        @revealed = true
        return @char
      else
        char_mask(progress)
      end
    end

    def char_mask(progress)
      @mask ||= NMS_NG::PRINTABLES[rand(NMS_NG::PRINTABLES.length - 1)]
      pseudo = progress / NMS_NG::DURATION * 10.0
      if rand(pseudo.to_i * 2) == 0
        @mask = NMS_NG::PRINTABLES[rand(NMS_NG::PRINTABLES.length - 1)]
      end
      @mask
    end

    def revealed?
      @revealed
    end


    def initialize(char, opts = {})
      @char = char
      @color = !!opts[:color] ? opts[:color] : :green
      @tdecrypt = char == ' ' ? (rand(1000) + 1000) : ( rand(1500) + 1500 )
      @revealed = false
        # puts "''#{char}'' : #{@tdecrypt}"
    end
  end
end