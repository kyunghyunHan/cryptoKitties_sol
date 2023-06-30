// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./KittyAccessControlV2.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
/*상속 */
contract KittyBaseV2 is KittyAccessControlV2, ERC721Enumerable, ERC721Holder {

    string _name = "CryptoKitties";
    string _symbol = "CK";
    constructor() ERC721(_name, _symbol) {}

/*Kitty가 민팅될떄마다 Birth이벤트발생 */
    event Birth(address indexed owner, uint256 kittyId, uint256 matronId, uint256 sireId, uint256 genes);

/* Kitty가 transfer될떄마다 Transfer이벤트발생*/
// event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    //키티
    struct Kitty {
        //Kitty유전자 조합
       uint256 genes;
       //kitty가 민팅된 block time stamp
       uint64 birthTime;
       //교배후 자식 kitty가 민팅이 가능해지는 시작,다음 교배가 가능해지는 시각
       uint64 cooldownEndTime;
       //엄마 kitty id
       uint32 matronId;
       //아빠 kitty id
       uint32 sireId;
       //교배중인 키티 id
       uint32 siringWithId;
       //교배시 1씩 증가하여 교배 쿨타임 기간 증가,13이 최대
       uint16 cooldownIndex;
       //몇세대 kitty인지
       uint16 generation;

    }
     
     /* 교배 쿨타임 기간 리스트
       - 기간 리스트,교배할떄마다 cooldowns index 1씩 증가
       - 러프하게 쿨타임 기간이 2배씩 증가함 최대 7일
      */
      uint32[14] public cooldowns = [
        uint32(1 minutes),
        uint32(2 minutes),
        uint32(5 minutes),
        uint32(10 minutes),
        uint32(30 minutes),
        uint32(1 hours),
        uint32(2 hours),
        uint32(4 hours),
        uint32(8 hours),
        uint32(16 hours),
        uint32(1 days),
        uint32(2 days),
        uint32(4 days),
        uint32(7 days)
    ];
     
    /*전체 크립토키티 정보배열 */
    Kitty[] kitties;
    
    /* 해당 키티가 누구 소유인지 */
    // mapping (uint256 => address) public kittyIndexToOwner;
    /* 해당 계정이 몇개의 Kitty소유하는지 */
    // mapping (address => uint256) ownershipTokenCount;
    /* transferFrom을 콜하려는 대상을 appove*/
    // mapping (uint256 => address) public kittyIndexToApproved;
    /*교배 대상 stringKittyID에대해 siring apprve가 되어야함 */
    mapping (uint256 => address) public sireAllowedToAddress;

    /*키티를 전송하는 internal함수 */
    function _transfer(address _from, address _to, uint256 _tokenId) override internal virtual {
 
        // ownershipTokenCount[_to]++;
   
        // kittyIndexToOwner[_tokenId] = _to;
        if (_from != address(0)) {
            // ownershipTokenCount[_from]--;
            delete sireAllowedToAddress[_tokenId];
            // delete kittyIndexToApproved[_tokenId];
        }
        // Transfer(_from, _to, _tokenId);
        super._transfer(_from, _to, _tokenId);
     }
     /*키티를 민팅하는 함수 */
     function _createKitty(
        uint256 _matronId,
        uint256 _sireId,
        uint256 _generation,
        uint256 _genes,
        address _owner
    )
        internal
        returns (uint)
    {
        
        require(_matronId <= 4294967295);
        require(_sireId <= 4294967295);
        require(_generation <= 65535);

        Kitty memory _kitty = Kitty({
            genes: _genes,
            birthTime: uint64(block.timestamp),
            cooldownEndTime: 0,
            matronId: uint32(_matronId),
            sireId: uint32(_sireId),
            siringWithId: 0,
            cooldownIndex: 0,
            generation: uint16(_generation)
        });
        kitties.push(_kitty);
        uint256 newKittenId = kitties.length - 1;

       
        require(newKittenId <= 4294967295);

        
        emit Birth(
            _owner,
            newKittenId,
            uint256(_kitty.matronId),
            uint256(_kitty.sireId),
            _kitty.genes
        );


        // _transfer(0, _owner, newKittenId);
        _safeMint(_owner, newKittenId);

        return newKittenId;
    }
}