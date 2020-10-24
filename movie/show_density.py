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
            return Tex("0." + str(random.randint(0, 10**length-1)).rjust(length, '0'))

        coords = [[-3, 1], [-4, 2], [1.6, 2.35], [4.1, -0.9]]
        np_coords = [np.array(r + [0]) for r in coords]
        nodes = [Node('S', location=r) for r in np_coords[:2]]
        nodes += [Node('S', location=r, radius=0.1) for r in np_coords[2:]]
        image = ImageMobject("images/InitialInfections.png").move_to([3, 1, 0]).scale(2.5)
        self.play(FadeIn(image), *(GrowFromCenter(n)for n in nodes))
        edges = [Edge(nodes[1], nodes[0], color="#20d4d1"), Edge(nodes[2], nodes[3], color=J_COLOR)]
        self.play(ShowCreation(edges[0]),  ShowCreation(edges[1]))

        numberline1 = NumberLine(x_min=0, x_max=1, numbers_with_elongated_ticks=[0, 1],
                                 unit_size=6, include_numbers=True, numbers_to_show=[0, 1]).move_to([0,-3,0])
        self.add(numberline1)
        self.add(Line([1, -3.1, 0], [1, -2.6, 0], color="#20d4d1"))
        self.add(Line([-2.5, -3.1, 0], [-2.5, -2.6, 0], color=J_COLOR))
        first_random_number = random_probability().move_to([0, 3, 0])
        last_random_number = Tex("0.314159265").move_to([0, 3, 0])
        random_numbers = [random_probability().move_to([0, 3, 0]) for i in range(10)]
        self.play(FadeIn(first_random_number), run_time=0.4)
        for num in random_numbers:
            self.play(Transform(first_random_number, num, run_time=0.2))
        self.play(Transform(first_random_number, last_random_number), run_time=0.2)
        scaled_pi = 6*0.31415 - 3
        self.play(first_random_number.set_color, R_COLOR, first_random_number.scale, 2,
                  FadeIn(Line([scaled_pi, -3.1, 0], [scaled_pi, -2.6, 0], color=R_COLOR)))
        self.play(first_random_number.scale, 1/2)
        self.play(Transform(edges[0], edges[0].color_replica(R_COLOR)),
                  Transform(edges[1], edges[1].color_replica(I_COLOR)))
        self.play(Uncreate(edges[1]), FadeIn(edges[0].color_replica(INERT_EDGE_COLOR)))

        self.wait()