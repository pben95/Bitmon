pragma solidity 0.4.21;

//////////////////////////////////////////////////
//----------------------------------------------//
//------------Bitmon Stats Interface------------//
//Written by pben95: https://github.com/pben95/ //
//----------------------------------------------//
//////////////////////////////////////////////////
//----------------------------------------------//
//--For gameplay contracts to read the storage--//
//--contract and access certain game functions--//
//----------------------------------------------//
//////////////////////////////////////////////////

interface IBitmonStats {
    
    ////////////
    //Mon Read//
    ////////////
    
    function getMonHp(uint256 _monId) external view returns (uint16);  //Gets mon's hp stat
    
    function getMonAtt(uint256 _monId) external view returns (uint16);  //Gets mon's att stat
    
    function getMonSpd(uint256 _monId) external view returns (uint16);  //Gets mon's spd stat
    
    function getMonLuck(uint256 _monId) external view returns (uint8);  //Gets mon's luck stat
    
    function getMonLevel(uint256 _monId) external view returns (uint8);  //Gets mon's level
    
    function getMonExp(uint256 _monId) external view returns (uint32);  //Gets mon's exp
    
    function getMonSpecies(uint256 _monId) external view returns (uint16);  //Gets mon's species
    
    function getMonVariant(uint256 _monId) external view returns (bool);  //Gets if mon is variant/shiny or not
    
    function getMonName(uint256 _monId) external view returns (bytes16);  //Gets mon's name (no name default)
    
    function getMonType(uint256 _monId) external view returns (uint8);  //Gets mon's type (first gets species of mon, then gets species monType)
    
    function getMonSkill1(uint256 _monId) external view returns (uint8);  //Gets mon's skill1 (first get species of mon, then get species skill1)
    
    function getMonSkill2(uint256 _monId) external view returns (uint8);  //Gets mon's skill2 (first get species of mon, then get species skill2)
    
    function ownerOf(uint256 _tokenId) external view returns (address);  //Gets mon's owner
    
    ////////////////
    //Species Read//
    ////////////////
    
    function getSpeciesMonType(uint16 _species) external view returns (uint8);  //Gets species monType
    
    function getSpeciesHpStep(uint16 _species) external view returns (uint8);  //Gets species hp growth step
    
    function getSpeciesAttStep(uint16 _species) external view returns (uint8);  //Gets species att growth step
    
    function getSpeciesSpdStep(uint16 _species) external view returns (uint8);  //Gets species spd growth step
    
    function getSpeciesSkill1(uint16 _species) external view returns (uint8);  //Gets species skill1
    
    function getSpeciesSkill2(uint16 _species) external view returns (uint8);  //Gets species skill2
    
    function getSpeciesEvos(uint16 _species) external view returns (uint8);  //Gets species number of evolutions
    
    /////////////
    //Mon Write//
    /////////////
    
    function addMonToPlayer(address _to, uint16 _species) external;  //Adds new mon of a certain species to a given player, game contracts only
    
    function changeMonExp(uint256 _monId, uint32 _amount) external;  //Add certain amount of exp to given mon, game contracts only
    
    ///////////////////////
    //Thanks for reading!//
    //------pben95-------//
    ///////////////////////
    
}