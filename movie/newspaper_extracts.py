from manim import *
from presets import *
import numpy as np
import random
import itertools

class Extracts(MovingCameraScene):
    def construct(self):
        h1 = ImageMobject('./images/H1.png').scale(5).shift(DOWN*10)
        h2 = ImageMobject('./images/H2.png').scale(5.385).shift(DOWN*10)
        h3 = ImageMobject('./images/H3.png').scale(5).shift(DOWN*10)
        h4 = ImageMobject('./images/H4.png').scale(1.4).shift(DOWN*10)
        self.add(h1, h2, h3, h4)
        self.play(h1.shift, UP*8)
        self.wait()
        self.play(h2.shift, UP*7.5)
        self.wait()
        self.play(h3.shift, UP*8)
        self.wait()
        self.play(h4.shift, UP*10)
        self.wait(2)
        self.play(self.camera_frame.set_height, self.camera_frame.get_height()*5, FadeOut(h1), FadeOut(h2), FadeOut(h3), FadeOut(h4))
        self.wait()

