from manim import *
from presets import *
import numpy as np
import random
import itertools


class NewSimulation(Scene):  # to be played after TrialConnection, so nodes are simply added initially
    def construct(self):
        def connection_phase(new_connections, nodes, edges):
            source_nodes = []
            for i, j in new_connections:
                source_nodes.append(i)
                edges[i][j] = Edge(nodes[i], nodes[j])
            source_nodes = set(source_nodes)
            self.play(*(ShowCreation(edges[i][j]) for i, j in new_connections),
                      *(Infect(nodes[k]) for k in source_nodes))
            self.wait()

        def infection_phase(new_infections, nodes, edges):
            self.play(*(InfectEdge(edges[i][j]) for i, j in new_infections))
            self.play(*(NewlyInfect(nodes[j]) for i, j in new_infections))
            self.wait()

        def recovery_phase(new_recoveries, nodes, edges):  # edges puur voor consistency
            self.play(*(Recover(nodes[i]) for i in new_recoveries))

        # 3
        coords = [[0, 0], [1.5, 2], [-0.5, 2.2], [-3.2, 5.5], [-2.8, 1.7], [-4, 1.2],
                  [-2, -0.5], [-3, -1.7], [-1, -2], [1.2, -2.1], [2.4, -1.2], [3, 0.5], [1, 0.5]]
        # arranged counter clockwise from the 45 degree line
        np_coords = [np.array(r + [0]) for r in coords]
        nodes = [Node('S', location=r) for r in np_coords]
        nodes[0] = nodes[0].status_replica('I')  # already infected in TrialConnection
        self.add(*(node for node in nodes))
        edges = [[None for i in range(len(nodes))] for i in range(len(nodes))]
        for i in [1, 3, 6, 8, 12]:
            edge = Edge(nodes[0], nodes[i])
            edges[0][i] = edge
            self.add(edge)

        # 4
        new_infections = [(0,8), (0,12)]
        infection_phase(new_infections, nodes, edges)

        # 5
        new_connections = [(8, 6), (8, 7), (12, 10), (12, 11)]
        connection_phase(new_connections, nodes, edges)

        # 6
        new_infections = [(8, 6), (12, 10)]
        infection_phase(new_infections, nodes, edges)

        # 7
        new_infections = [(0, 1)]
        infection_phase(new_infections, nodes, edges)

        # 8
        new_connections = [(6, 4), (6, 7), (1, 11), (10, 9)]
        connection_phase(new_connections, nodes, edges)

        # 9
        new_infections = [(0, 3), (6, 4), (8, 7)]
        infection_phase(new_infections, nodes, edges)

        # 10
        new_recoveries = [0, 12]
        recovery_phase(new_recoveries, nodes, edges)


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
                  TransformNodeStatus(nodes[8], 'I'), TransformNodeStatus(nodes[3], 'I'),
                  TransformNodeStatus(nodes[1], 'I'))
        self.play(InfectEdge(edges3[1]), InfectEdge(edges2[0]))
        self.play(TransformNodeStatus(nodes[5], 'J'), TransformNodeStatus(nodes[4], 'J'),
                  TransformNodeStatus(nodes[9], 'J'))
        self.wait()


