export const getBalance = ({ account }) => {
    return (dispatch, getState) => {
      return new Promise((resolve, reject) => {
        let meta = getMetCoin({ getState })
        meta.balanceOf.call(account, { from: account })
          .then(function (value) {
            dispatch({
              type: SET_BALANCE,
              payload: { account, value: value.valueOf() }
            })
            resolve()
          }).catch(function (e) {
            console.log(e)
            reject()
          })
      })
    }
  }