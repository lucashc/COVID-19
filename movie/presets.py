from manim import *
import numpy as np

# don't be afraid to change these if you find better colors
I_COLOR = '#F61D1D'
S_COLOR = '#0AACEE'
R_COLOR = '#0DEE0A'
J_COLOR = '#F6BD1D'
INERT_EDGE_COLOR = '#CBDEE9' # WHITE
INFECTING_EDGE_COLOR = I_COLOR
HEADER_SCALE = 2.2

color_dict = {'S': S_COLOR, 'I': I_COLOR, 'R': R_COLOR, 'J': J_COLOR}


class Node(Circle):
    def __init__(self, status, location=ORIGIN, radius=0.3, style='hollow'):
        self.status = status
        self.location = location
        self.radius = radius
        self.style = style
        if style == 'hollow':
            self.style_dict = {'color': color_dict[status]}
        elif style == 'filled':
            self.style_dict = {'color': WHITE, 'fill_color': color_dict[status],
                               'fill_opacity': 1}

        Circle.__init__(self, arc_center=location, radius=radius, **self.style_dict)

    def status_replica(self, new_status):  # create copy except for new status
        return Node(new_status, location=self.location, radius=self.radius, style=self.style)



class Edge(Line):
    def __init__(self, node1, node2, color=INERT_EDGE_COLOR):  # order matters for animation
        connecting_vector = node2.location - node1.location
        unit_vector = connecting_vector/np.linalg.norm(connecting_vector)
        self.starting_point = node1.location + unit_vector*node1.radius
        self.ending_point = node2.location - unit_vector*node2.radius
        Line.__init__(self, start=self.starting_point, end=self.ending_point, color=color)

    def color_replica(self, new_color):
        return Line(self.starting_point, self.ending_point, color=new_color)


class DirectedEdge(Vector):
    def __init__(self, node1, node2, color=INERT_EDGE_COLOR):
        connecting_vector = node2.location - node1.location
        unit_vector = connecting_vector/np.linalg.norm(connecting_vector)
        self.starting_point = node1.location + unit_vector*node1.radius
        self.ending_point = node2.location - unit_vector*node2.radius
        Vector.__init__(self, start=self.starting_point, end=self.ending_point, color=color)

    def color_replica(self, new_color):
        return Arrow(self.starting_point, self.ending_point, color=new_color)


def InfectEdge(edge):
    replica = edge.color_replica(INFECTING_EDGE_COLOR)
    return ShowCreation(replica)


def InfectEdgeReturn(edge):   # in case you need the edge
    replica = edge.color_replica(INFECTING_EDGE_COLOR)
    return ShowCreation(replica), replica


def TransformNodeStatus(node, new_status):
    return Transform(node, node.status_replica(new_status))


def ConnectNodes(node1, node2):  # achteraf gezien is dit niet zo handig, aangezien je het Edge object nodig hebt
    edge = Edge(node1, node2)    # om te kunnen infecteren
    return ShowCreation(edge)



