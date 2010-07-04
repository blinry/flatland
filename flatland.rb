require "shapes"

class View
    attr_reader :pos, :rot
    def initialize
        @pos = Vec2.new(0, -5)
        @rot = 0
    end
    def right!
        rotate 3
    end
    def left!
        rotate -3
    end
    def forward!
        move 0.1
    end
    def back!
        move -0.1
    end
    def move units
        @pos.x += Math::cos((@rot+90)/180.0*Math::PI)*units
        @pos.y += Math::sin((@rot+90)/180.0*Math::PI)*units
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

class Wall < Line
    attr_reader :color
    def initialize from, to, color
        super from, to
        @color = color
    end
end

$lines = []

5.times do
    range = 10
    x = rand(range*2)-range
    y = rand(range*2)-range

    a = Vec2.new(x-1,y-1)
    b = Vec2.new(x-1,y+1)
    c = Vec2.new(x+1,y+1)
    d = Vec2.new(x+1,y-1)

    col = [rand, rand, rand]
    [[a,b],[b,c],[c,d],[d,a]].each do |from, to|
        $lines << Wall.new(from, to, col)
    end
end

$camera = View.new

require "rubygems"
require "opengl"


def setup
    glutInit
    glutInitDisplayMode(GLUT_SINGLE | GLUT_RGBA)
    glutInitWindowSize(800,300)
    glutCreateWindow


    glFogi(GL_FOG_MODE,GL_LINEAR)
    glFogfv(GL_FOG_COLOR, [0,0,0])
    glFogf(GL_FOG_DENSITY, 0.35)
    glHint(GL_FOG_HINT, GL_DONT_CARE)
    glFogf(GL_FOG_START, 0.1)
    glFogf(GL_FOG_END, 3)

    #glEnable(GL_FOG)


    glClearColor(0.0, 0.0, 0.0, 0.0);
    glMatrixMode(GL_PROJECTION);
end

def display
    glClear(GL_COLOR_BUFFER_BIT);

    glLoadIdentity


    d=0.5
    gluPerspective(50,4/3.0,0.1,100)
    glRotatef($camera.rot,0,1,0)
    glTranslatef($camera.pos.x,0,$camera.pos.y)
    $lines.each do |line|
        glColor3f(line.color[0], line.color[1], line.color[2])
        glBegin(GL_POLYGON);
        glVertex3f(line.from.x, -0.5,line.from.y);
        glVertex3f(line.from.x, 0.5,line.from.y);
        glVertex3f(line.to.x, 0.5,line.to.y);
        glVertex3f(line.to.x, -0.5,line.to.y);
        glEnd();
    end

    glLoadIdentity

    w=0.05

    glColor3f(0, 0, 0);

        glBegin(GL_POLYGON);
        glVertex3f(-1,1,0)
        glVertex3f(-1,w,0)
        glVertex3f(1,w,0)
        glVertex3f(1,1,0)
        glEnd();

        glBegin(GL_POLYGON);
        glVertex3f(-1,-1,0)
        glVertex3f(-1,-w,0)
        glVertex3f(1,-w,0)
        glVertex3f(1,-1,0)
        glEnd();
    glFlush();
end

def keyboard key, x, y
    case key.chr
    when "d"
        $camera.right!
    when "a"
        $camera.left!
    when "w"
        $camera.forward!
    when "s"
        $camera.back!
    when "q"
        exit
    end
    display
end

display_func = Proc.method(:display).to_proc
keyboard_func = Proc.method(:keyboard).to_proc

setup
glutDisplayFunc(display_func)
glutKeyboardFunc(keyboard_func)

glutMainLoop