class TrialConnection(MovingCameraScene):
    def construct(self):
        #title = Tex("A newly infected node tries to connect to all other nodes").to_edge(UP)
        #self.play(Write(title))

        # coords = [[0, 0], [1.5, 2], [-4, 1.2], [2.4, -1.2], [-3, -1.7], [-2.8, 1.7], [-1, -2], [-0.5, 2.2],
        #           [-2, -0.5], [1.2, -2.1], [3, 0.5], [1, 0.5]]
        coords = [[0, 0], [1.5, 2], [-0.5, 2.2], [-3.2, 5.5], [-2.8, 1.7], [-4, 1.2],
                  [-2, -0.5], [-3, -1.7], [-1, -2], [1.2, -2.1], [2.4, -1.2],  [3, 0.5],  [1, 0.5]]
        # arranged counter clockwise from the 45 degree line
        np_coords = [np.array(r+[0]) for r in coords]
        nodes = [Node('S', location=r) for r in np_coords]
        nodes[0] = nodes[0].status_replica('J')
        self.add(*nodes)
        # for n in nodes:
        #     self.add(n)
        #     self.wait(0.2)

        edges = [Edge(nodes[0], node, color=GRAY) for node in nodes[1:]]
        succeed = [1, 3, 6, 8, 12]
        one_by_one_cutoff = 4
        for i, edge in enumerate(edges[:one_by_one_cutoff]):
            self.play(ShowCreation(edge))
            if i + 1 in succeed:  # +1 since 0 will not be connected to
                if i + 1 == 3:
                    self.play(self.camera_frame.set_height, self.camera_frame.get_height()*2)
                self.play(FadeIn(edge.color_replica(R_COLOR)))  # '#1BEE0A')))
                self.play(FadeIn(edge.color_replica(INERT_EDGE_COLOR)))
                if i + 1 == 3:
                    self.play(self.camera_frame.set_height, self.camera_frame.get_height()*1/2)
            else:
                self.play(Transform(edge, edge.color_replica(I_COLOR)))  # RED )))
                self.play(Uncreate(edge))

        recolor_list = []
        replace_list = []
        for i, edge in enumerate(edges[one_by_one_cutoff:]):
            if i + 1 + one_by_one_cutoff in succeed:  # +1 as before, +4 since we start at 4
                recolor_list.append(FadeIn(edge.color_replica('#1BEE0A')))  # fade to green
                replace_list.append(FadeIn(edge.color_replica(INERT_EDGE_COLOR)))  # fade to white instead of gray
            else:
                recolor_list.append(Transform(edge, edge.color_replica(I_COLOR)))
                replace_list.append(Uncreate(edge))

        self.play(*[ShowCreation(edge) for edge in edges[one_by_one_cutoff:]])
        self.play(*[recolor for recolor in recolor_list])
        self.play(*[replacement for replacement in replace_list])
        self.wait()
        self.play(Infect(nodes[0]))
        self.wait()


class SimulationWithZoomSave(Scene):
    def construct(self):
        coords = [[0, 0], [1.5, 2], [-4, 1.2], [2.4, -1.2], [-3, -1.7], [-2.8, 1.7], [-1, -2], [-0.5, 2.2],
                  [-2, -0.5], [1.2, -2.1], [3, 0.5], [1, 0.5]]
        np_coords = [np.array(r + [0]) for r in coords]
        nodes = [Node('S', location=r) for r in np_coords]
        nodes[0] = nodes[0].status_replica('J')

        edges = [Edge(nodes[0], nodes[1]), Edge(nodes[0], nodes[11]), Edge(nodes[0], nodes[8]),
                 Edge(nodes[0], nodes[6])]
        edges2 = [Edge(nodes[6], nodes[4]), Edge(nodes[6], nodes[8]),
                  Edge(nodes[11], nodes[3]), Edge(nodes[11], nodes[10])]
        edges3 = [Edge(nodes[8], nodes[4]), Edge(nodes[8], nodes[5]), Edge(nodes[3], nodes[9])]
        infected_edges = [edge.color_replica(INFECTING_EDGE_COLOR) for edge in [edges[1], edges[3], edges2[1], edges2[2],
                                                                         edges2[0], edges3[1]]]

        I_nodes = [node.status_replica('I') for node in [nodes[8], nodes[3], nodes[6], nodes[11], nodes[0], nodes[1]]]
        J_nodes = [node.status_replica('J') for node in [nodes[4], nodes[5], nodes[9]]]
        x_coords = np.arange(-14, 15, 3, dtype=np.float64)
        y_coords = np.arange(-8, 9, 3, dtype=np.float64)

        grid = np.transpose([np.tile(x_coords, len(y_coords)), np.repeat(y_coords, len(x_coords))]) + \
               (np.random.rand(len(x_coords) * len(y_coords), 2) - 0.5) * 3


        outer_coords = [np.array([r[0], r[1], 0]) for r in grid if
                        not(abs(r[0]) < 2.8 and abs(r[1]) < 2.2)]
        outer_nodes = [Node('S', location=p) for p in outer_coords]

        all_nodes_and_edges = VGroup(*(nodes + J_nodes + I_nodes + edges +
                                       edges2 + edges3 + infected_edges + outer_nodes))
        self.add(all_nodes_and_edges)
        self.play(*(FadeIn(n) for n in outer_nodes))
        self.play(ScaleInPlace(all_nodes_and_edges, 0.5))
        self.wait()


