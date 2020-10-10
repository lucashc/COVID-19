from manim import *
from movie.presets import *

class Graph(Scene):
    def construct(self):
        infected = Node('I', style='filled')  # added 2 styles, hollow (default) and filled.
        susceptible = Node('S', location=2 * UP + 2 * RIGHT)
        newly_infected = Node('I', location=2 * UP + 2 * RIGHT)
        line = Edge(infected, susceptible)
        red_line = Edge(infected, susceptible, color=I_COLOR)

        self.play(FadeIn(infected))
        self.play(FadeIn(susceptible))
        self.wait(0.5)
        self.play(FadeIn(line))
        self.wait(0.5)
        self.play(Transform(line, red_line))
        self.play(ShowCreation(red_line))
        self.wait()
        self.play(Transform(susceptible, newly_infected))
        self.remove(red_line)
        self.wait(1)
        self.play(FadeOutAndShift(infected), FadeOutAndShift(line), FadeOutAndShift(susceptible))
        self.wait()


