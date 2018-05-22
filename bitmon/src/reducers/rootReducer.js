import web3Reducer from './web3Reducer'
import {combineReducers} from 'redux';

const rootReducer = combineReducers({
    web3Wrap: web3Reducer
});

export default rootReducer;