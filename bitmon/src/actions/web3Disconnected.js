import * as types from './types'

export const web3Disconnected = () => {
    return {
      type: types.WEB3_DISCONNECTED,
      payload: {
        web3: null,
        isConnected: false
      }
    }
  }
  