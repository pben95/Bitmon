import CoreLayout from '../presentational/coreLayout';
import { connect } from 'react-redux'
import { web3Connect } from '../../actions/web3Connect';
import { getBalance } from '../../actions/balance';

const mapDispatchToProps = {
  web3Connect,
  getBalance
}

const mapStateToProps = (state) => ({
  isConnected: state.web3Wrap.isConnected
})

export default connect(mapStateToProps, mapDispatchToProps)(CoreLayout)
