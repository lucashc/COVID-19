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
        self.wait()
        self.play(FadeOut(text), FadeOut(image))
        self.wait()


class ConnectionDistance(Scene):
    def construct(self):
        def random_probability(length=9):
            return "0." + str(random.randint(0, 10**length-1)).rjust(length, '0')

        def ct(x):  # coordinate transform
            return 6*float(x) - 3

        coords = [[-3, 1], [-4, 2], [1.6, 2.35], [4.1, -0.9]]
        np_coords = [np.array(r + [0]) for r in coords]
        nodes = [Node('S', location=r) for r in np_coords[:2]]
        nodes += [Node('S', location=r, radius=0.1) for r in np_coords[2:]]
        image = ImageMobject("images/Germany.png").move_to([3, 1, 0]).scale(2.5)
        self.play(FadeIn(image), *(GrowFromCenter(n)for n in nodes))
        edges = [Edge(nodes[1], nodes[0], color="#bc20d4"), Edge(nodes[2], nodes[3], color=J_COLOR)]
        self.play(ShowCreation(edges[0]),  ShowCreation(edges[1]))

        nl_height = -2.7
        numberline1 = NumberLine(x_min=0, x_max=1, numbers_with_elongated_ticks=[0, 1],
                                 unit_size=6, include_numbers=True, numbers_to_show=[0, 1]).move_to([0,nl_height,0])
        label = Tex("Probability of connecting").next_to(numberline1, DOWN)
        small_dist_tick = Line([1, nl_height-0.1, 0], [1, nl_height+0.4, 0], color="#bc20d4")
        large_dist_tick = Line([-2.5, nl_height-0.1, 0], [-2.5, nl_height+0.4, 0], color=J_COLOR)
        self.play(Write(numberline1), FadeIn(small_dist_tick), FadeIn(large_dist_tick), Write(label))

        first_random_number = random_probability()
        first_num_tex = Tex(first_random_number).move_to([0, 3, 0])
        last_random_number = "0.314159265"
        last_num_tex = Tex(last_random_number).move_to([0, 3, 0])
        random_numbers = [random_probability()for i in range(7)]
        random_texes = [Tex(x).move_to([0, 3, 0]) for x in random_numbers]

        scaled_pi = 6 * 0.31415 - 3
        print(ct(first_random_number), type(ct(first_random_number)))
        prob_tick = Line([ct(first_random_number), nl_height - 0.1, 0],
                         [ct(first_random_number), nl_height + 0.4, 0], color=R_COLOR).scale(1.5)

        self.play(FadeIn(first_num_tex), FadeIn(prob_tick), run_time=0.4)
        for num, tex in zip(random_numbers, random_texes):
            self.play(Transform(first_num_tex, tex), prob_tick.move_to,
                      [ct(num), nl_height + 0.15, 0], run_time=0.2)

        self.play(Transform(first_num_tex, last_num_tex), prob_tick.move_to,
                  [scaled_pi, nl_height + 0.15, 0], run_time=0.2)

        self.play(first_num_tex.set_color, R_COLOR, first_num_tex.scale, 2, prob_tick.scale, 1.7)
        self.play(first_num_tex.scale, 1/2, prob_tick.scale, 1/1.7)

        green_dot1 = Dot(color=R_COLOR).move_to([-3, 3.5, 0])
        ineq1 = MathTex('<').next_to(green_dot1)
        purple_dot = Dot(color="#bc20d4").next_to(ineq1)
        expr1 = VGroup(green_dot1, ineq1, purple_dot)

        green_dot2 = Dot(color=R_COLOR).move_to([3, 3.5, 0])
        ineq2 = MathTex('>').next_to(green_dot2)
        yellow_dot = Dot(color=J_COLOR).next_to(ineq2)

        expr2 = VGroup(yellow_dot, ineq2, green_dot2)

        self.play(Write(expr1))
        new_edge = Edge(nodes[1],nodes[0], color=R_COLOR).set_stroke_width(10)

        self.play(Transform(edges[0], new_edge))
        self.play(FadeIn(edges[0].color_replica(INERT_EDGE_COLOR)), FadeOut(edges[0]))

        self.play(Write(expr2))
        self.play(Transform(edges[1], edges[1].color_replica(I_COLOR)))
        self.play(Uncreate(edges[1]))
        self.wait()
