# Sandbox Visualizer of Higher Dimensional Shapes
## Folder structure
    1. assets - includes all the images present in the application
    2. configs - includes .json file that defines added shapes
    3. docs - includes web build of the project. Refer to the **Web build guide** section to learn more
    4. scenes - includes all Godot scenes that are present in the project
    5. scripts - includes all GDScript code that is present in the project
    6. themes - includes Godot themes to configure the visual appearance of UI elements
    7. godot/git files - .editorconfig, .gitattributes, .gitignore, export_presets.cfg
    8. Readme.md - File you are currently reading
    9. project.godot - main Godot project file, open it in Godot to see the whole application

## Installation guide
  1. Download this archive, unpack it somewhere on your machine
  2. Install Godot 4.5 from the official website [https://godotengine.org/download/archive/4.5-stable/]
  3. Run the Godot exe (Godot_v4.5-stable_win64.exe) (Assuming you are on Windows)
  4. In Godot's project manager in the top left click "Import", locate the folder for the unpacked archive (Sandbox-Visualizer-for-Higher-Dimensional-Shapes-main)
  5. Inside the folder, select "project.godot"
  6. To run the project, press F5 or press the play Run button in the top right of the editor
  7. Done

## Web build guide

If you want to rebuild the web version of the app, follow these steps (note that an already working build exists inside the /docs directory):
  1. Inside the editor, in the top left corner press "Project"
  2. Then press "Export.."
  3. On the left, there should be a preset "Web (Runnable)", select that.
  4. Press "Export Project..."
  5. IMPORTANT: Select the /docs directory, file name should be "index.html"
  6. Untick "Export With Debug"
  7. Press "Save"
  8. Confirm overwrite

Done, now to test this in a browser environment you need to start up a local server.
Assuming you have Python installed on your machine ([https://www.python.org/downloads/]).
Commands listed here are for Windows:
  1. Open the project root directory in the terminal.
  2. Execute ```cd .\docs\``` in the terminal. (Change directory to /docs)
  3. Execute ```python -m http.server``` in the terminal. (Start up the server)
  4. Python will print the port on which the server is active (usually 8000)
  5. Open your browser
  6. Navigate to "http://localhost:8000/" (insert your port number if different instead of 8000)
  7. Done, you should see the web build running locally inside your browser.

## Github repo

This whole project is accessible as a repository at: https://github.com/madam6/Sandbox-Visualizer-for-Higher-Dimensional-Shapes

## Live version

Live version of the app is running at: https://madam6.github.io/Sandbox-Visualizer-for-Higher-Dimensional-Shapes/