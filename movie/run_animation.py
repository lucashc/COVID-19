import os
import shutil

# If it complains about files not existing, remove the partial_movie_files for that file.
# It seems it sometimes expects a cached file that does not exist. Don't know how to fix.

# SETTINGS #
file = 'graph_intro'       # must be in same folder
scene_name = 'Highlight_Edges'
render_setting = '-pl'           # -p for HD 60fps, -pl for 480p15, -s for last frame
if render_setting == '-pl':
    path = os.getcwd() + '/media/videos/' + file + '/480p15/partial_movie_files'
elif render_setting == '-p':
    path = os.getcwd() + '/media/videos/' + file + '/1080p60/partial_movie_files'

# -------- #


def run_animation(filename, scene_name, render_setting='-p'):
    if os.name == 'nt':  # Windows
        os.system(f"python -m manim {filename} {scene_name} {render_setting}")
    elif os.name == 'posix':  # Unix-based
        os.system(f"python3 -m manim '{filename}' {scene_name} {render_setting}")
    else:
        SystemError("Platform not supported")
    if render_setting in ('-pl', '-p'): shutil.rmtree(path)


filename = os.getcwd() + '/' + file + '.py'
print(filename)
run_animation(filename, scene_name, render_setting)
