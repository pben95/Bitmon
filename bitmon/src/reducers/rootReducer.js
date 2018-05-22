import web3Reducer from './web3Reducer'
import bitmonReducer from './bitmonReducer'
import {combineReducers} from 'redux';

const rootReducer = combineReducers({
    web3Wrap: web3Reducer,
    bitmonWrap: bitmonReducer
});

export default rootReducer;