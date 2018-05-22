import React, { Component } from 'react';
import PropTypes from 'prop-types';

export default class CoreLayout extends Component {
    componentWillMount () {
      this.props.web3Connect() // initiate web3 existence check. metamask compatibility
    }
  
    render () { 
        return (this.props.isConnected ? "We are connected!" : "Not Connected") 
    }
}
  
CoreLayout.propTypes = {
    web3Connect: PropTypes.func.isRequired,
    isConnected: PropTypes.bool.isRequired
}