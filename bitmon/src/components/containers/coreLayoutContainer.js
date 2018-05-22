import React, { Component } from 'react';
import CoreLayout from '../presentational/coreLayout';
import { connect } from 'react-redux'
import { web3Connect } from '../../actions/web3Connect';

const mapDispatchToProps = {
  web3Connect
}

const mapStateToProps = (state) => ({
  isConnected: state.web3Wrap.isConnected
})

export default connect(mapStateToProps, mapDispatchToProps)(CoreLayout)
