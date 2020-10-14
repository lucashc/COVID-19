from manim import *
from presets import *
import numpy as np
import random
import itertools

class Intro(Scene):
    def construct(self):
        t1 = Tex("{\\LARGE COVID-19}")
        t2 = Tex("Modelling Group 1").shift(DOWN*1)
        i1 = ImageMobject('./images/logo.png').shift(DOWN*2).scale(0.6)
        self.play(ShowCreation(t1), ShowCreation(t2), GrowFromCenter(i1))
        self.wait()
