require "shapes"

require "rubygems"
require "gosu"
require "gl"
require "glu"

include Gl
include Glu

class View
    attr_reader :pos, :rot
    def initialize
        @pos = Vec2.new(0, 0)
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
    def move forward, right=0
        @pos.x += Math::cos((@rot+90)/180.0*Math::PI)*forward
        @pos.y += Math::sin((@rot+90)/180.0*Math::PI)*forward

        @pos.x += Math::cos((@rot+180)/180.0*Math::PI)*right
        @pos.y += Math::sin((@rot+180)/180.0*Math::PI)*right
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

class GameWindow < Gosu::Window
  def initialize
    super(800, 600, false)
    self.caption = "Flatland"
    @camera = View.new

    @lines = []

    range = 10

    #add_quad Rect.new([2*range,2*range],[0,0]), [0,0,0]

    100.times do
        x = rand(range*2)-range
        y = rand(range*2)-range
        color = [rand/2.0+0.5, rand/2.0+0.5, rand/2.0+0.5]
        size_multiplier = 1


        add_quad Rect.new([rand*size_multiplier,rand*size_multiplier],[x,y]), color
    end

    gl_init

  end

  def add_quad q, col
      [[q.topleft,q.topright],
          [q.topright,q.bottomright],
          [q.bottomright,q.bottomleft],
          [q.bottomleft,q.topleft]].each do |from, to|
          @lines << Wall.new(from, to, col)
          end
  end

  def update
      move_camera
      set_mouse_position(width/2.0,height/2.0)
  end

  def move_camera
      forward = 0
      right = 0
      speed = 0.03
      mouse_speed = 0.1

      forward += speed if button_down? Gosu::KbUp or button_down? Gosu::KbW
      forward -= speed if button_down? Gosu::KbDown or button_down? Gosu::KbS
      right += speed if button_down? Gosu::KbRight or button_down? Gosu::KbD
      right -= speed if button_down? Gosu::KbLeft or button_down? Gosu::KbA

      @camera.move(forward,right)

      @camera.rotate(mouse_speed*(mouse_x-width/2.0))
  end

  def gl_init
      #bgcolor = [1,1,1,1]
      bgcolor = [0,0,0,1]

      glClearColor(*bgcolor)
      glClearDepth(0)
      glShadeModel(GL_SMOOTH)

      glEnable(GL_DEPTH_TEST)
      glDepthFunc(GL_GREATER)

      #glEnable(GL_LIGHTING)
      #glEnable(GL_LIGHT0)
      #glEnable(GL_COLOR_MATERIAL)

      #glLightfv(GL_LIGHT0, GL_DIFFUSE, [0.5,0.5,0.5,1])
      #glLightfv(GL_LIGHT0, GL_POSITION, [0,0,0,1])

      glFogi(GL_FOG_MODE,GL_LINEAR)
      glFogfv(GL_FOG_COLOR, bgcolor)
      #glFogf(GL_FOG_DENSITY, 0.15)
      #glHint(GL_FOG_HINT, GL_NICEST)
      glFogf(GL_FOG_START, 0.1)
      glFogf(GL_FOG_END, 5)
      glEnable(GL_FOG)
  end

  def gl_view
      glLoadIdentity
      glRotatef(@camera.rot,0,1,0)
      glTranslatef(@camera.pos.x,0,@camera.pos.y)
  end

  def gl_reshape
      glMatrixMode(GL_PROJECTION);
      glLoadIdentity
      gluPerspective(50,4/3.0,100,0.001)
      glMatrixMode(GL_MODELVIEW);
  end

  def gl_render
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
      d=100
      @lines.each do |line|
          glColor3f(line.color[0], line.color[1], line.color[2])
          glBegin(GL_POLYGON);
          glVertex3f(line.from.x, -d,line.from.y);
          glVertex3f(line.from.x, d,line.from.y);
          glVertex3f(line.to.x, d,line.to.y);
          glVertex3f(line.to.x, -d,line.to.y);
          glEnd
      end
      glFlush();
  end

  def draw
      # gl will execute the given block in a clean OpenGL environment, then reset
      # everything so Gosu's rendering can take place again.

      gl do
          gl_reshape
          gl_view
          gl_render
      end

      if true
      #if false
          c=Gosu::Color::BLACK
          d=0.45
          draw_quad(0,0,c,width,0,c,width,height*d,c,0,height*d,c)
          d=0.5
          draw_quad(0,height,c,width,height,c,width,height*(1-d),c,0,height*(1-d),c)
      end

  end

  def button_down(id)
      if id == Gosu::KbEscape
          close
      end
  end
end

window = GameWindow.new
window.show
