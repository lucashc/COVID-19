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

class Outro(Scene):
    def construct(self):
        self.wait(0.5)
        credit = Tex(r"{\centering Creators: \\ Benjamin Oudejans \\ Sven Holtrop \\ Lucas Crijns \\ Pim Keer \\ Maxime Delboo}").shift(UP*6)
        thanksto = Tex(r"Animated with Manim provided by 3b1b").scale(0.6).shift(DOWN*3)
        self.add(credit)
        self.play(credit.shift, DOWN*5, ShowCreation(thanksto))
        self.wait(3)
        self.play(credit.shift, 6*UP, thanksto.shift, 2*DOWN)
        self.wait()