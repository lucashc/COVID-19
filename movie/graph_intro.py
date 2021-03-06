from manim import *
from presets import *

class Graph_Intro(Scene):
    def construct(self):
        t1 = Tex("{\\Large A Graph")
        t1.move_to([0,3,0])
        coords = [[0, 0], [1.5, 2], [-4, 1.2], [2.4, -1.2], [-3, -1.7], [-2.8, 1.7], [-1, -2], [-0.5, 2.2],
                  [-2, -0.5], [1.2, -2.1], [3, 0.5], [1, 0.5]]
        np_coords = [np.array(r + [0]) for r in coords]
        nodes = [Node('N', location=r) for r in np_coords]
        edges = [Edge(nodes[0], nodes[1]), Edge(nodes[0], nodes[11]), Edge(nodes[0], nodes[8]),
                    Edge(nodes[0], nodes[6]), Edge(nodes[6], nodes[4]), Edge(nodes[6], nodes[8]),
                    Edge(nodes[11], nodes[3]), Edge(nodes[11], nodes[10]), Edge(nodes[8], nodes[4]),
                    Edge(nodes[8], nodes[5]), Edge(nodes[3], nodes[9])]
        self.play(ShowCreation(t1))
        node_vgroup = VGroup(*nodes)
        edge_vgroup = VGroup(*edges)
        self.play(GrowFromCenter(node_vgroup))
        self.wait(.25)
        self.play(ShowCreation(edge_vgroup))
        self.wait(1)

class Highlight_Nodes(Scene):
    def construct(self):
        t1 = Tex("{\\Large A Graph")
        t1.move_to([0,3,0])
        coords = [[0, 0], [1.5, 2], [-4, 1.2], [2.4, -1.2], [-3, -1.7], [-2.8, 1.7], [-1, -2], [-0.5, 2.2],
                  [-2, -0.5], [1.2, -2.1], [3, 0.5], [1, 0.5]]
        np_coords = [np.array(r + [0]) for r in coords]
        nodes = [Node('N', location=r) for r in np_coords]
        edges = [Edge(nodes[0], nodes[1]), Edge(nodes[0], nodes[11]), Edge(nodes[0], nodes[8]),
                    Edge(nodes[0], nodes[6]), Edge(nodes[6], nodes[4]), Edge(nodes[6], nodes[8]),
                    Edge(nodes[11], nodes[3]), Edge(nodes[11], nodes[10]), Edge(nodes[8], nodes[4]),
                    Edge(nodes[8], nodes[5]), Edge(nodes[3], nodes[9])]
        self.add(t1, *nodes, *edges)
        self.wait()
        self.play(*(TransformNodeHighlight(node, True) for node in nodes), run_time=0.5)
        self.wait(0.5)
        self.play(*(TransformNodeHighlight(node, False) for node in nodes), run_time=0.5)
        self.wait()

class Highlight_Edges(Scene):
    def construct(self):
        t1 = Tex("{\\Large A Graph")
        t1.move_to([0,3,0])
        coords = [[0, 0], [1.5, 2], [-4, 1.2], [2.4, -1.2], [-3, -1.7], [-2.8, 1.7], [-1, -2], [-0.5, 2.2],
                  [-2, -0.5], [1.2, -2.1], [3, 0.5], [1, 0.5]]
        np_coords = [np.array(r + [0]) for r in coords]
        nodes = [Node('N', location=r) for r in np_coords]
        edges = [Edge(nodes[0], nodes[1]), Edge(nodes[0], nodes[11]), Edge(nodes[0], nodes[8]),
                    Edge(nodes[0], nodes[6]), Edge(nodes[6], nodes[4]), Edge(nodes[6], nodes[8]),
                    Edge(nodes[11], nodes[3]), Edge(nodes[11], nodes[10]), Edge(nodes[8], nodes[4]),
                    Edge(nodes[8], nodes[5]), Edge(nodes[3], nodes[9])]
        self.add(t1, *nodes, *edges)
        self.wait()
        self.play(*(TransformEdgeHighlight(edge, HIGHLIGHT) for edge in edges), run_time=0.5)
        self.wait(0.5)
        self.play(*(TransformEdgeHighlight(node, INERT_EDGE_COLOR) for node in edges), run_time=0.5)
        self.wait()