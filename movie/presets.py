from manim import *
import numpy as np

# don't be afraid to change these if you find better colors
class preset_style:
    def __init__(self, I_COLOR, S_COLOR, R_COLOR, J_COLOR, \
        INERT_EDGE_COLOR, INFECTING_EDGE_COLOR, style = 'hollow', \
        E_I_COLOR = WHITE, E_S_COLOR = WHITE, E_R_COLOR = WHITE, E_J_COLOR = WHITE):
        self.I_COLOR = I_COLOR
        self.S_COLOR = S_COLOR
        self.R_COLOR = R_COLOR
        self.J_COLOR = J_COLOR
        self.E_I_COLOR = E_I_COLOR
        self.E_S_COLOR = E_S_COLOR
        self.E_R_COLOR = E_R_COLOR
        self.E_J_COLOR = E_J_COLOR
        self.style = style
        self.INERT_EDGE_COLOR = INERT_EDGE_COLOR
        self.INFECTING_EDGE_COLOR = INFECTING_EDGE_COLOR

filled = preset_style('#F61D1D', '#0AACEE', '#0DEE0A', '#F6BD1D', '#CBDEE9', '#F61D1D', 'filled',\
 '#4a0b0b', '#03354a', '#044003', '#453508')
hole = preset_style('#F61D1D', '#0AACEE', '#0DEE0A', '#F6BD1D', '#CBDEE9', '#F61D1D')

style = filled

I_COLOR = style.I_COLOR
S_COLOR = style.S_COLOR
R_COLOR = style.R_COLOR
J_COLOR = style.J_COLOR
E_I_COLOR = style.E_I_COLOR
E_S_COLOR = style.E_S_COLOR
E_R_COLOR = style.E_R_COLOR
E_J_COLOR = style.E_J_COLOR
INERT_EDGE_COLOR = style.INERT_EDGE_COLOR
INFECTING_EDGE_COLOR = style.INFECTING_EDGE_COLOR
HEADER_SCALE = 2.2

border_color_dict = {'S': S_COLOR, 'I': I_COLOR, 'R': R_COLOR, 'J': J_COLOR}
fill_color_dict = {'S': E_S_COLOR, 'I': E_I_COLOR, 'R': E_R_COLOR, 'J': E_J_COLOR}

class Node(Circle):
    def __init__(self, status, location=ORIGIN, radius=0.3, style=style.style):
        self.status = status
        self.location = location
        self.radius = radius
        self.style = style
        if self.style == 'hollow':
            self.style_dict = {'color': border_color_dict[status]}
        elif self.style == 'filled':
            self.style_dict = {'color': border_color_dict[status], 'fill_color': fill_color_dict[status],
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



