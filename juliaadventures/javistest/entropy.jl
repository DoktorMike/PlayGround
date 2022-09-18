using Javis

function ground(args...)
  background("white")
  sethue("black")
end

function object(p=O, color="black")
  sethue(color)
  circle(p, 25, :fill)
  return p
end


myvideo = Video(500, 500)
Background(1:70, ground)
red_ball = Object(1:70, (args...) -> object(O, "red"), Point(100, 0))
blue_ball = Object(1:70, (args...) -> object(O, "blue"), Point(100, 100))

render(myvideo; pathname="circle.gif")

# Exercise 2
myvideo = Video(500, 500)

Background(1:70, ground)
red_ball = Object(1:70, (args...) -> object(O, "red"), Point(100, 0))
act!(red_ball, Action(anim_rotate_around(2π, O)))

render(myvideo; pathname="circle2.gif")


# entropy

function updatedirection!(ball)
  ball.pos = Point(-ball.pos.x, ball.pos.y)
  ball
end

myvideo = Video(500, 500)
Background(1:70, ground)
redball = Object(1:70, (args...) -> object(O, "red"), Point(-250, -250))
for f in 1:70
  act!(redball, Action(f, anim_translate(10,10)))
end

Object(1:70, (args...) -> updatedirection!(redball))
act!(redball, Action(anim_translate(500, 500)))

render(myvideo; pathname="entropy.gif")
