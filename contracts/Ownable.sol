pragma solidity 0.4.21;

contract Ownable {
    address private owner;

    event LogOwnerChange(address _owner);

    // Modify method to only allow calls from the owner of the contract.
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function Ownable() public {
        owner = msg.sender;
    }

    /**
     * Replace the contract owner with a new owner.
     *
     * Parameters
     * ----------
     * _owner : address
     *     The address to replace the current owner with.
     */
    function replaceOwner(address _owner) external onlyOwner {
        owner = _owner;

        emit LogOwnerChange(_owner);
    }
}