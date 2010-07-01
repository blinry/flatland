require "shapes"

class View
    attr_reader :pos, :rot
    def initialize
        @pos = Vec2.new(0, 0)
        @rot = 90
    end
    def right!
        rotate -1
    end
    def left!
        rotate 1
    end
    def forward!
        move 1
    end
    def back!
        move -1
    end
    def move units
        @pos.y += Math::cos(@rot/180.0*Math::PI)*units
        @pos.x += Math::sin(@rot/180.0*Math::PI)*units
    end
    def rotate degree
        @rot += degree
        if @rot > 360
            @rot -= 360
        end
        if @rot < 0
            @rot += 360
        end
    end
end

class ASCIIView < View
    def draw points
        len = 50
        fov = 30.0
        string = " "*len
        points.each do |point|
            @pos.angle_to(point)
            coordinate = (@rot + fov/2 - @pos.angle_to(point))/fov*len
            if coordinate >= 0 and coordinate < len
                string[coordinate.to_i] = "*"
            end
        end
        #system "clear"
        print "["+string+"]"+"\n\r"
    end
end

points = []

points << Vec2.new(10,1)
points << Vec2.new(10,-1)
points << Vec2.new(11,1)
points << Vec2.new(11,-1)

camera = ASCIIView.new

system("stty -echo raw")

loop do
    camera.draw points
    char = STDIN.getc.chr
    case char
    when "d"
        camera.right!
    when "a"
        camera.left!
    when "w"
        camera.forward!
    when "s"
        camera.back!
    when "q"
        exit
    end
end
