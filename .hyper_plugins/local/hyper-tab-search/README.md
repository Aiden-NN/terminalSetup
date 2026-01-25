# hyper-tab-search

A Hyper terminal plugin that adds Warp-like tab/session search functionality.

## Features

- 🔍 Fuzzy search through all open tabs
- ⌨️ Keyboard-driven navigation
- 🎨 Clean, modern UI overlay
- ⚡ Fast and lightweight

## Installation

### From local directory

1. Clone or download this plugin to a local directory
2. Install dependencies:
   ```bash
   cd hyper-tab-search
   npm install
   ```
3. Link the plugin:
   ```bash
   npm link
   ```
4. In your Hyper config directory, link the plugin:
   ```bash
   cd ~/.hyper_plugins/local
   npm link hyper-tab-search
   ```
5. Add the plugin to your `~/.hyper.js` config:
   ```js
   module.exports = {
     config: {
       // ...
     },
     plugins: ['hyper-tab-search'],
   };
   ```

### From npm (if published)

Add to your `~/.hyper.js`:

```js
module.exports = {
  config: {
    // ...
  },
  plugins: ['hyper-tab-search'],
};
```

Then restart Hyper or run `Plugins > Update All` from the menu.

## Usage

1. Press `Cmd+K` (Mac) or `Ctrl+K` (Windows/Linux) to open the tab search overlay
2. Type to search through your open tabs
3. Use arrow keys (↑/↓) to navigate through results
4. Press `Enter` to switch to the selected tab
5. Press `Esc` to close the search overlay

## Keyboard Shortcuts

- `Cmd+K` / `Ctrl+K` - Toggle tab search overlay
- `↑` / `↓` - Navigate through search results
- `Enter` - Select highlighted tab
- `Esc` - Close search overlay

## Configuration

You can customize the keyboard shortcut in your `~/.hyper.js`:

```js
module.exports = {
  config: {
    tabSearchShortcut: 'cmd+k', // or 'ctrl+shift+p', etc.
  },
};
```

## Development

```bash
npm install
npm link
```

Then link in your Hyper plugins directory as shown in the installation steps.

## License

MIT
