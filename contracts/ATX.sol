pragma solidity ^0.4.18;

import "./token/MiniMeToken.sol";

contract ATX is MiniMeToken {
    mapping (address => bool) public blacklisted;
    bool public generateFinished;

    // @dev ATX constructor just parametrizes the MiniMeToken constructor
    function ATX(address _tokenFactory)
    MiniMeToken(
        _tokenFactory,
        0x0,            // no parent token
        0,              // no snapshot block number from parent
        "Aston X",  // Token name
        18,                 // Decimals
        "ATX",              // Symbol
        false               // Enable transfers
    ) {}

    function generateTokens(address _owner, uint _amount) public onlyController returns (bool) {
        require(generateFinished == false);
        return super.generateTokens(_owner, _amount);
    }
    
    function swapTokens(address[] _owners, uint[] _amounts) public onlyController returns (uint) {
        require(generateFinished == false);
        require(_owners.length == _amounts.length);
        require(_owners.length > 0 && _amounts.length > 0);

        uint gencnt = 0;
        for(uint i=0; i<_owners.length; i++) {
            if(super.generateTokens(_owners[i], _amounts[i])) {
                gencnt++;
            }
        }
        return gencnt;
    }

    function resetTokens(address[] _owners, uint[] _amounts) public onlyController returns (uint) {
        require(generateFinished == false);
        require(_owners.length == _amounts.length);
        require(_owners.length > 0 && _amounts.length > 0);

        uint resetcnt = 0;
        for(uint i=0; i<_owners.length; i++) {
            if(super.destroyTokens(_owners[i], _amounts[i])) {
                resetcnt++;
            }
        }
        return resetcnt;
    }
    
    function doTransfer(address _from, address _to, uint _amount) internal returns(bool) {
        require(blacklisted[_from] == false);
        return super.doTransfer(_from, _to, _amount);
    }

    function finishGenerating(bool _finishGenerating) public onlyController {
        generateFinished = _finishGenerating;
    }

    function blacklistAccount(address tokenOwner) public onlyController returns (bool) {
        blacklisted[tokenOwner] = true;
        return true;
    }
    function unBlacklistAccount(address tokenOwner) public onlyController returns (bool) {
        blacklisted[tokenOwner] = false;
        return true;
    }
    function destruct(address to) public onlyController returns(bool) {
        selfdestruct(to);
        return true;
    }
}
