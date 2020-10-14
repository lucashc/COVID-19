from manim import *
from presets import *
import numpy as np
import random
import itertools

class Density(Scene):
    def construct(self):
        text = Tex("Population density of Germany").scale(1.5)
        image = ImageMobject('images/popdens.png').shift(DOWN*0.5).scale(3)

        # Animation
        def apply_func(mob):
            mob.scale(0.67)
            mob.shift(UP*3)
            return mob
        self.add(text)
        self.play(ApplyFunction(apply_func, text), GrowFromCenter(image))