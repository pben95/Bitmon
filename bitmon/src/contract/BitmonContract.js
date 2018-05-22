import Web3 from 'web3';

const BitmonContract = (ABI, account) => {
    let web3Provider = new Web3(new Web3.providers.HttpProvider('https://rinkeby.etherscan.io/address/0xf93b68309245da8dbc21fcac0756a71b13e23b47'));

    return new web3Provider.eth.Contract(ABI, account);
}

export default BitmonContract;
