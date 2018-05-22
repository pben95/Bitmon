import Web3 from 'web3'
import { ACTION_HANDLERS } from '../actions/actionHandlers'
import { initialState } from './initialState'

export default function Web3Reducer (state = initialState, action) {
  const handler = ACTION_HANDLERS[action.type]
  return handler ? handler(state, action) : state
}