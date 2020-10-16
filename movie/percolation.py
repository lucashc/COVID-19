from manim import *
import numpy as np
from presets import *



class Graph(GraphScene):
    CONFIG = {
        "x_min": 0.001,
        "x_max": 8,
        "y_max": 1.25,
        "y_min": 0,
        "x_axis_label": '$d$',
        "y_axis_label": '$P$',
        "y_axis_config": {'tick_frequency': 0.25, 'x_min': -0.15, "decimal_number_config": {'num_decimal_places': 2}},
        "x_axis_config": {'tick_frequency': 100, 'include_tip': True, 'x_min': -0.5, 'x_max': 8, 'x_label_direction': DOWN},
        "x_labeled_nums": range(1,8),  # range(100,1000, 100),
        "y_labeled_nums": [0.25, 0.5, 0.75, 1],
        "exclude_zero_label": False,
        "function_color": I_COLOR  # GREEN
    }

    def construct(self):
        self.setup_axes(animate=True)
        f = self.graph(1/2)
        f_copy = self.graph(1/2)
        f_gray = self.graph(1/2, color=LIGHT_GRAY, stroke_opacity=0.4)
        self.bring_to_back(f_gray)
        f_big_l = self.graph(1)
        f_big_l_gray = self.graph(1, color=LIGHT_GRAY, stroke_opacity=0.4)
        f_small_l = self.graph(1/4)
        f_small_l_gray = self.graph(1/4, color=LIGHT_GRAY, stroke_opacity=0.4)

        A = MathTex('P')
        A.set_coord(0.5, 1)  # note: niet coordinaat (0, 1) maar coordinaat 1 (dus y) wordt op 0 gezet
        A.set_coord(-0.5, 0)
        B = MathTex('= 1-e').next_to(A)
        #plus = MathTex('+').next_to(B).scale(4)
        C = MathTex(r'-\lambda').next_to(B, RIGHT + UP, buff=0).scale(0.8)
        D = MathTex(r'w_1 w_2 d(x,y)^{-\alpha}').next_to(C).scale(0.8)
        B.add_updater(lambda m: m.next_to(A))
        C.add_updater(lambda m: m.next_to(B, RIGHT + UP, buff=0))
        D.add_updater(lambda m: m.next_to(C))
        eq = VGroup(A,B,C,D)
        self.play(ShowCreation(f), Write(eq))
        self.wait()
        self.play(ScaleInPlace(A, 1.5), ScaleInPlace(C, 1.5), Transform(f, f_big_l), FadeIn(f_gray))
        self.wait()
        self.play(ScaleInPlace(A, 0.4), ScaleInPlace(C, 0.4), Transform(f, f_small_l), FadeIn(f_big_l_gray))
        self.wait()
        self.play(ScaleInPlace(A, 1/(1.5*0.4)), ScaleInPlace(C, 1/(1.5*0.4)),
                  Transform(f, f_copy), FadeIn(f_small_l_gray))
        self.wait()

    def probability(self, x, l):
        return 1 - np.exp(-l/x)

    def graph(self, l, color=None, stroke_opacity=1.0):
        if color is None:
            color = self.function_color
        return self.get_graph(lambda x: self.probability(x, l), color=color, stroke_opacity=stroke_opacity)

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
