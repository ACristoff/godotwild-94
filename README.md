# Godot Library Components

Reusable components for godot projects @ Beret Parade

# Instructions:
Copy the project over, rename it, do what you have to do

# Folder directory:
We've update the folders from an Assets / Game split to a structure where assets live in the same folder as the node that uses it most. However this demands people think about where they place things.

## Characters
Nodes like player character, NPCs, enemies

## Data
Hosts data like generated data, saves, logs, etc.

## Lib
Nodes and hooks, reused through the game or handle very specific tasks
### Audio Manager
Is a global shortcut for playing audio files. Has preset functions that route to specific audio busses, returns the audio player that was used. Also hosts premade functions for things like switching between music tracks instead of doing it manually.
### Game Manager
Is the root node, hosts all the functions responsible for hot-swapping child nodes and persists game-wide data. Common structure in many games.
### Signal Bus
Contains and deploys signals that will be used across various parts of the game. This is a good shortcut when the relationship between nodes is unclear, or signal needs to be ingested across various and undetermined amount of nodes.
### Level Manager
Is responsible for swapping out levels, is the parent node for level-wide data persistence.

## UI
Nodes related to menus, HUD and other UI elements. Also includes reusable UI components

## World
Nodes that host specific levels or make up the world space

# TODO
## Settings
### Sound Menu
### Resolutions
### Graphics Quality
## Sound Manager
## Title Screen
## Credits
## Particles System
## Dialogue System
