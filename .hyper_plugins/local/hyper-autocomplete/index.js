let storeRef = null;
let overlayContainer = null;
let activeXterm = null;
let shouldBlockTab = false;
let cwdTracker = {};

let overlayState = {
  visible: false,
  suggestions: [],
  selectedIndex: 0,
  inputLine: '',
  cursorPosition: null,
};

let getSuggestions, getCompletionText;
try {
  const engine = require('./lib/suggestions');
  getSuggestions = engine.getSuggestions;
  getCompletionText = engine.getCompletionText;
} catch (err) {
  console.error('[hyper-autocomplete] Failed to load suggestions:', err);
}

function getActiveSession() {
  if (!storeRef) return { uid: null, cwd: null };
  try {
    var state = storeRef.getState();
    var uid = state.sessions.activeUid;
    var session = state.sessions.sessions[uid];
    var cwd = cwdTracker[uid] || (session && session.cwd) || require('os').homedir();
    return { uid: uid, cwd: cwd };
  } catch {
    return { uid: null, cwd: require('os').homedir() };
  }
}

function getCurrentLine(term) {
  if (!term) return '';
  try {
    const buffer = term.buffer.active;
    const line = buffer.getLine(buffer.cursorY);
    if (!line) return '';
    let text = line.translateToString(true);
    const promptPatterns = [/^.*[$#%>❯→]\s*/, /^.*\)\s*/];
    for (const pattern of promptPatterns) {
      const match = text.match(pattern);
      if (match && match[0].length < text.length) {
        text = text.substring(match[0].length);
        break;
      }
    }
    return text.trim();
  } catch {
    return '';
  }
}

function getCursorPixelPosition(term) {
  if (!term || !term.element) return { x: 100, y: 100 };
  try {
    const dims = term._core._renderService.dimensions;
    const buffer = term.buffer.active;
    const rect = term.element.getBoundingClientRect();
    return {
      x: rect.left + buffer.cursorX * dims.css.cell.width,
      y: rect.top + (buffer.cursorY + 1) * dims.css.cell.height,
    };
  } catch {
    try {
      const rect = term.element.getBoundingClientRect();
      return { x: rect.left + 100, y: rect.top + 100 };
    } catch {
      return { x: 100, y: 100 };
    }
  }
}

function applyCompletion(suggestion, inputLine, uid) {
  if (!getCompletionText) return;
  const fullText = getCompletionText(suggestion, inputLine);
  if (window.rpc) {
    window.rpc.emit('data', { uid, data: '\x15' + fullText });
  }
}

function ensureOverlay() {
  if (overlayContainer && document.body.contains(overlayContainer)) return overlayContainer;
  overlayContainer = document.createElement('div');
  overlayContainer.id = 'hyper-autocomplete-root';
  overlayContainer.style.cssText = 'position:fixed;top:0;left:0;width:0;height:0;z-index:99999;pointer-events:none;';
  document.body.appendChild(overlayContainer);
  return overlayContainer;
}

function renderOverlay() {
  const container = ensureOverlay();

  if (!overlayState.visible || !overlayState.suggestions.length) {
    container.innerHTML = '';
    container.style.pointerEvents = 'none';
    container.style.width = '0';
    container.style.height = '0';
    return;
  }

  container.style.pointerEvents = 'auto';
  container.style.width = '100vw';
  container.style.height = '100vh';

  const { suggestions, selectedIndex, cursorPosition } = overlayState;
  const cx = cursorPosition ? cursorPosition.x : 100;
  const cy = cursorPosition ? cursorPosition.y : 100;
  const goUp = cy > window.innerHeight * 0.6;
  const listW = 480;
  const left = Math.min(Math.max(cx - 12, 8), window.innerWidth - listW - 16);

  const typeIcon = { folder: '\u{1F4C1}', file: '\u{1F4C4}', history: '\u{23F1}\uFE0F' };
  const typeLabel = { folder: 'Directory', file: 'File', history: 'History' };

  let html = '<div id="ac-backdrop" style="position:fixed;top:0;left:0;right:0;bottom:0;">';
  html += '<div style="position:absolute;left:' + left + 'px;';
  html += goUp ? 'bottom:' + (window.innerHeight - cy + 4) + 'px;' : 'top:' + (cy + 4) + 'px;';
  html += 'width:' + listW + 'px;background:rgba(30,30,46,0.97);border:1px solid rgba(255,255,255,0.08);border-radius:10px;overflow:hidden;box-shadow:0 8px 32px rgba(0,0,0,0.5);font-family:CartographCF-RegularItalic,JetBrainsMono NF,Fira Code,monospace;font-size:13px;backdrop-filter:blur(16px);">';
  html += '<div id="ac-list" style="max-height:280px;overflow-y:auto;padding:4px 0;">';

  suggestions.forEach(function (item, i) {
    var sel = i === selectedIndex;
    var bg = sel ? 'background:linear-gradient(90deg,rgba(160,200,255,0.18) 0%,rgba(200,180,255,0.10) 100%);' : '';
    var color = sel ? 'color:#e8eaf6;font-weight:500;' : 'color:#c0c4d6;';
    var icon = typeIcon[item.type] || '\u{1F4CB}';
    var label = typeLabel[item.type] || item.type;
    var escaped = item.text.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

    html += '<div data-idx="' + i + '" class="ac-item" style="padding:7px 14px;cursor:pointer;display:flex;align-items:center;gap:10px;' + bg + color + 'transition:background 0.1s ease;">';
    html += '<span style="width:22px;text-align:center;flex-shrink:0;font-size:14px;">' + icon + '</span>';
    html += '<span style="flex:1;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;letter-spacing:0.2px;">' + escaped + '</span>';
    html += '<span style="font-size:11px;color:#6b7089;flex-shrink:0;">' + label + '</span>';
    html += '</div>';
  });

  html += '</div></div></div>';
  container.innerHTML = html;

  var list = document.getElementById('ac-list');
  if (list && list.children[selectedIndex]) {
    list.children[selectedIndex].scrollIntoView({ block: 'nearest' });
  }

  var backdrop = document.getElementById('ac-backdrop');
  if (backdrop) {
    backdrop.addEventListener('click', function (e) {
      if (e.target === backdrop) hideOverlay();
    });
  }

  container.querySelectorAll('.ac-item').forEach(function (el) {
    el.addEventListener('click', function () {
      var idx = parseInt(el.dataset.idx, 10);
      var suggestion = overlayState.suggestions[idx];
      if (suggestion) {
        var session = getActiveSession();
        applyCompletion(suggestion, overlayState.inputLine, session.uid);
      }
      hideOverlay();
    });
  });
}

function showOverlay(suggestions, inputLine, cursorPosition) {
  overlayState = { visible: true, suggestions: suggestions, selectedIndex: 0, inputLine: inputLine, cursorPosition: cursorPosition };
  renderOverlay();
}

function hideOverlay() {
  if (!overlayState.visible) return;
  overlayState = { visible: false, suggestions: [], selectedIndex: 0, inputLine: '', cursorPosition: null };
  renderOverlay();
}

function navigateOverlay(dir) {
  if (!overlayState.visible) return;
  var len = overlayState.suggestions.length;
  if (dir === 'down') {
    overlayState.selectedIndex = (overlayState.selectedIndex + 1) % len;
  } else {
    overlayState.selectedIndex = (overlayState.selectedIndex - 1 + len) % len;
  }
  renderOverlay();
}

function selectCurrent() {
  if (!overlayState.visible || !overlayState.suggestions.length) return;
  var suggestion = overlayState.suggestions[overlayState.selectedIndex];
  if (suggestion) {
    var session = getActiveSession();
    applyCompletion(suggestion, overlayState.inputLine, session.uid);
  }
  hideOverlay();
}

function triggerAutocomplete(term) {
  if (!term || !getSuggestions) return false;

  var inputLine = getCurrentLine(term);
  if (!inputLine) return false;

  var session = getActiveSession();
  console.log('[hyper-autocomplete] uid:', session.uid, 'cwd:', session.cwd, 'cwdTracker:', JSON.stringify(cwdTracker));
  console.log('[hyper-autocomplete] inputLine:', JSON.stringify(inputLine));
  var suggestions = getSuggestions(inputLine, session.cwd);
  console.log('[hyper-autocomplete] suggestions:', suggestions.length, suggestions.map(function(s) { return s.text; }));
  if (!suggestions.length) return false;

  if (suggestions.length === 1) {
    applyCompletion(suggestions[0], inputLine, session.uid);
    return true;
  }

  showOverlay(suggestions, inputLine, getCursorPixelPosition(term));
  return true;
}

exports.decorateTerm = function (Term, ref) {
  var React = ref.React;

  return class extends React.Component {
    constructor(props, context) {
      super(props, context);
      this._onDecorated = this._onDecorated.bind(this);
    }

    _onDecorated(termComponent) {
      if (this.props.onDecorated) this.props.onDecorated(termComponent);
      if (!termComponent) return;
      var xterm = termComponent.term;
      if (!xterm) return;
      activeXterm = xterm;

      xterm.attachCustomKeyEventHandler(function (e) {
        if (e.type !== 'keydown') return true;

        if (e.key === 'Tab' && !e.ctrlKey && !e.metaKey && !e.altKey && !e.shiftKey) {
          if (overlayState.visible) {
            e.preventDefault();
            selectCurrent();
            shouldBlockTab = true;
            return false;
          }
          var handled = triggerAutocomplete(xterm);
          if (handled) {
            e.preventDefault();
            shouldBlockTab = true;
            return false;
          }
          return true;
        }

        if (!overlayState.visible) return true;

        switch (e.key) {
          case 'ArrowDown':
            e.preventDefault();
            navigateOverlay('down');
            return false;
          case 'ArrowUp':
            e.preventDefault();
            navigateOverlay('up');
            return false;
          case 'Enter':
            e.preventDefault();
            selectCurrent();
            return false;
          case 'Escape':
            e.preventDefault();
            hideOverlay();
            return false;
          default:
            hideOverlay();
            return true;
        }
      });
    }

    render() {
      return React.createElement(Term, Object.assign({}, this.props, {
        onDecorated: this._onDecorated,
      }));
    }
  };
};

exports.middleware = function (store) {
  return function (next) {
    return function (action) {
      storeRef = store;

      if (action.type === 'SESSION_USER_DATA' && shouldBlockTab) {
        var data = typeof action.data === 'string' ? action.data : '';
        if (data === '\t') {
          shouldBlockTab = false;
          return;
        }
        shouldBlockTab = false;
      }

      if (action.type === 'SESSION_SET_CWD') {
        console.log('[hyper-autocomplete] CWD changed:', action.uid, action.cwd);
        cwdTracker[action.uid] = action.cwd;
      }

      if (action.type === 'SESSION_PTY_DATA' && overlayState.visible) {
        hideOverlay();
      }

      next(action);
    };
  };
};
