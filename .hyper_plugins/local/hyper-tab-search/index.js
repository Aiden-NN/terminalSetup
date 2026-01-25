const fuzzysort = require('fuzzysort');

let TabSearchOverlay;

exports.mapTermsState = (state, map) => {
  return Object.assign(map, {
    sessions: state.sessions.sessions,
    activeUid: state.sessions.activeUid,
  });
};

function createTabSearchOverlay(React) {
  return class TabSearchOverlay extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      searchQuery: '',
      selectedIndex: 0,
    };
    this.inputRef = React.createRef();
  }

  componentDidMount() {
    if (this.inputRef.current) {
      this.inputRef.current.focus();
    }
  }

  handleKeyDown = (e) => {
    const results = this.getFilteredResults();
    
    if (e.key === 'Escape') {
      this.props.onClose();
    } else if (e.key === 'ArrowDown') {
      e.preventDefault();
      this.setState((prev) => ({
        selectedIndex: Math.min(prev.selectedIndex + 1, results.length - 1),
      }));
    } else if (e.key === 'ArrowUp') {
      e.preventDefault();
      this.setState((prev) => ({
        selectedIndex: Math.max(prev.selectedIndex - 1, 0),
      }));
    } else if (e.key === 'Enter' && results.length > 0) {
      e.preventDefault();
      const selected = results[this.state.selectedIndex];
      this.props.onSelectSession(selected.uid);
      this.props.onClose();
    }
  };

  getFilteredResults = () => {
    const { sessions } = this.props;
    const { searchQuery } = this.state;
    
    if (!sessions) return [];
    
    const sessionList = Object.keys(sessions).map((uid) => ({
      uid,
      title: sessions[uid].title || 'Terminal',
    }));

    if (!searchQuery) {
      return sessionList;
    }

    const results = fuzzysort.go(searchQuery, sessionList, {
      key: 'title',
      limit: 10,
    });

    return results.map((result) => result.obj);
  };

  render() {
    const results = this.getFilteredResults();
    const { selectedIndex } = this.state;

    return React.createElement(
      'div',
      {
        style: {
          position: 'fixed',
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          backgroundColor: 'rgba(0, 0, 0, 0.8)',
          display: 'flex',
          alignItems: 'flex-start',
          justifyContent: 'center',
          paddingTop: '20vh',
          zIndex: 9999,
        },
        onClick: this.props.onClose,
      },
      React.createElement(
        'div',
        {
          style: {
            backgroundColor: '#1e1e1e',
            border: '1px solid #444',
            borderRadius: '8px',
            width: '600px',
            maxHeight: '400px',
            overflow: 'hidden',
            boxShadow: '0 4px 20px rgba(0, 0, 0, 0.5)',
          },
          onClick: (e) => e.stopPropagation(),
        },
        React.createElement('input', {
          ref: this.inputRef,
          type: 'text',
          placeholder: 'Search tabs...',
          value: this.state.searchQuery,
          onChange: (e) => this.setState({ searchQuery: e.target.value, selectedIndex: 0 }),
          onKeyDown: this.handleKeyDown,
          style: {
            width: '100%',
            padding: '16px',
            fontSize: '16px',
            backgroundColor: '#2d2d2d',
            color: '#fff',
            border: 'none',
            outline: 'none',
            borderBottom: '1px solid #444',
            boxSizing: 'border-box',
          },
        }),
        React.createElement(
          'div',
          {
            style: {
              maxHeight: '300px',
              overflowY: 'auto',
            },
          },
          results.length === 0
            ? React.createElement(
                'div',
                {
                  style: {
                    padding: '20px',
                    textAlign: 'center',
                    color: '#888',
                  },
                },
                'No tabs found'
              )
            : results.map((session, index) =>
                React.createElement(
                  'div',
                  {
                    key: session.uid,
                    onClick: () => {
                      this.props.onSelectSession(session.uid);
                      this.props.onClose();
                    },
                    style: {
                      padding: '12px 16px',
                      cursor: 'pointer',
                      backgroundColor: index === selectedIndex ? '#0a84ff' : 'transparent',
                      color: '#fff',
                      borderBottom: '1px solid #333',
                    },
                  },
                  session.title
                )
              )
        )
      )
    );
  }
  };
}

exports.decorateTerms = (Terms, { React }) => {
  if (!TabSearchOverlay) {
    TabSearchOverlay = createTabSearchOverlay(React);
  }
  
  return class extends React.Component {
    constructor(props) {
      super(props);
      this.state = {
        searchVisible: false,
      };
      this.handleKeyDown = this.handleKeyDown.bind(this);
    }

    componentDidMount() {
      window.addEventListener('keydown', this.handleKeyDown);
    }

    componentWillUnmount() {
      window.removeEventListener('keydown', this.handleKeyDown);
    }

    handleKeyDown(e) {
      if ((e.metaKey || e.ctrlKey) && e.shiftKey && e.key.toLowerCase() === 'o') {
        console.log('Tab search triggered!');
        e.preventDefault();
        e.stopPropagation();
        this.setState((prev) => ({ searchVisible: !prev.searchVisible }));
      }
    }

    handleSelectSession = (uid) => {
      console.log('Selecting session:', uid);
      console.log('Available props:', Object.keys(this.props));
      
      if (window.rpc) {
        window.rpc.emit('termgroup:change-active', uid);
      }
      
      if (this.props.onActive) {
        this.props.onActive(uid);
      }
    };

    handleClose = () => {
      this.setState({ searchVisible: false });
    };

    render() {
      return React.createElement(
        'div',
        { style: { position: 'relative', height: '100%' } },
        React.createElement(Terms, this.props),
        this.state.searchVisible &&
          React.createElement(TabSearchOverlay, {
            sessions: this.props.sessions,
            onSelectSession: this.handleSelectSession,
            onClose: this.handleClose,
          })
      );
    }
  };
};
