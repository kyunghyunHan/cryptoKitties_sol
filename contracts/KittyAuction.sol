pragma solidity ^0.8.17;

import "./KittyOwnership.sol";
// import "./Auction/ClockAuction.sol";
// import "./Auction/SaleClockAuction.sol";
 

contract KittyAuction is KittyOwnership {

            //컨트렉트 타입 변수
    SaleClockAuction public saleAuction;
   
   //_address 주소를 setAucion에 설정 ,CEO계정만 호출가능
    function setSaleAuctionAddress(address _address) public onlyCEO {
        //컨트렉트 타입 변수
        SaleClockAuction candidateContract = SaleClockAuction(_address);
 
        require(candidateContract.isSaleClockAuction());

        saleAuction = candidateContract;
    }
/*
set SiringAuctionAddress
- address주소를 가지고 siringAuction에설정 CEO 만 호출가능
 */
    /*
    createSaleAuction
    - 호출자가 Kittyid를 소유하고 있는지 체크
    - slaeAuction에대해 Kitty id Approve
    - saleAuction에대해 Kitty에대한 auction생성
    
     */

    function createSaleAuction(
        uint256 _kittyId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration
    )
        public
        whenNotPaused
    {

        require(_owns(msg.sender, _kittyId));
        _approve(address(saleAuction), _kittyId);
         
        saleAuction.createAuction(
            _kittyId,
            _startingPrice,
            _endingPrice,
            _duration,
            msg.sender
        );
    }


/*
createSitingAuction
- 호출자가 Kittyid를 소유하고 있는지 체크
- 해당 kitty가 교배 가능한 상태인지 체크
- siringAuction에 대해 해당 Kitty Approve
- siringActuon에 해당 Kiity에 대한 auction생성
 */
/*bidOnSiringAuction
- 교배옥션에 있느 sireid Kitty와 본인이 소유중인 _martonid kitty를 교배시키는 기능
- 호출가자 matronid소유중인지 체크
- _martonid kitty가 교배 가능한 상태인지 체크
- _martonid kitty와 sireid Kitty가 가족이 아닌지 체크
- 교배 옥션에 있는 sireid Kitty의 교배 가격을 지불하여 교배

 */

 /*
 withdrawAuctionBalances
 - siringAuction쌓인 ETH를 KittyCore로 인출 COO만 인출가능
 
  */
    function withdrawAuctionBalances() external onlyCOO {
        saleAuction.withdrawBalance();
    }
}
/*
KittyBreeding컨트렉트는 생략함으로 KittyOwner컨트렉트 바로 상속

 */