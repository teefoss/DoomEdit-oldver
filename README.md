# DoomEdit
A Doom level editor for macOS.

**DoomEdit** is a loose port of id Software's DoomEd. Although similar in structure and appearance, DoomEdit will modernize DoomEd's interface. For now, like DoomEd, DoomEdit reads a .dwd file. ID Software's nobebuilder, DoomBSP, will be ported and integrated.

### Current Status

The app has most of the basic functionally and it's possible to load a map (.dwd), and edit it. DoomBSP has been integrated. doom.wad or doom2.wad is required.

## Planned Features

### Edit Mode
Like DoomEd's 'Select Tool', DoomEdit will have 'Edit Mode', where one can select, move, and right-click to edit an object or objects' properties in a pop-up window. This almost completely eliminates the need for constant switching between modes.

### Quick Views
Holding the appropriate key for a Quick View allows you to quickly view information directly in the map view and edit specific properties. For example:

- **Line View**: holding L shows the line length by each line in the map view. Selecting, moving, and editing is limited to lines only. (Implemented)
- **Floor View**: holding F draws all floor textures in sectors in the map view. Right-click a sector to edit just the floor texture.
- **Thing View**: holding T shows the type, and actual game size in the map view. Selecting, moving, and editing is limited to things only. (Parially implemented)

## About the Author

I picked up programming as a hobby recently, so this is very much a learning project. It's quite an ambitious project, so progress will be beyond slow, code will be ugly, and release (if ever) will not be for quite a long time!
