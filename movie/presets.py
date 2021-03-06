from manim import *
import numpy as np

# don't be afraid to change these if you find better colors
class preset_style:
    def __init__(self, N_COLOR, I_COLOR, S_COLOR, R_COLOR, J_COLOR, \
        INERT_EDGE_COLOR, INFECTING_EDGE_COLOR, style = 'hollow', \
        E_N_COLOR = WHITE, E_I_COLOR = WHITE, E_S_COLOR = WHITE, E_R_COLOR = WHITE, E_J_COLOR = WHITE, HIGHLIGHT = WHITE):
        self.I_COLOR = I_COLOR
        self.S_COLOR = S_COLOR
        self.R_COLOR = R_COLOR
        self.J_COLOR = J_COLOR
        self.N_COLOR = N_COLOR
        self.E_N_COLOR = E_N_COLOR
        self.E_I_COLOR = E_I_COLOR
        self.E_S_COLOR = E_S_COLOR
        self.E_R_COLOR = E_R_COLOR
        self.E_J_COLOR = E_J_COLOR
        self.HIGHLIGHT = HIGHLIGHT
        self.style = style
        self.INERT_EDGE_COLOR = INERT_EDGE_COLOR
        self.INFECTING_EDGE_COLOR = INFECTING_EDGE_COLOR

filled = preset_style('#CBDEE9', '#F61D1D', '#0AACEE', '#0DEE0A', '#F6BD1D', '#CBDEE9', '#F61D1D', 'filled',\
 '#2c3033', '#4a0b0b', '#03354a', '#044003', '#453508', '#ffff00')
hole = preset_style('#CBDEE9', '#F61D1D', '#0AACEE', '#0DEE0A', '#F6BD1D', '#CBDEE9', '#F61D1D')

style = filled

I_COLOR = style.I_COLOR
S_COLOR = style.S_COLOR
R_COLOR = style.R_COLOR
J_COLOR = style.J_COLOR
N_COLOR = style.N_COLOR
E_N_COLOR = style.E_N_COLOR
E_I_COLOR = style.E_I_COLOR
E_S_COLOR = style.E_S_COLOR
E_R_COLOR = style.E_R_COLOR
E_J_COLOR = style.E_J_COLOR
INERT_EDGE_COLOR = style.INERT_EDGE_COLOR
INFECTING_EDGE_COLOR = style.INFECTING_EDGE_COLOR
HIGHLIGHT = style.HIGHLIGHT
HEADER_SCALE = 2.2

border_color_dict = {'N': N_COLOR, 'S': S_COLOR, 'I': I_COLOR, 'R': R_COLOR, 'J': J_COLOR}
fill_color_dict = {'N': E_N_COLOR, 'S': E_S_COLOR, 'I': E_I_COLOR, 'R': E_R_COLOR, 'J': E_J_COLOR}

class Node(Circle):
    def __init__(self, status, location=ORIGIN, radius=0.3, style=style.style, highlight=False):
        self.status = status
        self.location = location
        self.radius = radius
        self.style = style
        self.highlight = highlight
        if self.style == 'hollow':
            self.style_dict = {'color': border_color_dict[status]}
        elif self.style == 'filled':
            self.style_dict = {'color': border_color_dict[status], 'fill_color': fill_color_dict[status],
                               'fill_opacity': 1}
        if highlight:
            self.style_dict['color'] = HIGHLIGHT

        Circle.__init__(self, arc_center=location, radius=radius, **self.style_dict)

    def status_replica(self, new_status):  # create copy except for new status
        return Node(new_status, location=self.location, radius=self.radius, style=self.style)
    
    def highlight_replica(self, highlight=False):
        return Node(status=self.status, location=self.location, radius=self.radius, style=self.style, highlight=highlight)



class Edge(Line):
    def __init__(self, node1, node2, color=INERT_EDGE_COLOR):  # order matters for animation
        connecting_vector = node2.location - node1.location
        unit_vector = connecting_vector/np.linalg.norm(connecting_vector)
        self.starting_point = node1.location + unit_vector*node1.radius + 0.02*unit_vector
        self.ending_point = node2.location - unit_vector*node2.radius - 0.02*unit_vector
        self.color = color
        Line.__init__(self, start=self.starting_point, end=self.ending_point, color=color)

    def color_replica(self, new_color):
        return Line(self.starting_point, self.ending_point, color=new_color)

    def set_stroke_width(self, stroke_width):
        return Line(self.starting_point, self.ending_point, color=self.color, stroke_width=stroke_width)

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

def TransformNodeHighlight(node, highlight=True, **kwargs):
    return Transform(node, node.highlight_replica(highlight), **kwargs)


def TransformEdgeHighlight(edge, color, **kwargs):
    return Transform(edge, edge.color_replica(color), **kwargs)

def ConnectNodes(node1, node2):  # achteraf gezien is dit niet zo handig, aangezien je het Edge object nodig hebt
    edge = Edge(node1, node2)    # om te kunnen infecteren
    return ShowCreation(edge)

def NewlyInfect(node):  # lui, ik weet het
    return TransformNodeStatus(node, 'J')

def Infect(node):
    return TransformNodeStatus(node, 'I')

def Recover(node):
    return  TransformNodeStatus(node, 'R')