class MovingCamZoom(MovingCameraScene):
    def construct(self):
        coords = [[0, 0], [1.5, 2], [-4, 1.2], [2.4, -1.2], [-3, -1.7], [-2.8, 1.7], [-1, -2], [-0.5, 2.2],
                  [-2, -0.5], [1.2, -2.1], [3, 0.5], [1, 0.5]]
        np_coords = [np.array(r + [0]) for r in coords]
        nodes = [Node('S', location=r) for r in np_coords]
        nodes[0] = nodes[0].status_replica('J')

        edges = [Edge(nodes[0], nodes[1]), Edge(nodes[0], nodes[11]), Edge(nodes[0], nodes[8]),
                 Edge(nodes[0], nodes[6])]
        edges2 = [Edge(nodes[6], nodes[4]), Edge(nodes[6], nodes[8]),
                  Edge(nodes[11], nodes[3]), Edge(nodes[11], nodes[10])]
        edges3 = [Edge(nodes[8], nodes[4]), Edge(nodes[8], nodes[5]), Edge(nodes[3], nodes[9])]
        infected_edges = [edge.color_replica(INFECTING_EDGE_COLOR) for edge in [edges[1], edges[3], edges2[1], edges2[2],
                                                                         edges2[0], edges3[1], edges[0], edges3[2]]]

        I_nodes = [node.status_replica('I') for node in [nodes[8], nodes[3], nodes[6], nodes[11], nodes[0], nodes[1]]]
        J_nodes = [node.status_replica('J') for node in [nodes[4], nodes[5], nodes[9]]]
        x_coords = np.arange(-14, 15, 3, dtype=np.float64)
        y_coords = np.arange(-8, 9, 3, dtype=np.float64)

        grid = np.transpose([np.tile(x_coords, len(y_coords)), np.repeat(y_coords, len(x_coords))]) + \
               (np.random.rand(len(x_coords) * len(y_coords), 2) -0.5) * 3

        outer_coords = [np.array([r[0], r[1], 0]) for r in grid if
                        not(abs(r[0]) < 2.8 and abs(r[1]) < 2.2)]
        outer_nodes = [Node('S', location=p) for p in outer_coords]

        all_nodes_and_edges = VGroup(*(nodes + J_nodes + I_nodes + edges +
                                       edges2 + edges3 + infected_edges ))
        self.add(all_nodes_and_edges)

        # first fade in nodes
        # self.play(*(FadeIn(n) for n in outer_nodes))
        # self.play(self.camera_frame.set_height, self.camera_frame.get_height()*2)

        # simultaneous
        self.play(self.camera_frame.set_height, self.camera_frame.get_height()*2,
                  *(FadeIn(n) for n in outer_nodes))

        self.wait()


class NodeTypes(Scene):
    def construct(self):
        # this is the intro part (better to keep separate and edit everything together)
        title_text = (Tex("Node types").scale(HEADER_SCALE)).to_edge(UP)
        self.play(Write(title_text))
        self.wait(1)
        legend_nodes = [Node(status, location=np.array([-2, 1-i, 0])) for i, status in enumerate(['S', 'I', 'R', 'J'])]
        legend_texts = ["Susceptible", "Infected", "Recovered", "Newly infected"]
        legend_texs = [Tex(status).next_to(node, buff=0.5) for status, node in zip(legend_texts, legend_nodes)]
        for i in range(4):
            self.play(GrowFromCenter(legend_nodes[i]), Write(legend_texs[i]))

        self.wait(1)
        all_objects = [title_text] + legend_nodes + legend_texs
        self.play(*[Uncreate(x) for x in all_objects])
        self.wait()


