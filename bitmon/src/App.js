import React, { Component } from 'react';
import logo from './logo.svg';
import CoreLayoutContainer from './components/containers/coreLayoutContainer';
import CoinCountContainer from './components/containers/coinCountContainer';
import './App.css';

class App extends Component {
  render() {
    return (
      <div className="App">
        <CoreLayoutContainer />
        <CoinCountContainer />
      </div>
    );
  }
}

export default App;
