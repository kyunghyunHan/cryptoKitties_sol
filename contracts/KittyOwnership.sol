// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;
import "./KittyBase.sol";

contract KittyOwnership is KittyBase,ERC721  {

    //ERC721양식
    string public name = "CryptoKitties";
    string public symbol = "CK";

    
    bool public implementsERC721 = true;
    //ERC721양식을 따르는지이 여부 반환,무조건 true를 반환
    function implementsERC721() public pure returns (bool){
        return true;

    }
     /*
     _claimant계정이 _tokenid를 소유하고 있는지 여부 반환,kittyindexToOwner변수 read
      */
     function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return kittyIndexToOwner[_tokenId] == _claimant;
        //address owner = ownerOf(_tokenId);
        //return (_claimant == owner);
    }
    /*_claimant계정이 _tokenId에대해 approve되어 있는지 여부확인
       kittyIndexToApproved 변수read
     */
    function _approvedFor(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return kittyIndexToApproved[_tokenId] == _claimant;
    }
     
     /*
     _tokenID에 대한 approve계정으로 _approved계정할당 
     - kittyIndexToApproved write
      */
    function _approve(uint256 _tokenId, address _approved) internal {
        kittyIndexToApproved[_tokenId] = _approved;
    }
   /*
   사용자가 실수로 KittyCore로 보낸 Kitty를 _recipient계정으로 보내는 함수
    */
    function rescueLostKitty(uint256 _kittyId, address _recipient) public onlyCOO whenNotPaused {
        require(_owns(address(this), _kittyId));
        _transfer(address(this), _recipient, _kittyId);
    }

    /* 
    ERC721양식
    _owner계정이 소유중인 Kitty개수반환,ownershipTokenCount변수 read
    */
    function balanceOf(address _owner) public view returns (uint256 count) {
        return ownershipTokenCount[_owner];
    }
    /*
    ERC721양식
    호출자가 _tokenId소유중인지 체크후 _to에게 전송함
    
     */
    function transfer(
        address _to,
        uint256 _tokenId
    )
        public
        whenNotPaused
    {
        require(_to != address(0));
        require(_owns(msg.sender, _tokenId));

        _transfer(msg.sender, _to, _tokenId);
    }

    /*
    - ERC721양식
    - 호출자가 _tokenid소유중인지 체크 후 _to를 approve함
     */
    
     function approve(
        address _to,
        uint256 _tokenId
    )
        public
        whenNotPaused
    {
        // Only an owner can grant transfer approval.
        require(_owns(msg.sender, _tokenId));

        // Register the approval (replacing any previous approval).
        _approve(_tokenId, _to);

        // Emit approval event.
        Approval(msg.sender, _to, _tokenId);
    }

    /* 
    ERC721양식 
    - 호출자가 _tokenid에 대해 approved됐는지 체크 
    및 _from이 _tokenid를 소유하는지 체크 후 _from에서_tokenid를 소유하는지 체크후 
    _from에서 _to로 _tokenid전송
    
    */
     function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
        public
        whenNotPaused
    {
        // Check for approval and valid ownership
        require(_approvedFor(msg.sender, _tokenId));
        require(_owns(_from, _tokenId));

        // Reassign ownership (also clears pending approvals and emits Transfer event).
        _transfer(_from, _to, _tokenId);
    }
    /*전체 kitty수 반환 */
    function totalSupply() public view returns (uint) {
        return kitties.length - 1;
    }
    /*_tokenid의 owner계정반환 */
     function ownerOf(uint256 _tokenId)
        public
        view
        returns (address owner)
    {
        owner = kittyIndexToOwner[_tokenId];

        require(owner != address(0));
    }
/* ERC721optional
   _owner가 소유하는 Kitty개수 -1사이의 인덱스에 해당하는 Kitty id반환
    */
        function tokensOfOwnerByIndex(address _owner, uint256 _index)
        external
        view
        returns (uint256 tokenId)
    {
        uint256 count = 0;
        for (uint256 i = 1; i <= totalSupply(); i++) {
            if (kittyIndexToOwner[i] == _owner) {
                if (count == _index) {
                    return i;
                } else {
                    count++;
                }
            }
        }
        revert();
    }

}