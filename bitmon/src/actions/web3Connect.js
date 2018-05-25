import truffleConfig from '../truffle'
import * as types from './types'

export const web3Connect = () => {
    return (dispatch, getState) => {
      /*eslint-disable */
      let web3Location = `https://rinkeby.infura.io/R2rm8T1awO3hgUnGw5l2`
  
      let output = (typeof web3 !== 'undefined') // web3 given by metamask
                    ? { type: types.WEB3_CONNECTED, payload: { web3: new Web3(new Web3.providers.HttpProvider(web3Location)), isConnected: true } }  // comment in for optional section
                     : { type: types.WEB3_DISCONNECTED, payload: { web3: null, isConnected: false } }  // comment out for optional section
      /*eslint-enable */
      dispatch(output)
    }
  }

  
