require "shapes"

require "rubygems"
require "gosu"
require "gl"
require "glu"

include Gl
include Glu

class View
    attr_reader :rot
    attr_accessor :pos, :down_rot, :height
    def initialize
        @pos = Vec2.new(0, 0)
        @rot = 0
        @down_rot = 0
        @height = 0
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
    attr_reader :color, :connected
    attr_accessor :deleted
    def initialize from, to, color
        super from, to
        @color = color
        @connected = []
        @deleted = false
    end
    def connect wall
        @connected << wall
    end
end

class GameWindow < Gosu::Window
  def initialize
    super(800, 600, false)
    self.caption = "Flatland"
    @camera = View.new
    @top_view = false

    @lines = []

    range = 2

    #add_quad Rect.new([2*range,2*range],[0,0]), [0,0,0]

        20.times do
            x = rand*range*2-range
            y = rand*range*2-range
            red = [1,0,0]
            green = [0,1,0]
            white = [1,1,1]
            color = [red, green, white][rand(3)]
            size_multiplier = 1


            add_quad Rect.new([rand*size_multiplier,rand*size_multiplier],[x,y]), color
        end

        gl_init

      end

      def add_quad q, col
          rect = []
          [[q.topleft,q.topright],
              [q.topright,q.bottomright],
              [q.bottomright,q.bottomleft],
              [q.bottomleft,q.topleft]].each do |from, to|
              rect << Wall.new(from, to, col)
          end
          rect[0].connect rect[1]
          rect[1].connect rect[2]
          rect[2].connect rect[3]
          rect[3].connect rect[0]
          @lines.concat rect
      end

      def update
          move_camera
          set_mouse_position(width/2.0,height/2.0)
      end

      def move_camera
          f = 20.0
          r = 90/f
          h = 4/f
          if @top_view
              if @camera.height < 4
                  @camera.height += h
              end
              if @camera.down_rot < 90
                  @camera.down_rot += r
              end
          else
              if @camera.height > 0
                  @camera.height -= h
              end
              if @camera.down_rot > 0
                  @camera.down_rot -= r
              end
          end

          forward = 0
          right = 0
          speed = 0.03
          mouse_speed = 0.1

          prev_pos = @camera.pos.clone

          forward += speed if button_down? Gosu::KbUp or button_down? Gosu::KbW
          forward -= speed if button_down? Gosu::KbDown or button_down? Gosu::KbS
          right += speed if button_down? Gosu::KbRight or button_down? Gosu::KbD
          right -= speed if button_down? Gosu::KbLeft or button_down? Gosu::KbA

          @camera.move(forward,right)
          @camera.rotate(mouse_speed*(mouse_x-width/2.0))

          after_pos = @camera.pos.clone

          camera_movement = Line.new(-prev_pos, -after_pos)

          if camera_movement.length > 0
              @lines.each do |line|
                  if line.collides? camera_movement
                      case line.color
                      when [1,0,0]
                          raise "GAME OVER"
                      when [0,1,0]
                          delete_wall line
                      else
                          @camera.pos = prev_pos
                          break
                      end
                  end
              end
          end

          if @lines.count{|l| l.color == [0,1,0]} == 0
              raise "YOU WIN"
          end
      end

      def delete_wall wall
          @lines.delete(wall)
          wall.deleted = true
          wall.connected.each do |w|
              delete_wall w unless w.deleted
          end
      end

      def gl_init
          #bgcolor = [1,1,1,1]
          bgcolor = [0,0,0,1]

          glClearColor(*bgcolor)
          glClearDepth(0)
          glShadeModel(GL_SMOOTH)

          glEnable(GL_DEPTH_TEST)
          glDepthFunc(GL_GREATER)

          glLineWidth(5)

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
          glRotatef(@camera.down_rot,1,0,0)
          glRotatef(@camera.rot,0,1,0)
          glTranslatef(@camera.pos.x,-@camera.height,@camera.pos.y)
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
              glBegin(GL_LINES);
              #glVertex3f(line.from.x, -d,line.from.y);
              glVertex3f(line.from.x, 0,line.from.y);
              #glVertex3f(line.to.x, d,line.to.y);
              glVertex3f(line.to.x, 0,line.to.y);
              glEnd
          end
              glColor3f(255,255,255)
              glBegin(GL_LINES);
              glVertex3f(-@camera.pos.x-0.01, 0, -@camera.pos.y-0.01)
              glVertex3f(-@camera.pos.x+0.01, 0, -@camera.pos.y+0.01)
              glEnd
          glFlush
      end

      def draw
          # gl will execute the given block in a clean OpenGL environment, then reset
          # everything so Gosu's rendering can take place again.

          gl do
              gl_reshape
              gl_view
              gl_render
          end
      end

      def button_down(id)
          case id
          when Gosu::KbEscape
              close
          when Gosu::KbT
              @top_view = ! @top_view
          end
      end
end

window = GameWindow.new
window.show
