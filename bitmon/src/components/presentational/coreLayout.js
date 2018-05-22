import React, { Component } from 'react';
import PropTypes from 'prop-types';

export default class CoreLayout extends Component {
    componentWillMount () {
      this.props.web3Connect() // initiate web3 existence check. metamask compatibility
      this.props.getBalance('0xb37596eb3986da9df4a2d9062cb615f21c294522')
    }
  
    render () { 
        return (this.props.isConnected ? "We are connected!" : "Not Connected") 
    }
}
  
CoreLayout.propTypes = {
    web3Connect: PropTypes.func.isRequired,
    isConnected: PropTypes.bool.isRequired
}