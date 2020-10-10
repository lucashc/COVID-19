from manim import *

class Graph(Scene):
    def construct(self):
        infected = Circle(color=RED, radius=0.3)
        susceptible = Circle(color=BLUE, arc_center=2*UP + 2*RIGHT, radius=0.3)
        newly_infected = Circle(color=RED, arc_center=2*UP + 2*RIGHT, radius=0.3)
        line = Line(0.22*UP + 0.22*RIGHT, 1.78*UP + 1.78*RIGHT)
        red_line = Line(0.22*UP + 0.22*RIGHT, 1.78*UP + 1.78*RIGHT, color=RED)
        self.play(FadeIn(infected))
        self.play(FadeIn(susceptible))
        self.wait(0.5)
        self.play(FadeIn(line))
        self.wait(0.5)
        self.play(Transform(line, red_line))
        self.play(ShowCreation(red_line))
        self.wait()
        self.play(Transform(susceptible, newly_infected))
        self.wait(1)
        # self.play(FadeOutAndShift(infected))
        # self.play(FadeOutAndShift(line))
        # self.play(FadeOutAndShift(susceptible))
        # self.wait()


