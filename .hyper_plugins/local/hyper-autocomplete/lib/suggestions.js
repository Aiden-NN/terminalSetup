var fs = require('fs');
var path = require('path');
var os = require('os');
var fuzzysort = require('fuzzysort');

var NAV_COMMANDS = new Set([
  'cd', 'z', 'open', 'agy', 'bat', 'cat', 'less', 'head', 'tail',
  'ls', 'vi', 'vim', 'nvim', 'code', 'nano', 'cp', 'mv', 'rm',
]);
var MAX_SUGGESTIONS = 8;
var HISTORY_FILE = path.join(os.homedir(), '.zsh_history');

var historyCache = [];
var historyMtime = 0;

function parseHistory() {
  try {
    var stat = fs.statSync(HISTORY_FILE);
    if (stat.mtimeMs === historyMtime && historyCache.length > 0) return historyCache;
    historyMtime = stat.mtimeMs;

    var raw = fs.readFileSync(HISTORY_FILE, 'utf8');
    var lines = raw.split('\n');
    var commands = [];
    var current = '';

    for (var i = 0; i < lines.length; i++) {
      var line = lines[i];
      if (line.startsWith(': ')) {
        if (current) commands.push(current);
        var match = line.match(/^: \d+:\d+;(.+)/);
        current = match ? match[1] : '';
      } else if (current) {
        current += line.startsWith('\\') ? line : '\n' + line;
      }
    }
    if (current) commands.push(current);

    var freq = new Map();
    for (var j = 0; j < commands.length; j++) {
      var clean = commands[j].replace(/\\\n/g, ' ').trim();
      if (clean) freq.set(clean, (freq.get(clean) || 0) + 1);
    }

    historyCache = Array.from(freq.entries())
      .map(function (entry) { return { cmd: entry[0], count: entry[1] }; })
      .sort(function (a, b) { return b.count - a.count; });

    return historyCache;
  } catch (e) {
    return historyCache;
  }
}

function getPathSuggestions(partial, cwd) {
  try {
    var dir, prefix;

    if (!partial) {
      dir = cwd;
      prefix = '';
    } else if (partial.startsWith('~')) {
      var expanded = partial.replace(/^~/, os.homedir());
      if (expanded.includes('/')) {
        dir = path.dirname(expanded);
        prefix = path.basename(expanded);
      } else {
        dir = os.homedir();
        prefix = '';
      }
    } else if (partial.includes('/')) {
      var resolved = path.isAbsolute(partial) ? partial : path.resolve(cwd, partial);
      try {
        if (fs.statSync(resolved).isDirectory()) {
          dir = resolved;
          prefix = '';
        } else {
          dir = path.dirname(resolved);
          prefix = path.basename(resolved);
        }
      } catch (e) {
        dir = path.dirname(resolved);
        prefix = path.basename(resolved);
      }
    } else {
      dir = cwd;
      prefix = partial;
    }

    var entries = fs.readdirSync(dir, { withFileTypes: true });
    var results = [];

    for (var i = 0; i < entries.length; i++) {
      var entry = entries[i];
      if (entry.name.startsWith('.') && !prefix.startsWith('.')) continue;
      if (prefix && !entry.name.toLowerCase().startsWith(prefix.toLowerCase())) continue;

      var isDir = entry.isDirectory();
      var suffix = isDir ? '/' : '';
      var displayPath;

      if (!partial || !partial.includes('/')) {
        displayPath = entry.name + suffix;
      } else {
        var partialDir = partial.substring(0, partial.lastIndexOf('/') + 1);
        displayPath = partialDir + entry.name + suffix;
      }

      results.push({
        text: displayPath,
        type: isDir ? 'folder' : 'file',
        score: entry.name.toLowerCase() === prefix.toLowerCase() ? 100 : 50,
      });
    }

    results.sort(function (a, b) {
      if (a.type === 'folder' && b.type !== 'folder') return -1;
      if (a.type !== 'folder' && b.type === 'folder') return 1;
      return b.score - a.score || a.text.localeCompare(b.text);
    });

    return results.slice(0, MAX_SUGGESTIONS);
  } catch (e) {
    return [];
  }
}

function getHistorySuggestions(input) {
  var history = parseHistory();
  if (!input || !input.trim()) return [];

  var results = fuzzysort.go(input, history, {
    key: 'cmd',
    limit: MAX_SUGGESTIONS,
    threshold: -500,
  });

  return results.map(function (r) {
    return {
      text: r.obj.cmd,
      type: 'history',
      score: r.score + r.obj.count,
    };
  });
}

function parseInputLine(line) {
  var trimmed = (line || '').trim();
  if (!trimmed) return { command: '', args: '', lastArg: '', full: '' };
  var parts = trimmed.split(/\s+/);
  var command = parts[0];
  var lastArg = parts.length > 1 ? parts[parts.length - 1] : '';
  return { command: command, lastArg: lastArg, full: trimmed };
}

function getSuggestions(inputLine, cwd) {
  var parsed = parseInputLine(inputLine);
  if (!parsed.command) return [];

  if (NAV_COMMANDS.has(parsed.command)) {
    return getPathSuggestions(parsed.lastArg || '', cwd || os.homedir());
  }

  return getHistorySuggestions(parsed.full).slice(0, MAX_SUGGESTIONS);
}

function getCompletionText(suggestion, inputLine) {
  var parsed = parseInputLine(inputLine);
  if (suggestion.type === 'history') return suggestion.text;
  if (!parsed.lastArg) return parsed.command + ' ' + suggestion.text;
  return inputLine.substring(0, inputLine.lastIndexOf(parsed.lastArg)) + suggestion.text;
}

module.exports = { getSuggestions: getSuggestions, getCompletionText: getCompletionText };
