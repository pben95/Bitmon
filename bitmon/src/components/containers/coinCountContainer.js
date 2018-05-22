import { connect } from 'react-redux'

import { CoinCount } from '../presentational/coinCount'

const mapDispatchToProps = {
}

const mapStateToProps = (state) => ({
  isConnected: state.web3Wrap.isConnected,
  balance: state.bitmonWrap.value
})

export default connect(mapStateToProps, mapDispatchToProps)(CoinCount)