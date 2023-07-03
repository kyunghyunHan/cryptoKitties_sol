pragma solidity ^0.8.17;

import "./KittyBaseV2.sol";

contract KittyOwnershipV2 is KittyBaseV2 {

 
    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        // return kittyIndexToOwner[_tokenId] == _claimant;
        address owner = ownerOf(_tokenId);
        return (_claimant == owner);
    }


    function rescueLostKitty(uint256 _kittyId, address _recipient) public onlyCOO whenNotPaused {
        require(_owns(address(this), _kittyId));
        _transfer(address(this), _recipient, _kittyId);
    }

    
}