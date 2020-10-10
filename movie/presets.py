from manim import *
import numpy as np

# don't be afraid to change these if you find better colors
I_COLOR = RED  # '#EE0A0A' # this color is maybe too bright
S_COLOR = '#0AACEE'
R_COLOR = '#0DEE0A'
J_COLOR = '#EE9B0A'
color_dict = {'S': S_COLOR, 'I': I_COLOR, 'R': R_COLOR, 'J': J_COLOR}

class Node(Circle):
    def __init__(self, status, location=ORIGIN, radius=0.3, style='hollow'):
        self.status = status
        self.location = location
        self.radius = radius
        if style == 'hollow':
            self.style_dict = {'color': color_dict[status]}
        elif style == 'filled':
            self.style_dict = {'color': WHITE, 'fill_color': color_dict[status],
                               'fill_opacity': 1}

        Circle.__init__(self, arc_center=location, radius=radius, **self.style_dict)

    def update_status(self, new_status):
        return Circle(arc_center=self.location, radius=self.radius, **self.style_dict)




class Edge(Line):
    def __init__(self, node1, node2, color=WHITE):  # order matters for animation
        connecting_vector = node2.location - node1.location
        unit_vector = connecting_vector/np.linalg.norm(connecting_vector)
        starting_point = node1.location + unit_vector*node1.radius
        ending_point = node2.location - unit_vector*node2.radius
        Line.__init__(self, start=starting_point, end=ending_point, color=color)

