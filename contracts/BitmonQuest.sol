pragma solidity 0.4.21;
import './IBitmonStats.sol';
import './Ownable.sol';  //OpenZeppelin 

///////////////////////////////////////////////////
//-----------------------------------------------//
//--Rinkeby Alpha BitmonQuest PvE Game Contract--//
// Written by pben95: https://github.com/pben95/ //
//-----------------------------------------------//
///////////////////////////////////////////////////
//-----------------------------------------------//
//Player v NPC enemy for gaining EXP and new mons//
//-----------------------------------------------//
///////////////////////////////////////////////////

contract BitmonQuest is Ownable {
    address public BitmonStorage = 0xF65d8E43C68D6Dbe9184a87A840C2B46809C86bC;
    IBitmonStats public dataC = IBitmonStats(BitmonStorage);
    mapping(uint8 => mapping(uint8 => uint16)) public typeChart;  //divide 1000
    mapping(uint256 => Battle) public battles;
    uint16[] base = [500, 500, 500, 1000, 1000, 1000, 1500, 1500, 1500];  //divide 10000
    uint16[] scale = [2, 3, 4, 2, 3, 4, 2, 3, 4];
    mapping(address => uint256) internal nonces;
    
    struct Battle {
        uint8 level;
        uint8 monType;
        uint8 skill;
        uint16 monHp;
        uint16 hp;
        uint16 att;
        uint16 spd;
        uint16 turn;
    }
    
    modifier onlyTrainer(uint256 _monId) {
        require(msg.sender == _getMonOwner(_monId));
        _;
    }
    
    event DataContractChanged(address indexed _old, address indexed _new);
    
    function BitmonQuest() public {
        typeChart[2][3] = 1501;
        typeChart[2][4] = 751;
        typeChart[3][2] = 751;
        typeChart[3][4] = 1501;
        typeChart[4][2] = 1501;
        typeChart[4][3] = 751;
    }
    
    function changeDataContract(address _contract) external onlyOwner {
        address old = BitmonStorage;
        BitmonStorage = _contract;
        dataC = IBitmonStats(BitmonStorage);
        emit DataContractChanged(old, _contract);
    }
    
    function getMon(uint16 _species) external {
        require(_species > 0 && _species <= 12);
        _addMonToPlayer(msg.sender, _species);
    }
    
    function newBattle(uint256 _monId) onlyTrainer(_monId) external {
        Battle storage b = battles[_monId];
        require(b.turn == 0);
        b.turn = 1;
        b.level = _getMonLevel(_monId);
        b.monType = 3;
        b.skill = uint8(_random(1,6));
        b.monHp = _getMonHp(_monId);
        b.hp = uint16(b.level * 20 * _random(2,4));
        b.att = uint16(b.level * _random(2,4));
        b.spd = uint16(b.level * _random(2,4));
    }
    
    function moveBattle(uint256 _monId, uint8 _move) onlyTrainer(_monId) external {
        require(_move >= 1 && _move <= 4);
        Battle storage b = battles[_monId];
        require(b.turn > 0);
        b.turn++;
        _playerMove(_monId, _move);
        _enemyMove(_monId);
        if (b.monHp == 0) {
            b.turn = 0;
        } else if (b.hp == 0) {
            b.turn = 0;
            _changeMonExp(_monId, b.level * 10);
        }
    }
    
    function _playerMove(uint256 _monId, uint8 _move) internal {
        Battle storage b = battles[_monId];
        uint16 dodge;
        uint16 att = _getMonAtt(_monId);
        uint16 spd = _getMonSpd(_monId);
        uint16 multi = typeChart[_getMonType(_monId)][b.monType];
        if (spd > b.spd) {
            dodge = spd - b.spd;
            if (dodge > 10) {
                dodge = 10;
            }
        }
        if (_random(1,99) < dodge) {
            return;
        } else {
            if (_move == 1) {
                b.hp = _calculateDamage(b.hp, att, 0, multi);
            } else if (_move == 2) {
                b.hp = _calculateDamage(b.hp, att, _getMonSkill1(_monId), multi);
            } else if (_move == 3) {
                b.hp = _calculateDamage(b.hp, att, _getMonSkill2(_monId), multi);
            } else if (_move == 4) {
                b.turn = 0;
            } else { revert(); }
        }
    }
    
    function _enemyMove(uint256 _monId) internal {
        Battle storage b = battles[_monId];
        uint16 dodge;
        uint16 spd = _getMonSpd(_monId);
        uint16 multi = typeChart[b.monType][_getMonType(_monId)];
        if (b.spd > spd) {
            dodge = b.spd - spd;
            if (dodge > 10) {
                dodge = 10;
            }
        }
        if (_random(1,99) < dodge) {
            return;
        } else {
            if (_random(1,5) == 3) {
                b.monHp = _calculateDamage(b.monHp, b.att, b.skill, multi);
            } else {
                b.monHp = _calculateDamage(b.monHp, b.att, 0, multi);
            }
        }
    }
    
    function _calculateDamage(uint16 _hp, uint16 _att, uint8 _skill, uint16 _multi) internal view returns (uint16) {
        uint16 damage;
        uint16 multi;
        if (_multi == 0) {
            multi = 1000;
        } else {
            multi = _multi;
        }
        if (_skill == 0) {
            damage = (2 * _att * multi)/1000; 
        } else {
            damage = ((((base[_skill] * _hp)/10000) + (scale[_skill] * _att))*multi)/1000;
        }
        if (damage >= _hp) {
            return 0;
        } else {
            return (_hp - damage);
        }
        
    }
    
    function _random(uint _min, uint _max) internal returns (uint) {  //Internal function for RNG. Probably not secure but there's no money on the line so please don't cheat
        nonces[tx.origin]++;
        uint randomHash = uint(keccak256(block.blockhash(block.number-1)))+uint(keccak256(nonces[tx.origin]));
        uint value = (randomHash % _max)+1;
        if (value < _min) {
            return _min;
        } else {
            return value;
        }
    }
    
    ////////////////////////////
    //Storage Contract Getters//
    ////////////////////////////
    
    function _getMonHp(uint256 _monId) internal view returns (uint16) {
        return (dataC.getMonHp(_monId));
    }
    
    function _getMonAtt(uint256 _monId) internal view returns (uint16) {
        return (dataC.getMonAtt(_monId));
    }
    
    function _getMonSpd(uint256 _monId) internal view returns (uint16) {
        return (dataC.getMonSpd(_monId));
    }
    
    function _getMonLevel(uint256 _monId) internal view returns (uint8) {
        return (dataC.getMonLevel(_monId));
    }
    
    function _getMonSpecies(uint256 _monId) internal view returns (uint16) {
        return (dataC.getMonSpecies(_monId));
    }
    
    function _getMonLuck(uint256 _monId) internal view returns (uint8) {
        return (dataC.getMonLuck(_monId));
    }
    
    function _getMonVariant(uint256 _monId) internal view returns (bool) {
        return (dataC.getMonVariant(_monId));
    }
    
    function _getMonExp(uint256 _monId) internal view returns (uint32) {
        return (dataC.getMonExp(_monId));
    }
    
    function _getMonName(uint256 _monId) internal view returns (bytes16) {
        return (dataC.getMonName(_monId));
    }
    
    function _getMonType(uint256 _monId) internal view returns (uint8) {
        return (dataC.getMonType(_monId));
    }
    
    function _getMonSkill1(uint256 _monId) internal view returns (uint8) {
        return (dataC.getMonSkill1(_monId));
    }
    
    function _getMonSkill2(uint256 _monId) internal view returns (uint8) {
        return (dataC.getMonSkill2(_monId));
    }
    
    function _getMonOwner(uint256 _monId) internal view returns (address) {
        return (dataC.ownerOf(_monId));
    }
    
    function _getSpeciesHpStep(uint16 _species) internal view returns (uint16) {
        return (dataC.getSpeciesHpStep(_species));
    }
    
    function _getSpeciesAttStep(uint16 _species) internal view returns (uint16) {
        return (dataC.getSpeciesAttStep(_species));
    }
    
    function _getSpeciesSpdStep(uint16 _species) internal view returns (uint16) {
        return (dataC.getSpeciesSpdStep(_species));
    }
    
    function _getSpeciesSkill1(uint16 _species) internal view returns (uint8) {
        return (dataC.getSpeciesSkill1(_species));
    }
    
    function _getSpeciesSkill2(uint16 _species) internal view returns (uint8) {
        return (dataC.getSpeciesSkill2(_species));
    }
    
    ////////////////////////////
    // Storage Contract Write // 
    //(Requires contract added//
    //  to gameContracts list)//
    ////////////////////////////
    
    function _changeMonExp(uint256 _monId, uint32 _amt) internal {
        dataC.changeMonExp(_monId, _amt);
    }
    
    function _addMonToPlayer(address _to, uint16 _species) internal {
        dataC.addMonToPlayer(_to, _species);
    }
    
    ///////////////////////
    //Thanks for reading!//
    //------pben95-------//
    ///////////////////////
    
}