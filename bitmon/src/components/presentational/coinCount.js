import React, { Component } from 'react';
import PropTypes from 'prop-types';

export const CoinCount = ({ balance, isConnected }) => {
    balance = (isConnected) ? balance : '¯\\_(ツ)_/¯'
    return (
      <div>
        <span>Your Balance: {balance}</span>
      </div>
    )
  }
  
  
  CoinCount.propTypes = {
    balance: PropTypes.string,
    isConnected: PropTypes.bool
  }