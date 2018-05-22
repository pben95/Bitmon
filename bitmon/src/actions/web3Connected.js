import * as types from './types'

export const web3Connected = ({ web3, isConnected }) => {
    return {
      type: types.WEB3_CONNECTED,
      payload: {
        web3,
        isConnected
      }
    }
  }