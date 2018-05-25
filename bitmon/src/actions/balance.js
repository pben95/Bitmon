import * as types from './types'
import bitmonContract from '../contract/BitmonContract'
import abi from '../contract/abi'
var contractAddress = '0xF93b68309245DA8Dbc21fcac0756a71b13E23B47'

export const getBalance = (account) => {
    return (dispatch, getState) => {
      return new Promise((resolve, reject) => {
        let bitmon = bitmonContract(abi, contractAddress)
        bitmon.methods.balanceOf(account).call()
          .then((value) => {
            dispatch({
              type: types.SET_BALANCE,
              payload: { account, value: value.valueOf() }
            })
            resolve()
          }).catch((error) => {
            console.log(error)
            reject()
          })
      })
    }
  }
