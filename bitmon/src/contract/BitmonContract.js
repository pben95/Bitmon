import Web3 from 'web3';

const BitmonContract = (ABI, account) => {
    let web3Provider = new Web3(new Web3.providers.HttpProvider('https://rinkeby.infura.io/R2rm8T1awO3hgUnGw5l2'));

    return new web3Provider.eth.Contract(ABI, account);
}

export default BitmonContract;
