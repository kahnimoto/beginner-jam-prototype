# BJAM Stage 1 Prototype

Godot Game made for the Beginner Jam of the 100 Devs community

## How to play

Import to Godot 4.5.1 and run :D 

## How to create a new level

1. Duplicate a level in `scebes/levels` for example `ice_two.tscn`
2. Under `Scenery` node, there are 2 TileMapLayers, `DungeonBackground` is the important one that will control the map, while `Objects` are purely decorative. You can select either and draw a rectable with right mouse button to erase the current level. Then use the terrains in the Dungon tilmap to draw the map. Start drawing a big square of "Blank", then draw the interior walkable area with "Inside" and lastly draw the outline of the inside with "Dungeon" (aka walls). 
3. On the `DungeonBackground` tilemaplayer, using Tiles instead of Terrains, pick and draw individual challenge tiles like the different types of ice, pits or decaying tiles with different timer. The green tile will not decay. Place a door somewhere the player can get to.
4. On the `Objects` tilemaplayer, pick and place decorative items. At least place some torches, otherwise the game will be dark.
5. The decorative torches dont make lights, so in the `Lights` Node, delete all but 1 `PointLight2D` then place it on one of your decorative torches. Copy it and place copies on all your decorative torches. The lights are the exception to the grid snap, turn off grid snap and place them on the torches.
6. Next we place objects in the world the player can pick up. Use the ones in the level or instantate scenes. When moving these objects, make sure the Grid Snap is enabled and configured to 16 pixels
    6.1. `Key` the map must have at least 1 key object
    6.2. `Doorway` the map needs at least 1 doorway
    6.3. `Bridge` player can only carry 1 at a time
    6.4. `Sandbag` player can carry 3 at a time
When placing the doorway, place it on an inside node, not on the door. On the node, change the export variable to tell it which direction the door is. This is used for the spotlight feature.
7. In the world there can be Monsters, instantiate or copy this. Moving them on the grid with Grid Snap like objects. If you want them to move, add a child (in the level scene, not monster scene), called `PathNodes` and under this put Marker2D, at least two. The markers also need to be on the grid and walkable in direct cardinal lines.
8. Using Grid Snap to place the player where you want them to start.
9. In `global_game_manager.gd` ctrl+drag the new level.tscn file you made into the top of the file so it becomes a new const, i.e. `const LEVEL_ONE = preload("uid://c0rjmcisgel26")`. Then lower in the file add this to the levels array, maybe first so you can easily test it.
10. Play test it!

## Project Structure

- `/assets/external` : images used in the project
- `/docs` : post morten and other documentation
- `/docs/`[Post Mortem Stage 1](docs/stage_1_post_mortem.md)
- `/scenes/levels` : All the levels scenes
- `/scenes/objects` : Objects the player can pickup
- `/scenes/tests`
- `/scenes/ui` : HUD and start menu
- `/scenes` : Player and Monster scenes are here
- `/scripts/globals` : Autoloaded files
- `/scripts/interfaces/pickups.gd` : An abstract class all pickups extend
- `/scripts/items` : Pickup scripts and other items
- `/scripts/ui` : hud, overlay and start menu scripts
- `/scripts` : key scripts like the player, monster and turn_manager
- `/textures` : AtlasTextures made from the tilesheet
- `/tilesets` : DungeonTilset resource used by all TileMapLayers

