// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./KittyMinting.sol";
contract KittyCore is KittyMinting {

        address public newContractAddress;
            constructor() {
       
        _pause(); // Pausable

        // the creator of the contract is the initial CEO
        ceoAddress = msg.sender;

        // the creator of the contract is also the initial COO
        cooAddress = msg.sender;

        // start with the mythical kitten 0 - so we don't have generation-0 parent issues
        _createKitty(0, 0, 0, type(uint256).max, address(0x000000000000000000000000000000000000dEaD));
    }


       function setNewAddress(address _v2Address) public onlyCEO whenPaused {
        newContractAddress = _v2Address;
        emit ContractUpgrade(_v2Address);
    }


    receive() external payable {
        require(
            msg.sender == address(saleAuction)
        );
    }

    
    function getKitty(uint256 _id)
        public
        view
        returns (
        bool isGestating,
        bool isReady,
        uint256 cooldownIndex,
        uint256 nextActionAt,
        uint256 siringWithId,
        uint256 birthTime,
        uint256 matronId,
        uint256 sireId,
        uint256 generation,
        uint256 genes
    ) {
        Kitty storage kit = kitties[_id];

        // if this variable is 0 then it's not gestating
        isGestating = (kit.siringWithId != 0);
        isReady = (kit.cooldownEndTime <= block.timestamp);
        cooldownIndex = uint256(kit.cooldownIndex);
        nextActionAt = uint256(kit.cooldownEndTime);
        siringWithId = uint256(kit.siringWithId);
        birthTime = uint256(kit.birthTime);
        matronId = uint256(kit.matronId);
        sireId = uint256(kit.sireId);
        generation = uint256(kit.generation);
        genes = kit.genes;
    }

    /// @dev Override unpause so it requires all external contract addresses
    ///  to be set before contract can be unpaused. Also, we can't have
    ///  newContractAddress set either, because then the contract was upgraded.
    function unpause() public override virtual onlyCEO {
        require(address(saleAuction) != address(0));
        // require(address(siringAuction) != address(0));
        // require(address(geneScience) != address(0));
        require(newContractAddress == address(0));

        // Actually unpause the contract.
        super.unpause();
    }
}





/*
new ContractAddress:KittyCore컨트렉트업그레이드시 새로운 KittyCore컨트렉트 주소 변수
 */

 /*
 KittyCore :컨트렉트생성자,
 paused KittyCore배포시 paused상태로 시작
 ceoAddress:CeomCoo계정은 컨트렉트 배포 계정으로 설정
 _createKitty:uint256최댓값을 gene으로 한 0세대 Kitty를 0번 주소에 민팅
*/

/*
setNewAddress
- KittyCore컨트렉트에 버그가 있어서 업그레이드시 새로운 키티 코어 주소를 등록함
- 키티코어 컨트렉트가 paused상태에서 CEO계정만 호출가능
 */

 /*
 이더를 받을수 잇는 컨트렉트
 - require문에서SaleClockAuction과 SiringAuction으로 제한함
*/

/*
getKitty
- id에 해당하는 키티정보반환
- isGastiing:현재 임신기간인지 여부확인,현재 교배를 진행한 상대 키티 아이디가 세팅되어 있는지 여부판단
- isReady:교배가 가능한 상태인지 여부 ,교배 쿨다운 타임이 지났는지 여부로 판단
 */

 /* unpause
 - saleAuction,siringAuction,geneScience컨트렉트 주소가 모두 세팅되어 있고 newCotractAddress가 세팅되어 잇지 않은걸 체크한 후 상속받는 KittyAccessControl의unpause호출
  */