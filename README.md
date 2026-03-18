# TreeNotes

A hierarchical note-taking addon for World of Warcraft with support for raid symbols.

## Features

- 📚 **Three-tier Organization**: Organize your notes in Notebooks → Chapters → Pages
- 🎯 **Raid Symbol Support**: Quickly insert raid markers ({skull}, {cross}, {square}, etc.) into your notes
- 🌳 **Tree View Navigation**: Expandable/collapsible tree structure for easy navigation
- 💾 **Persistent Storage**: All notes are automatically saved to your WoW saved variables
- ✏️ **Live Editing**: Changes are saved instantly as you type
- 🖱️ **Context Menus**: Right-click to delete items

## Installation

1. Download or clone this repository
2. Copy the `TreeNotes` folder to your WoW AddOns directory:
   - Windows: `C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns\`
   - Mac: `/Applications/World of Warcraft/_retail_/Interface/AddOns/`
3. Restart WoW or reload your UI with `/reload`

## Usage

### Opening TreeNotes

Type `/treenotes` in the chat to open the main window.

### Creating Structure

1. **Create a Notebook**: Click the `+Notebook` button in the tree panel
2. **Create a Chapter**: Select a notebook, then click `+Chapter`
3. **Create a Page**: Select a chapter, then click `+Page`

### Editing Content

- **Left-click** on any item in the tree to select it
- Edit the title in the "Title" field
- For pages, edit content in the large text area below
- **Right-click** on any item to delete it

### Using Raid Symbols

When editing a page, click any of the symbol buttons at the bottom to insert raid markers:
- **S** = Skull
- **C** = Cross
- **S** = Square
- **M** = Moon
- **T** = Triangle
- **D** = Diamond
- **C** = Circle
- **S** = Star

Symbols are inserted at your cursor position as `{symbol}` text.

## Interface Overview

```
┌─────────────────────────────────────────────┐
│              TreeNotes                       │
├───────────────┬──────────────────────────────┤
│  Tree View    │  Content Editor              │
│               │                              │
│  ⊕ Notebook 1 │  Title: [____________]       │
│    ⊕ Ch. 1    │                              │
│      • Page 1 │  Content:                    │
│      • Page 2 │  ┌──────────────────────┐   │
│    ⊟ Ch. 2    │  │                      │   │
│               │  │  Your notes here...  │   │
│  ⊕ Notebook 2 │  │                      │   │
│               │  └──────────────────────┘   │
│               │                              │
│               │  Symbols: S C S M T D C S    │
├───────────────┴──────────────────────────────┤
│ +Notebook | +Chapter | +Page                │
└──────────────────────────────────────────────┘
```

## File Structure

```
TreeNotes/
├── Core.lua         # Core functionality and data management
├── UI.lua           # User interface and interaction handling
├── TreeNotes.toc    # Addon metadata
└── README.md        # This file
```

## Technical Details

### Data Structure

Notes are stored in a three-level hierarchy:

```lua
TreeNotesDB = {
    notebooks = {
        {
            id = "unique_id",
            title = "Notebook Title",
            chapters = {
                {
                    id = "unique_id",
                    title = "Chapter Title",
                    pages = {
                        {
                            id = "unique_id",
                            title = "Page Title",
                            content = "Page content..."
                        }
                    }
                }
            }
        }
    }
}
```

### Saved Variables

All data is stored in the `TreeNotesDB` saved variable, which persists between sessions.

## Requirements

- World of Warcraft (tested on interface version 20505)
- No external dependencies

## Known Limitations

- No search functionality (yet)
- No export/import features (yet)
- Basic text formatting only
- Single-column layout only

## Future Enhancements

- [ ] Search across all notes
- [ ] Export/import functionality
- [ ] Rich text formatting
- [ ] Tagging system
- [ ] Quick access/favorites
- [ ] Note templates
- [ ] Drag-and-drop reordering

## Contributing

Contributions are welcome! Feel free to:
- Report bugs
- Suggest features
- Submit pull requests

## License

This project is open source. Feel free to use and modify as needed.

## Credits

Created for the WoW AddOn development community.

---

**Tip**: Press `ESC` or click the X button to close the TreeNotes window.
