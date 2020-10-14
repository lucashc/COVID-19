from manim import *
from presets import *

class Graph(Scene):
    def construct(self):
        infected = Node('I', style='filled')  # added 2 styles, hollow (default) and filled.
        susceptible = Node('S', location=2*UP + 2*RIGHT)
        line = Edge(infected, susceptible)
        self.play(FadeIn(infected))
        self.play(FadeIn(susceptible))
        self.wait(0.5)
        self.play(ConnectNodes(infected, susceptible))
        self.wait(0.5)
        self.play(InfectEdge(line))
        self.wait()
        self.play(TransformNodeStatus(susceptible, 'I'))
        self.wait(1)
        self.play(FadeOutAndShift(infected), FadeOutAndShift(line), FadeOutAndShift(susceptible))
        self.wait()


