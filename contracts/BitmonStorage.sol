pragma solidity 0.4.21;

///////////////////////////////////////////////////
//-----------------------------------------------//
//------------Bitmon: ERC721 RPG DApp------------//
//-Rinkeby Testnet Alpha ERC721 Storage Contract-//
// Written by pben95: https://github.com/pben95/ //
//-----------------------------------------------//
///////////////////////////////////////////////////
//-----------------------------------------------//
//Credit to OpenZeppelin for the ERC721 contracts//
//Thanks to the multitude of great ERC721 DApps  //
//for inspiration: CryptoFighters, Etheremon,    //
//Angel Battles, Axie Infinity, Dragonereum, etc //
//Also, mobile gachapon collectible RPGs like    //
//Monster Super League and Digimon Links. Thanks!//
//-----------------------------------------------//
///////////////////////////////////////////////////

import "./ERC721.sol";
import "./ERC721Enumerable.sol";
import "./ERC721Metadata.sol";
import "./ERC721TokenReceiver.sol";
import "./IBitmonStats.sol";
import "./Ownable.sol";  //OpenZeppelin

contract BitmonStorage is ERC721, ERC721Enumerable, ERC721Metadata, IBitmonStats, Ownable {
    
    //////////////////
    //Bitmon Storage//
    //////////////////
    
    mapping(uint256 => Bitmon) public monList;
    mapping(uint16 => Species) public speciesList;
    mapping(address => bool) public gameContracts;
    mapping(address => uint256) internal nonces;
    uint16 totalSpecies;
    
    struct Bitmon {  //Bitmon struct, defines stats for individual mons.
        bool variant;  //If special or not (shiny/special colors)
        uint8 evos;  //Number of times evolved, can't be higher than species evos
        uint8 luck;  //Luck, set on birth, determines something 
        uint8 level;  //Total level, increase at certain number of EXP
        uint16 species;  //Which species the mon is
        uint16 hp;  //Current max hp, increases with level. 20x higher than other stats
        uint16 att;  //Current attack, increases with level
        uint16 spd;  //Current speed, increases with level
        uint32 exp;  //Total EXP, level increases at certain thresholds
        bytes16 name;  //Mon's name
        uint256 monId;  //ERC721 identifier
    }
    
    struct Species {  //Bitmon species struct, defines number of evolutions, type, skills, and stat growth
        uint8 evos;  //Number of evolutions it can undergo.
        uint8 monType;  //Types: Null, Data, Vaccine, Virus
        uint8 skill1;  //First skill, changes base damage  and scalings
        uint8 skill2;  //Second skill, changes base damage and scalings
        uint8 hpStep;  //hp increase per level, at least 3, no more than 9
        uint8 attStep;  //Attack increase per level, at least 3, no more than 9
        uint8 spdStep;  //Speed increase per level, at least 3, no more than 9
    }
    
    function BitmonStorage() public {  //Constructor
        _addInitialSpecies;
    }
    
    function _addInitialSpecies() internal {
        _addSpecies(0, 1, 1, 2, 4, 4, 4);  //Null type, balanced, 1 evos
        _addSpecies(0, 2, 1, 2, 4, 4, 4);  //Data type, balanced, 1 evos
        _addSpecies(0, 3, 1, 2, 4, 4, 4);  //Vaccine type, balanced, 1 evos
        _addSpecies(0, 4, 1, 2, 4, 4, 4);  //Virus type, balanced, 1 evos
        _addSpecies(1, 1, 3, 4, 3, 5, 3);  //Null type, sweeper, 2 evos
        _addSpecies(1, 2, 3, 4, 3, 5, 3);  //Data type, sweeper, 2 evos
        _addSpecies(1, 3, 3, 4, 5, 3, 3);  //Vaccine type, tank, 2 evos
        _addSpecies(1, 4, 3, 4, 5, 3, 3);  //Virus type, tank, 2 evos
        _addSpecies(2, 1, 5, 6, 4, 3, 3);  //Null type, tank, 3 evos
        _addSpecies(2, 2, 5, 6, 4, 3, 3);  //Data type, tank, 3 evos
        _addSpecies(2, 3, 5, 6, 3, 4, 3);  //Vaccine type, sweeper, 3 evos
        _addSpecies(2, 4, 5, 6, 3, 4, 3);  //Virus type, sweeper, 3 evos
    }
    
    function addGameContract(address _contract) external onlyOwner {  //Adds game contract that can use gamecontract only functions
        require(_isContract(_contract));
        gameContracts[_contract] = true;
        emit GameContractAdded(_contract);
    }
    
    function removeGameContract(address _contract) external onlyOwner {  //Removes old/deprecated/accidental game contracts.
        require(_isContract(_contract));
        gameContracts[_contract] = false;
        emit GameContractRemoved(_contract);
    }
    
    //////////
    //Events//
    //////////
    
    event NewBitmon(address indexed _owner, uint256 indexed _monId);

    event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);

    event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);

    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
    
    event GameContractAdded(address indexed _contract);
    
    event GameContractRemoved(address indexed _contract);
    
    /////////////
    //Modifiers//
    /////////////

    modifier onlyValidToken(uint256 _tokenId) {
        require(ownerByTokenId[_tokenId] != address(0));
        _;
    }
    
    modifier onlyGameContracts() {
        require(gameContracts[msg.sender] == true);
        _;
    }

    modifier onlyValidTransfers(address _from, address _to, uint256 _tokenId) {
        address tokenOwner = ownerByTokenId[_tokenId];

        require(
            msg.sender == tokenOwner ||
            msg.sender == approvedTransfers[_tokenId] ||
            operators[tokenOwner][msg.sender]
        );

        require(
            _to != address(0) &&
            _to != address(this) &&
            _to != _from
        );

        _;
    }
    
    //////////////////
    //Game Functions//
    //////////////////
    
    function addMonToPlayer(address _to, uint16 _species) external onlyGameContracts {  //Allows game contracts to give mons (sale contract, winning in battle, etc)
        _addMonToPlayer(_to, _species); 
    }
    
    function newSpecies(uint8 _evos, uint8 _monType, uint8 _skill1, uint8 _skill2, uint8 _hpStep, uint8 _attStep, uint8 _spdStep) external onlyOwner {  //Allows me to add more species
        _addSpecies(_evos, _monType, _skill1, _skill2, _hpStep, _attStep, _spdStep);
    }
    
    function changeSpeciesSkills(uint16 _species, uint8 _skill1, uint8 _skill2) external onlyOwner {  //Alows me to change species skills
        require(_species >= 1 && _species <= totalSpecies);
        require(_skill1 > 0 && _skill2 > 0);
        Species storage s = speciesList[_species];
        s.skill1 = _skill1;
        s.skill2 = _skill2;
    }
    
    function changeMonExp(uint256 _monId, uint32 _amount) external onlyValidToken(_monId) onlyGameContracts {  //Allows game contracts to award a mon EXP and checks if it levels up
        Bitmon storage mon = monList[_monId];
        mon.exp += _amount;
        if (mon.exp >= 100 * (mon.level**2)/2 && mon.level < 250) {  //Max level is 250
            mon.level++;
            Species memory s = speciesList[mon.species];
            if (mon.hp < 65000) {  //Maximum hp a mon can have (20 * maximum stat value of 3250)
                mon.hp += 20 * uint16(_random(s.hpStep - 2, s.hpStep + 1) + mon.evos);
            }
            if (mon.att < 3250) {  //Maximum att a mon can have (maximum stat value of 3250)
                mon.att += uint16(_random(s.attStep - 2, s.attStep + 1) + mon.evos);
            }
            if (mon.spd < 3250) {  //Maximum spd a mon can have (maximum stat value of 3250)
                mon.spd = uint16(_random(s.spdStep - 2, s.spdStep + 1) + mon.evos);
            }
        }
    }

    function _addMonToPlayer(address _to, uint16 _species) internal {  //Internal function for adding mons, calls _add and generates the mons stats
        require(_species >= 1 && _species <= totalSpecies);
        uint256 newIndex = totalTokens + 1;
        _add(newIndex, _to);
        Bitmon storage mon = monList[newIndex];
        Species memory s = speciesList[_species];
        mon.species = _species;
        mon.level = 1;
        mon.hp = 20 * uint16(_random(s.hpStep - 2, s.hpStep + 1));
        mon.att = uint16(_random(s.attStep - 2, s.attStep + 1));
        mon.spd = uint16(_random(s.spdStep - 2, s.spdStep + 1));
        mon.luck = uint8(_random(1,5));
        mon.monId = newIndex;
        if (_random(1,99) == 50) {
            mon.variant = true;
        }
        emit NewBitmon(_to, newIndex);
    }
    
    function _addSpecies(uint8 _evos, uint8 _monType, uint8 _skill1, uint8 _skill2, uint8 _hpStep, uint8 _attStep, uint8 _spdStep) internal {  //Internal function for adding species
        require(_hpStep >= 3 && _attStep >= 3 && _spdStep >= 3);
        require(_hpStep <= 9 && _attStep <= 9 && _spdStep <= 9);
        require(_monType >= 1 && _monType <= 4);
        require(_skill1 > 0 && _skill2 > 0);
        totalSpecies++;
        Species storage s = speciesList[totalSpecies];
        s.evos = _evos;
        s.monType = _monType;
        s.skill1 = _skill1;
        s.skill2 = _skill2;
        s.hpStep = _hpStep;
        s.attStep = _attStep;
        s.spdStep = _spdStep;
    }
    
    function _random(uint _min, uint _max) internal returns (uint) {  //Internal function for RNG. Probably not secure but please don't cheat
        nonces[tx.origin]++;
        uint randomHash = uint(keccak256(block.blockhash(block.number-1)))+uint(keccak256(nonces[tx.origin]));
        uint value = (randomHash % _max)+1;
        if (value < _min) {
            return _min;
        } else {
            return value;
        }
    }
    
    ////////////////////
    //Player Functions//
    ////////////////////
    
    function nameMon(uint256 _monId, bytes16 _name) external onlyValidToken(_monId) {  //Lets player name their mon
        require(msg.sender == ownerByTokenId[_monId]);
        Bitmon storage mon = monList[_monId];
        mon.name = _name;
    }
    
    function evolveMon(uint256 _monId) external onlyValidToken(_monId)  {  //Lets player evolve their mon, every 50 levels can evolve.
        require(msg.sender == ownerByTokenId[_monId]);
        Bitmon storage mon = monList[_monId];
        Species memory s = speciesList[mon.species];
        require(mon.evos < s.evos);
        require(mon.level >= (mon.evos + 1)*50);
        mon.evos++;
    }
    
    ////////////////////
    //ERC721 Functions//
    ////////////////////
    
    mapping(uint256 => address) private ownerByTokenId;
    mapping(address => uint256[]) private tokenIdsByOwner;
    mapping(uint256 => uint256) private ownerTokenIndexByTokenId;
    mapping(uint256 => address) private approvedTransfers;
    mapping(address => mapping(address => bool)) private operators;
    uint256 private totalTokens;
    
    function name() external pure returns (string) {
        return "Bitmon";
    }

    function symbol() external pure returns (string) {
        return "BITMON";
    }

    function balanceOf(address _owner) external view returns (uint256) {
        require(_owner != address(0));

        return tokenIdsByOwner[_owner].length;
    }

    function ownerOf(uint256 _tokenId) external view returns (address) {
        // Store the owner in a temporary variable to avoid having to do the
        // lookup twice.
        address _owner = ownerByTokenId[_tokenId];

        require(_owner != address(0));

        return _owner;
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) external onlyValidToken(_tokenId) {
        _safeTransferFrom(_from, _to, _tokenId, data);
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external onlyValidToken(_tokenId) {
        _safeTransferFrom(_from, _to, _tokenId, "");
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external onlyValidToken(_tokenId) onlyValidTransfers(_from, _to, _tokenId) {
        _transfer(_to, _tokenId);
    }

    function approve(address _approved, uint256 _tokenId) external {
        address _owner = ownerByTokenId[_tokenId];

        require(msg.sender == _owner || operators[_owner][msg.sender]);

        // Set address as approved for transfer. It can be the case that the
        // address was already set (e.g. this method was called twice in a row)
        // in which case this does not change anything.
        approvedTransfers[_tokenId] = _approved;

        emit Approval(msg.sender, _approved, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved) external {
        operators[msg.sender][_operator] = _approved;

        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function getApproved(uint256 _tokenId) external view onlyValidToken(_tokenId) returns (address) {
        return approvedTransfers[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {
        return operators[_owner][_operator];
    }

    function totalSupply() external view returns (uint256) {
        return totalTokens;
    }

    function tokenByIndex(uint256 _index) external view returns (uint256) {
        require(_index < totalTokens);

        return _index;
    }

    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256) {
        require(_index < tokenIdsByOwner[_owner].length);
        return tokenIdsByOwner[_owner][_index];
    }

    function _isContract(address _address) internal view returns (bool) {
        uint size;

        assembly {
            size := extcodesize(_address)
        }

        return size > 0;
    }

    function _safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) internal onlyValidTransfers(_from, _to, _tokenId) {
        // Call the method that performs the actual transfer. All common cases
        // of "wrong" transfers have already been checked at this point. The
        // internal transfer method does no checking.
        _transfer(_to, _tokenId);

        // Check whether the receiving party is a contract, and if so, call
        // the `onERC721Received` method as defined in the ERC-721 standard.
        if (_isContract(_to)) {

            // Assume the receiving party has implemented ERC721TokenReceiver,
            // as otherwise the "unsafe" `transferFrom` method should have been
            // called instead.
            ERC721TokenReceiver _receiver = ERC721TokenReceiver(_to);

            // The response returned by `onERC721Received` of the receiving
            // contract"s `on *must* be equal to the magic number defined by
            // the ERC-165 signature of `ERC721TokenReceiver`. If this is not
            // the case, the transaction will be reverted.
            require(
                _receiver.onERC721Received(
                    address(this),
                    _tokenId,
                    data
                ) == INTERFACE_SIGNATURE_ERC721_TOKEN_RECEIVER
            );
        }
    }

    function _transfer(address _to, uint256 _tokenId) internal {
        // Get current owner of the token. It is technically possible that the
        // owner is the same address as the address to which the token is to be
        // sent to. In this case the token will be moved to the end of the list
        // of tokens owned by this address.
        address _from = ownerByTokenId[_tokenId];

        // There are two possible scenarios for transfers when it comes to the
        // removal of the token from the side that currently owns the token:
        //  1: the owner has two or more tokens; or
        //  2: the owner has one token.
        if (tokenIdsByOwner[_from].length > 1) {

            // Get the index of the token that has to be removed from the list
            // of tokens owned by the current owner.
            uint256 tokenIndexToDelete = ownerTokenIndexByTokenId[_tokenId];

            // To keep the list of tokens without gaps, and thus reducing the
            // gas cost associated with interacting with the list, the last
            // token in the owner"s list of tokens is moved to fill the gap
            // created by removing the token.
            uint256 tokenIndexToMove = tokenIdsByOwner[_from].length - 1;

            // Overwrite the token that is to be removed with the token that
            // was at the end of the list. It is possible that both are one and
            // the same, in which case nothing happens.
            tokenIdsByOwner[_from][tokenIndexToDelete] =
                tokenIdsByOwner[_from][tokenIndexToMove];
        }

        // Remove the last item in the list of tokens owned by the current
        // owner. This item has either already been copied to the location of
        // the token that is to be transferred, or is the only token of this
        // owner in which case the list of tokens owned by this owner is now
        // empty.
        tokenIdsByOwner[_from].length--;

        // Add the token to the list of tokens owned by `_to`. Items are always
        // added to the very end of the list. This makes the token index of the
        // new token within the owner"s list of tokens equal to the length of
        // the list minus one as Solidity is a zero-based language. This token
        // index is then set for this token identifier.
        tokenIdsByOwner[_to].push(_tokenId);
        ownerTokenIndexByTokenId[_tokenId] = tokenIdsByOwner[_to].length - 1;

        // Set the direct ownership information of the token to the new owner
        // after all other ownership-related mappings have been updated to make
        // sure the "side" data is correct.
        ownerByTokenId[_tokenId] = _to;

        // Remove the approved address of this token. It may be the case there
        // was no approved address, in which case nothing changes.
        approvedTransfers[_tokenId] = address(0);

        // Log the transfer event onto the blockchain to leave behind an audit
        // trail of all transfers that have taken place.
        emit Transfer(_from, _to, _tokenId);
    }

    function _add(uint256 _tokenId, address _owner) internal {
        // Ensure the token does not already exist, and prevent duplicate calls
        // using the same identifier.
        require(ownerByTokenId[_tokenId] == address(0));

        // Update the direct ownership mapping, by setting the owner of the
        // token identifier to `_owner`, and adding the token to the list of
        // tokens owned by `_owner`. Arrays are always initialized to empty
        // versions of of their specific type, thus ensuring that the `push`
        // method will not fail.
        ownerByTokenId[_tokenId] = _owner;
        tokenIdsByOwner[_owner].push(_tokenId);

        // Update the mapping that keeps track of a token"s index within the
        // list of tokens owned by each owner. At the time of addition a token
        // is always added to the end of the list, and will thus always equal
        // the number of tokens already in the list, minus one, because the
        // arrays within Solidity are zero-based.
        ownerTokenIndexByTokenId[_tokenId] = tokenIdsByOwner[_owner].length - 1;

        totalTokens += 1;
    }
    
    bytes4 private constant INTERFACE_SIGNATURE_ERC165 = bytes4(
        keccak256("supportsInterface(bytes4)")
    );

    bytes4 private constant INTERFACE_SIGNATURE_ERC721 = bytes4(
        keccak256("balanceOf(address)") ^
        keccak256("ownerOf(uint256)") ^
        keccak256("safeTransferFrom(address,address,uint256,bytes)") ^
        keccak256("safeTransferFrom(address,address,uint256)") ^
        keccak256("transferFrom(address,address,uint256)") ^
        keccak256("approve(address,uint256)") ^
        keccak256("setApprovalForAll(address,bool)") ^
        keccak256("getApproved(uint256)") ^
        keccak256("isApprovedForAll(address,address)")
    );

    bytes4 private constant INTERFACE_SIGNATURE_ERC721_ENUMERABLE = bytes4(
        keccak256("totalSupply()") ^
        keccak256("tokenByIndex(uint256)") ^
        keccak256("tokenOfOwnerByIndex(address,uint256)")
    );

    bytes4 private constant INTERFACE_SIGNATURE_ERC721_METADATA = bytes4(
        keccak256("name()") ^
        keccak256("symbol()") ^
        keccak256("tokenURI(uint256)")
    );

    bytes4 private constant INTERFACE_SIGNATURE_ERC721_TOKEN_RECEIVER = bytes4(
        keccak256("onERC721Received(address,uint256,bytes)")
    );
    
    function supportsInterface(bytes4 interfaceID) external pure returns (bool) {
        return (
            interfaceID == INTERFACE_SIGNATURE_ERC165 ||
            interfaceID == INTERFACE_SIGNATURE_ERC721 ||
            interfaceID == INTERFACE_SIGNATURE_ERC721_METADATA ||
            interfaceID == INTERFACE_SIGNATURE_ERC721_ENUMERABLE
        );
    }
    
    ////////////////////
    //Mon Getters//
    ////////////////////
    
    function getMonId(uint256 _monId) external view returns (uint256) {  //Returns mon ID, checks if token created
        return(monList[_monId].monId);
    }
    
    function getMonHp(uint256 _monId) external view returns (uint16) {  //Returns mons hp
        return(monList[_monId].hp);
    }
    
    function getMonAtt(uint256 _monId) external view returns (uint16) {  //Returns mons att
        return(monList[_monId].att);
    }
    
    function getMonSpd(uint256 _monId) external view returns (uint16) {  //Returns mons spd
        return(monList[_monId].spd);
    }
    
    function getMonLuck(uint256 _monId) external view returns (uint8) {  //Returns mons luck
        return(monList[_monId].luck);
    }
    
    function getMonLevel(uint256 _monId) external view returns (uint8) {  //Returns mons level
        return(monList[_monId].level);
    }
    
    function getMonExp(uint256 _monId) external view returns (uint32) {  //Returns mons exp
        return(monList[_monId].exp);
    }
    
    function getMonSpecies(uint256 _monId) external view returns (uint16) {  //Returns mons species
        return(monList[_monId].species);
    }
    
    function getMonVariant(uint256 _monId) external view returns (bool) {  //Returns if mon is variant
        return(monList[_monId].variant);
    }
    
    function getMonName(uint256 _monId) external view returns (bytes16) {  //Returns mons name
        return(monList[_monId].name);
    }
    
    function getMonType(uint256 _monId) external view returns (uint8) {
        return(speciesList[monList[_monId].species].monType);
    }
    
    function getMonSkill1(uint256 _monId) external view returns (uint8) {
        return(speciesList[monList[_monId].species].skill1);
    }
    
    function getMonSkill2(uint256 _monId) external view returns (uint8) {
        return(speciesList[monList[_monId].species].skill2);
    }
    
    ///////////////////
    //Species Getters//
    ///////////////////
    
    function getSpeciesMonType(uint16 _species) external view returns (uint8) {  //Returns species mon type
        return(speciesList[_species].monType);
    }
    
    function getSpeciesHpStep(uint16 _species) external view returns (uint8) {  //Returns species hpStep
        return(speciesList[_species].hpStep);
    }
    
    function getSpeciesAttStep(uint16 _species) external view returns (uint8) {  //Returns species attStep
        return(speciesList[_species].attStep);
    }
    
    function getSpeciesSpdStep(uint16 _species) external view returns (uint8) {  //Returns species spdStep
        return(speciesList[_species].spdStep);
    }
    
    function getSpeciesSkill1(uint16 _species) external view returns (uint8) {  //Returns species skill1
        return(speciesList[_species].skill1);
    }
    
    function getSpeciesSkill2(uint16 _species) external view returns (uint8) {  //Returns species skill2
        return(speciesList[_species].skill2);
    }
    
    function getSpeciesEvos(uint16 _species) external view returns (uint8) {  //Returns species number of evolutions
        return(speciesList[_species].evos);
    }
    
    ///////////////////////
    //Thanks for reading!//
    //------pben95-------//
    ///////////////////////
    
}