class Still(MovingCameraScene):
    def construct(self):
        coords = [[0, 0], [1.5, 2], [-4, 1.2], [2.4, -1.2], [-3, -1.7], [-2.8, 1.7], [-1, -2], [-0.5, 2.2],
                  [-2, -0.5], [1.2, -2.1], [3, 0.5], [1, 0.5]]
        np_coords = [np.array(r + [0]) for r in coords]
        nodes = [Node('S', location=r) for r in np_coords]
        nodes[0] = nodes[0].status_replica('J')

        edges = [Edge(nodes[0], nodes[1]), Edge(nodes[0], nodes[11]), Edge(nodes[0], nodes[8]),
                 Edge(nodes[0], nodes[6])]
        edges2 = [Edge(nodes[6], nodes[4]), Edge(nodes[6], nodes[8]),
                  Edge(nodes[11], nodes[3]), Edge(nodes[11], nodes[10])]
        edges3 = [Edge(nodes[8], nodes[4]), Edge(nodes[8], nodes[5]), Edge(nodes[3], nodes[9])]
        infected_edges = [edge.color_replica(INFECTING_EDGE_COLOR) for edge in [edges[1], edges[3], edges2[1], edges2[2],
                                                                         edges2[0], edges3[1], edges[0], edges3[2]]]

        I_nodes = [node.status_replica('I') for node in [nodes[8], nodes[3], nodes[6], nodes[11], nodes[0]]]
        J_nodes = [node.status_replica('J') for node in [nodes[4], nodes[5], nodes[9]]]
        nodes[1] = nodes[1].status_replica('R')
        x_coords = np.arange(-14, 15, 3, dtype=np.float64)
        y_coords = np.arange(-8, 9, 3, dtype=np.float64)

        grid = np.transpose([np.tile(x_coords, len(y_coords)), np.repeat(y_coords, len(x_coords))]) + \
               (np.random.rand(len(x_coords) * len(y_coords), 2) -0.5) * 3

        outer_coords = [np.array([r[0], r[1], 0]) for r in grid if
                        not(abs(r[0]) < 2.8 and abs(r[1]) < 2.2)]
        outer_nodes = [Node('S', location=p) for p in outer_coords]

        all_nodes_and_edges = VGroup(*(nodes + J_nodes + I_nodes + edges +
                                       edges2 + edges3 + infected_edges))
        self.add(all_nodes_and_edges)

        # first fade in nodes
        # self.play(*(FadeIn(n) for n in outer_nodes))
        # self.play(self.camera_frame.set_height, self.camera_frame.get_height()*2)

        # simultaneous

        self.wait()



class ZoomIntoGraph(MovingCameraScene):
    def construct(self):
        self.camera_frame.set_height(self.camera_frame.get_height()*20)
        image = ImageMobject('images/InitialInfections.png').scale(60)
        self.play(FadeIn(image))
        coords = [[0, 0], [1.5, 2], [-4, 1.2], [2.4, -1.2], [-3, -1.7], [-2.8, 1.7], [-1, -2], [-0.5, 2.2],
                  [-2, -0.5], [1.2, -2.1], [3, 0.5], [1, 0.5]]
        np_coords = [np.array(r + [0]) for r in coords]
        nodes = [Node('S', location=r) for r in np_coords]
        nodes[0] = nodes[0].status_replica('J')
        Nodes = VGroup(*nodes)

        # self.play(self.camera_frame.set_height, self.camera_frame.get_height()/40,
        #           FadeOutAndShift(image, 80*RIGHT, rate_func=lingering), FadeIn(init_node))

        self.play(ApplyMethod(image.shift, 16.8*RIGHT + 21/2*UP))
        self.play(self.camera_frame.set_height, self.camera_frame.get_height()/20, FadeOut(image),
                  FadeIn(Nodes, rate_func=lingering, run_time=2))

        self.wait()
