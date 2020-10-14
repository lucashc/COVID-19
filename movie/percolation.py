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

