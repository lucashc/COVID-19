import os

# NOTE: make sure to close the python file containing the manim code

# SETTINGS #
file = 'simple_infection'       # must be in same folder
scene_name = 'Graph'
render_setting = '-p'           # -p for HD 60fps, -pl for 480p15, -s for last frame
# -------- #


def run_animation(filename, scene_name, render_setting='-p'):
    if os.name == 'nt':  # Windows
        os.system(f"python -m manim {filename} {scene_name} {render_setting}")
    elif os.name == 'posix':  # Unix-based
        os.system(f"python3.7 -m manim {filename} {scene_name} {render_setting}")
    else:
        SystemError("Platform not supported")


filename = os.getcwd() + '/' + file + '.py'
print(filename)
run_animation(filename, scene_name, render_setting)
