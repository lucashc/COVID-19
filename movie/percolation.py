from manim import *
import numpy as np

def func(x):
    return np.exp(-x)


class Percolation(GraphScene):
    CONFIG = {
        "x_min": 0,
        "x_max": 6,
        "y_max": 1.5,
        "y_min": 0,
        "x_tick_frequency": 4
    }

    def construct(self):
        self.setup_axes(animate=True)
        f = self.get_graph(func, color=RED)
        self.play(Write(f))
        self.wait()


class Formula(Scene):
    def construct(self):
        A = MathTex('P').scale(2)
        A.set_coord(-4, 0)
        B = MathTex('= 1-e').next_to(A).scale(2)
        #plus = MathTex('+').next_to(B).scale(4)
        C = MathTex(r'-\lambda').next_to(B, RIGHT + UP, buff=0).scale(1.5)
        D = MathTex(r'w_1 w_2 d(x,y)^{-\alpha}').next_to(C).scale(1.5)
        B.add_updater(lambda m: m.next_to(A))
        C.add_updater(lambda m: m.next_to(B, RIGHT + UP, buff=0))
        D.add_updater(lambda m: m.next_to(C))
        self.add(A, B, C, D)
        self.play(ScaleInPlace(A, 1.5), ScaleInPlace(C, 1.5))
        self.wait()
        self.play(ScaleInPlace(A, 0.4), ScaleInPlace(C, 0.4))
        self.wait()
        self.play(ScaleInPlace(A, 1/(1.5*0.4)), ScaleInPlace(C, 1/(1.5*0.4)))
        self.wait()
