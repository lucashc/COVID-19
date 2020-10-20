from manim import *
import numpy as np
from presets import *



class Graph(GraphScene):
    CONFIG = {
        "x_min": 0.001,
        "x_max": 8,
        "y_max": 1.25,
        "y_min": 0,
        "x_axis_label": '',  # set manually
        "y_axis_label": '',
        "y_axis_config": {'tick_frequency': 0.25, 'x_min': -0.15, "decimal_number_config": {'num_decimal_places': 2}},
        "x_axis_config": {'tick_frequency': 1, 'include_tip': True, 'x_min': -0.5, 'x_max': 8},
        # "x_labeled_nums": range(1,8),  # range(100,1000, 100),
        "y_labeled_nums": [0.25, 0.5, 0.75, 1],
        "exclude_zero_label": False,
        "function_color": I_COLOR  # GREEN
    }

    def construct(self):
        self.setup_axes(animate=True)
        xlabel = MathTex('d').move_to([5.5, -2.5, 0])
        ylabel = MathTex('P').move_to([-4.5, 3.5, 0])
        self.play(FadeIn(xlabel, run_time=0.2), FadeIn(ylabel, run_time=0.2))
        f = self.graph(1/2)
        f_copy = self.graph(1/2)
        f_shadow = self.graph(1/2, color=WHITE, stroke_opacity=0.4)

        f_big_l = self.graph(1)
        f_big_l_shadow = self.graph(1, color=ORANGE, stroke_opacity=0.4)
        f_small_l = self.graph(1/4)
        f_small_l_shadow = self.graph(1/4, color=ORANGE, stroke_opacity=0.4)

        f_big_alpha = self.graph(1/2, 2)
        f_big_alpha_shadow = self.graph(1/2, 2, color=S_COLOR, stroke_opacity=0.4)
        f_small_alpha = self.graph(1/2, 1/2)
        f_small_alpha_shadow = self.graph(1/2, 1/2, color=S_COLOR, stroke_opacity=0.4)

        P = MathTex('P')
        P.move_to([-0.5, 0.5, 0])
        eq_1_min_e = MathTex('= 1-e').next_to(P)
        min_lambda = MathTex(r'^{-\lambda}').next_to(eq_1_min_e, RIGHT + UP, buff=0)
        weights = MathTex(r'^{w_1 w_2}').next_to(min_lambda, buff=MED_SMALL_BUFF/2)
        distance = MathTex(r'^{d(x,y)}').next_to(weights, buff=MED_SMALL_BUFF/2)
        min_alpha = MathTex(r'^{^{-\alpha}}').next_to(distance, RIGHT + UP, buff=0)

        eq_1_min_e.add_updater(lambda m: m.next_to(P))
        min_lambda.add_updater(lambda m: m.next_to(eq_1_min_e, RIGHT + UP, buff=0))
        weights.add_updater(lambda m: m.next_to(min_lambda, buff=MED_SMALL_BUFF/2))
        distance.add_updater(lambda m: m.next_to(weights, buff=MED_SMALL_BUFF/2))
        min_alpha.add_updater(lambda m: m.next_to(distance, RIGHT + UP, buff=0))

        eq = VGroup(P, eq_1_min_e, min_lambda, weights, distance, min_alpha)

        self.play(ShowCreation(f, run_time=1.5), Write(eq))
        self.bring_to_back(f_shadow)
        self.wait()
        self.play(FadeToColor(xlabel, R_COLOR), FadeToColor(distance, R_COLOR))
        self.play(FadeToColor(ylabel, J_COLOR), FadeToColor(P, J_COLOR))
        self.wait()
        self.play(ScaleInPlace(P, 1.5), ScaleInPlace(min_lambda, 1.5), Transform(f, f_big_l), FadeIn(f_shadow))
        self.wait()
        self.play(ScaleInPlace(P, 0.4), ScaleInPlace(min_lambda, 0.4), Transform(f, f_small_l), FadeIn(f_big_l_shadow))
        self.wait()
        self.play(ScaleInPlace(P, 1/(1.5*0.4)), ScaleInPlace(min_lambda, 1/(1.5*0.4)),
                  Transform(f, f_copy), FadeIn(f_small_l_shadow))
        self.wait()
        self.play(ScaleInPlace(min_alpha, 1.5), Transform(f, f_big_alpha))
        self.wait()
        self.play(ScaleInPlace(min_alpha, 0.4), Transform(f, f_small_alpha), FadeIn(f_big_alpha_shadow))
        self.wait()
        self.play(ScaleInPlace(min_alpha, 1/(1.5*0.4)), Transform(f, f_copy), FadeIn(f_small_alpha_shadow))
        self.wait()

    def probability(self, x, l, a):
        return 1 - np.exp(-l/x**a)

    def graph(self, l, alpha=1.0, color=None, stroke_opacity=1.0):
        if color is None:
            color = self.function_color
        return self.get_graph(lambda x: self.probability(x, l, alpha), color=color, stroke_opacity=stroke_opacity)


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
