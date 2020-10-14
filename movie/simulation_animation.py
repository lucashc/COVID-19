from manim import *
from presets import *
import numpy as np

class Simulation(Scene):
    def construct(self):

        # this is the intro part (better to keep separate and edit everything together)
        title_text = Tex("How does our graph model work?").to_edge(UP)
        self.play(Write(title_text))
        self.wait(1)
        subtitle = Tex("Nodes have different colors depending on their status").next_to(title_text, DOWN)
        self.play(Write(subtitle))
        legend_nodes = [Node(status, location=np.array([-2, 1-i, 0])) for i, status in enumerate(['S', 'I', 'R', 'J'])]
        legend_texts = ["Susceptible", "Infected", "Recovered", "Newly infected"]
        legend_texs = [Tex(status).next_to(node) for status, node in zip(legend_texts, legend_nodes)]
        for i in range(4):
            self.play(GrowFromCenter(legend_nodes[i]), Write(legend_texs[i]))

        self.wait(1)
        all_objects = [title_text, subtitle] + legend_nodes + legend_texs
        self.play(*[Uncreate(x) for x in all_objects])
        self.wait()


        # this is the graphy part
        coords = [[0, 0], [1.5, 2], [-4, 1.2], [2.4, -1.2], [-3, -1.7], [-2.8, 1.7], [-1, -2], [-0.5, 2.2],
                  [-2, -0.5], [1.2, -2.1], [3, 0.5], [1, 0.5]]
        np_coords = [np.array(r+[0]) for r in coords]
        nodes = [Node('S', location=r) for r in np_coords]
        nodes[0] = nodes[0].status_replica('J')
        self.play(*(GrowFromCenter(node) for node in nodes))
        self.wait(0.5)
        edges = [Edge(nodes[0], nodes[1]), Edge(nodes[0], nodes[11]), Edge(nodes[0], nodes[8]),
                  Edge(nodes[0], nodes[6])]
        self.play(*[ShowCreation(edge) for edge in edges])
        self.wait(0.5)
        self.play(InfectEdge(edges[1]), InfectEdge(edges[3]))
        self.play(TransformNodeStatus(nodes[6], 'J'), TransformNodeStatus(nodes[11], 'J'),
                  TransformNodeStatus(nodes[0], 'I'))
        self.wait()
        text1 = Tex("Only newly infected nodes can make connections").to_edge(UP)
        self.play(Write(text1))
        edges2 = [Edge(nodes[6], nodes[4]), Edge(nodes[6], nodes[8]),
                  Edge(nodes[11], nodes[3]), Edge(nodes[11], nodes[10])]
        self.play(*[ShowCreation(edge) for edge in edges2],
                  TransformNodeStatus(nodes[6], 'I'), TransformNodeStatus(nodes[11], 'I'))
        # nodes go I->J at the same time as they make connections
        self.wait(1)
        text2 = Tex("Not all neighbors are infected right away").to_edge(UP)
        self.play(Transform(text1, text2))
        self.remove(text2)
        self.play(InfectEdge(edges2[1]), InfectEdge(edges2[2]))
        self.play(TransformNodeStatus(nodes[8], 'J'), TransformNodeStatus(nodes[3], 'J'))
        self.wait(1)
        text3 = Tex("But edges have a chance to infect each time step").to_edge(UP)
        self.play(Transform(text1, text3))
        self.remove(text3)
        self.play(InfectEdge(edges[0]))
        self.play(TransformNodeStatus(nodes[1], 'J'))

        self.wait(1)
        edges3 = [Edge(nodes[8], nodes[4]), Edge(nodes[8], nodes[5]), Edge(nodes[3], nodes[9])]
        self.play(*[ShowCreation(edge) for edge in edges3],
                  TransformNodeStatus(nodes[8], 'I'), TransformNodeStatus(nodes[3], 'I'))
        self.play(InfectEdge(edges3[1]), InfectEdge(edges2[0]))
        self.play(TransformNodeStatus(nodes[5], 'J'), TransformNodeStatus(nodes[4], 'J'),
                  TransformNodeStatus(nodes[9], 'J'))
        self.wait()

class TrialConnection(Scene):
    def construct(self):
        title = Tex("A newly infected node tries to connect to all  other nodes").to_edge(UP)
        self.play(Write(title))

        # coords = [[0, 0], [1.5, 2], [-4, 1.2], [2.4, -1.2], [-3, -1.7], [-2.8, 1.7], [-1, -2], [-0.5, 2.2],
        #           [-2, -0.5], [1.2, -2.1], [3, 0.5], [1, 0.5]]
        coords = [[0, 0], [3, 0.5], [1, 0.5], [1.5, 2], [-0.5, 2.2], [-2.8, 1.7], [-4, 1.2], [-2, -0.5], [-3, -1.7],
                  [-1, -2], [1.2, -2.1], [2.4, -1.2]]  # arranged counter clockwise from x=0
        np_coords = [np.array(r+[0]) for r in coords]
        nodes = [Node('S', location=r) for r in np_coords]
        nodes[0] = nodes[0].status_replica('J')
        self.play(*(GrowFromCenter(node) for node in nodes))
        # for n in nodes:
        #     self.add(n)
        #     self.wait(0.2)

        edges = [Edge(nodes[0], node, color=GRAY) for node in nodes[1:]]
        succeed = [2, 3, 7, 9]
        for i, edge in enumerate(edges[:4]):
            self.play(ShowCreation(edge))
            if i + 1 in succeed:  # +1 since 0 will not be connected to
                self.play(FadeIn(edge.color_replica('#1BEE0A')))
                self.play(FadeIn(edge.color_replica(WHITE)))
            else:
                self.play(Transform(edge, edge.color_replica(RED)))
                self.play(Uncreate(edge))

        recolor_list = []
        replace_list = []
        for i, edge in enumerate(edges[4:]):
            if i + 1 + 4 in succeed:  # +1 as before, +4 since we start at 4
                recolor_list.append(FadeIn(edge.color_replica('#1BEE0A')))  # fade to green
                replace_list.append(FadeIn(edge.color_replica(WHITE)))  # fade to white instead of gray
            else:
                recolor_list.append(Transform(edge, edge.color_replica(RED)))
                replace_list.append(Uncreate(edge))

        self.play(*[ShowCreation(edge) for edge in edges[4:]])
        self.play(*[recolor for recolor in recolor_list])
        self.play(*[replacement for replacement in replace_list])
        self.wait()