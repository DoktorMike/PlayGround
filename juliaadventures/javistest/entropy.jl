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
myvideo = Video(500, 500)
Background(1:70, ground)
redball = Object(1:70, (args...) -> object(O, "red"), Point(100, 0))
act!(redball, Action(anim_translate(300, 300)))
render(myvideo; pathname="entropy.gif")
