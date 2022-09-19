using Javis

video = Video(500, 500)
nframes = 250
Background(1:nframes, (v, o, f) -> background("black"))

const ballsize = 25

# Infobox
function info_box(video, object, frame)
    sethue("white")
    fontsize(12)
    box(140, -210, 170, 40, :stroke)
    text("10-20 EEG Array Readings", 140, -220, valign = :middle, halign = :center)
    text("t = $(frame)s", 140, -200, valign = :middle, halign = :center)
end

# Create all the balls
randvelocity() = (floor(Int64, randn() * 10), floor(Int64, randn() * 5))

function createobj(color="red")
  obj = Object(1:nframes, (v, o, f) -> begin
    sethue(color)
    circle(O, ballsize, :fill)
    return O
  end)
  obj.opts[:velocity] = randvelocity()
  obj
end
colors = ("red", "green", "blue", "pink", "orange", "yellow")
objs = [createobj(colors[i]) for i in 1:length(colors)]

#not really an obj , as in draws nothing , but runs a function
# Logic for updating the velocity based on wall collissions
updaterobj = Object(1:nframes, (v, o, f) -> begin
  #hardcoded boundaries of the video
  function updateone(obj)
    radius = floor(ballsize / 2)
    if !(-250 + radius < pos(obj).x < 250 - radius)
      v = obj.opts[:velocity]
      obj.opts[:velocity] = (-v[1], v[2])
    end
    if !(-250 + radius < pos(obj).y < 250 - radius)
      v = obj.opts[:velocity]
      obj.opts[:velocity] = (v[1], -v[2])
    end
  end
  updateone.(objs)
end)

# Update each balls position based on their velocity
move() = (v, o, a, f) -> begin
  if f == first(Javis.get_frames(a))
    translate(o.start_pos + o.opts[:velocity])
  else
    translate(get_position(o) + o.opts[:velocity])
  end
end

for i in 1:length(objs)
  act!(objs[i], Action(1:nframes, move()))
end

info = Object(info_box)

#render(video, pathname="vid.mp4")
render(video; pathname="vid.gif")
#run(`mpv vid.mp4`)
