import * as types from './types'
import bitmonContract from '../contract/BitmonContract'
import abi from '../contract/abi'

export const getBalance = (account) => {
    return (dispatch, getState) => {
      return new Promise((resolve, reject) => {
        let bitmon = bitmonContract(abi, account)
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