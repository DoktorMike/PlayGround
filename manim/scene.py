from manim import *
from manim_chemistry import *


class CreateCircle(Scene):
    def construct(self):
        circle = Circle()  # create a circle
        circle.set_fill(PINK, opacity=0.5)  # set the color and transparency
        self.play(Create(circle))  # show the circle on screen


class DifferentRotations(Scene):
    def construct(self):
        left_square = Square(color=BLUE, fill_opacity=0.7).shift(2 * LEFT)
        right_square = Square(color=GREEN, fill_opacity=0.7).shift(2 * RIGHT)
        self.play(
            left_square.animate.rotate(PI), Rotate(right_square, angle=PI), run_time=2
        )
        self.wait()


class MathTeXDemo(Scene):
    def construct(self):
        rtarrow0 = MathTex(r"\xrightarrow{x^6y^8}", font_size=96)
        rtarrow1 = Tex(r"$\xrightarrow{x^6y^8}$", font_size=96)

        self.add(VGroup(rtarrow0, rtarrow1).arrange(DOWN))


class Draw3DMorphine(ThreeDScene):
    def construct(self):
        three_d_morphine = ThreeDMolecule.from_mol_file("morphine.mol", "Elementos.csv")
        self.add(three_d_morphine)
        self.wait()


class TwoDMoleculeScene(Scene):
    def construct(self):
        morphine = MMoleculeObject.from_mol_file("morphine.mol", rotate_bonds=[7, 20])
        self.add(morphine)
