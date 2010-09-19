class Vec2
    def initialize x,y
        @x=x.to_f
        @y=y.to_f
        self
    end
    attr_accessor :x,:y
    def == vec
        @x==vec.x and @y==vec.y
    end
    def Vec2.[] x,y
        Vec2.new(x,y)
    end
    def to_a
        [@x,@y]
    end
    def inspect
        "(#@x|#@y)"
    end
    def abs
        Math.sqrt(@x**2+@y**2)
    end
    def + vec
        Vec2[@x+vec.x,@y+vec.y]
    end
    def - vec
        Vec2[@x-vec.x,@y-vec.y]
    end
    def * n
        Vec2[@x*n,@y*n]
    end
    def / n
        Vec2[@x/n.to_f,@y/n.to_f]
    end
    def -@
        Vec2[-@x,-@y]
    end
    def angle_to other
        Math::atan2(other.x-@x, other.y-@y)/Math::PI*180
    end
end

class Array
    def to_v
        Vec2[self[0],self[1]]
    end
end

class Line
    attr_reader :from, :to
    def initialize from, to
        @from = from
        @to = to
    end
    def length
        if @from == @to
            0
        else
            Math::sqrt((@from.x-@to.x)**2+(@from.y-@to.y)**2)
        end
    end
    def collides? shape
        a = Line.check_clockwise(@from, @to, shape.from)
        b = Line.check_clockwise(@from, @to, shape.to)
        if a != b
            a = Line.check_clockwise(shape.from, shape.to, @from)
            b = Line.check_clockwise(shape.from, shape.to, @to)
            if a != b
                return true
            end
        end
        return false
    end
    private
    def Line.check_clockwise p1, p2, p3
        foo = ((p2.x-p1.x)*(p3.y-p1.y)) - ((p3.x-p1.x)*(p2.y-p1.y))
        if foo < 0
            true
        elsif foo > 0
            false
        else
            nil
        end
    end
end

class Rect
    def initialize size,center=[0,0]
        @size=size.to_v
        @pos=center.to_v
        self
    end
    attr_accessor :size
    def center
        @pos
    end
    def width
        @size.x
    end
    def height
        @size.y
    end
    def top
        @pos.y-@size.y/2.0
    end
    def bottom
        @pos.y+@size.y/2.0
    end
    def right
        @pos.x+@size.x/2.0
    end
    def left
        @pos.x-@size.x/2.0
    end
    def topleft
        Vec2[left,top]
    end
    def topleft= vec
        @pos=vec+@size/2
        self
    end
    def topright
        Vec2[right,top]
    end
    def bottomright
        Vec2[right,bottom]
    end
    def bottomright= vec
        @pos=vec-@size/2
        self
    end
    def bottomleft
        Vec2[left,bottom]
    end
    def collides? shape
        case shape.class
        when Vec2
            return (shape.x > left and shape.x < right and shape.y > top and shape.y < bottom)
        when Rect
            return (right>shape.left and left<shape.right and bottom>shape.top and top<shape.bottom)
        when Circle
            #TODO
        end
    end
end

class Circle
    def initialize pos, radius
        @pos=pos
        @radius=radius
        self
    end
    attr_accessor :pos,:radius
    def center
        @pos
    end
    def diameter
        @radius*2
    end
    #TODO: doesn't work
    def collides? shape
        case shape.class
        when Vec2
            return (Math.sqrt((shape.x-@pos.x)**2+(shape.y-@pos.y)**2)<@radius)
        else
            raise ArgumentError, "can't collide with a #{shape.class}"
        end
    end
end
