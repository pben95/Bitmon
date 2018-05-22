import * as types from './types';

export const ACTION_HANDLERS = {
    [types.WEB3_CONNECTED]: (state, action) => {
      return action.payload
    },
    [types.WEB3_DISCONNECTED]: (state, action) => {
      return action.payload
    },
    [types.SET_BALANCE]: (state, action) => {
      return Object.assign({}, state, action.payload)
    }
  }
  