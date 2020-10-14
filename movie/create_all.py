import os
from shutil import copyfile
from pathlib import Path

# Format 
scenes = [
    "show_density.Density",
    "simulation_animation.SimulationWithZoomSave"
]

pairings = map(lambda x: tuple(x.split('.')), scenes)
render_setting = ''           # -p for HD 60fps, -pl for 480p15, -s for last frame

def run_animation(filename, scene_name, render_setting='-p'):
    if os.name == 'nt':  # Windows
        os.system(f"python -m manim {filename} {scene_name} {render_setting}")
    elif os.name == 'posix':  # Unix-based
        os.system(f"python3 -m manim '{filename}' {scene_name} {render_setting}")
    else:
        SystemError("Platform not supported")

x = Path(os.getcwd() + '/finished').mkdir(parents=True, exist_ok=True)

for filename, scene_name in pairings:
    filename_abs = os.getcwd() + '/' + filename + '.py'
    print(f"Making scene {scene_name} from {filename}")
    run_animation(filename_abs, scene_name, render_setting)
    # Copy finished file
    moviepath = os.getcwd() + '/media/videos/' + filename + '/1080p60/' + scene_name + '.mp4'
    to = os.getcwd() + '/finished/' + scene_name + '.mp4'
    copyfile(moviepath, to)
    print(f"Movie file from {scene_name} copied to finished")

print("Done.")
