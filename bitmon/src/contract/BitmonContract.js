import React, { Component } from 'react';
import logo from './logo.svg';
import './App.css';

const BitmonContract = (props) => {
    return web3.eth.contract(props.ABI);
}

export default BitmonContract;
