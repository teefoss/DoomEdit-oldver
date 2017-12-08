# DoomEdit
A Doom level editor for macOS.

**DoomEdit** is a loose port of id Software's DoomEd. Although similar in structure and appearance, DoomEdit will modernize DoomEd's interface. For now, like DoomEd, DoomEdit reads a .dwd file. Eventually, (if I can do it) doomBSP will be ported as well to allow saving directly to a WAD. As an homage to the original, DoomEdit uses the term *point* rather than *vertex*.

### Current Status

Almost no features yet!

The map view window appears with a pre-loaded Doom map and draws lines, points, and things.

## Planned Features

### Edit Mode
Like DoomEd's 'Select Tool', DoomEdit will have 'Edit Mode', where one can select, move, and right-click to edit an object or objects' properties in a pop-up window. This almost completely eliminates the need for constant switching between modes.

### Quick Views
Holding the appropriate key for a Quick View allows you to quickly view information directly in the map view and edit specific properties. For example:

- **Line View**: holding L shows the line length by each line in the map view. Selecting, moving, and editing is limited to lines only.
- **Floor View**: holding F draws all floor textures in sectors in the map view. Right-click a sector to edit just the floor texture.
- **Thing View**: holding T shows the type, and actual game size in the map view. Selecting, moving, and editing is limited to things only.
- **Skill 3 View**: holding 3 shows only things flagged as skill 3 or lower.
- As well as Ceiling View, Sector View, Light Level View, and more...

A Quick View can be locked on (e.g. shift-T) if needing to work in that view for a while. There will be an option to make this default behavior, if a user is more comfortable working with the usual vertex/line/sector/thing modes.

## About the Author

I picked up programming as a hobby recently, so this is very much a learning project. It's quite an ambitious project, so progress will be beyond slow, code will be ugly, and release (if ever) will not be for quite a long time!
