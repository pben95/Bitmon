import React, { Component } from 'react';
import logo from './logo.svg';
import CoreLayoutContainer from './components/containers/coreLayoutContainer';
import './App.css';

class App extends Component {
  render() {
    return (
      <div className="App">
        <CoreLayoutContainer />
      </div>
    );
  }
}

export default App;
