pragma solidity ^0.8.17;

import "./KittyAuction.sol";

contract KittyMinting is KittyAuction {
    //프로모션용 Kityy최대발행수량 5천개리밋
    uint256 public promoCreationLimit = 5000;
    //0세대 키티 최대 발행수량 5만개 리밋,프로모션 개수도 포함되는 양
    uint256 public gen0CreationLimit = 50000;
    //0세대 키티 경매 시작 가격
    uint256 public gen0StartingPrice = 0.01 ether;
    //키티의 경매기간ㄴ
    uint256 public gen0AuctionDuration = 1 days;
  //민팅된ㅍ 프로모션 키티 순ㄴ
    uint256 public promoCreatedCount;
    //민팅된 0세대 키티 수 프로모션도 포함
    uint256 public gen0CreatedCount;

    //압력받은 genes유전자를 가진 0세대 프로모션 키티를 owner에게 민팅함 COO계정만 호출가능
    function createPromoKitty(uint256 _genes, address _owner) public onlyCOO {
        if (_owner == address(0)) {
             _owner = cooAddress;
        }
        require(promoCreatedCount < promoCreationLimit);
        require(gen0CreatedCount < gen0CreationLimit);

        promoCreatedCount++;
        gen0CreatedCount++;
        _createKitty(0, 0, 0, _genes, _owner);
    }
   //입력받은 genes유전자를 가진 0세대 키티를 민팅 후 saleclockauction에 올림 COO계정만 호출가능
   //- 0세대 키티를 옥션에 올릴떄마다 현재 옥션 상황에 따라 가격이 조정되어 등록됨

    function createGen0Auction(uint256 _genes) public onlyCOO {
        require(gen0CreatedCount < gen0CreationLimit);

        uint256 kittyId = _createKitty(0, 0, 0, _genes, address(this));
        _approve(address(saleAuction), kittyId);

        saleAuction.createAuction(
            kittyId,
            _computeNextGen0Price(),
            0,
            gen0AuctionDuration,
            address(this)
        );

        gen0CreatedCount++;
    }

    //새로운 0세대 키티 가격 책정시 최근 5개의 0세대 키티의 경매가 평균의 1.5배의 가격으로 측정
    function _computeNextGen0Price() internal view returns (uint256) {
        uint256 avePrice = saleAuction.averageGen0SalePrice();

        require(avePrice < 340282366920938463463374607431768211455);

        uint256 nextPrice = avePrice + (avePrice / 2);

        if (nextPrice < gen0StartingPrice) {
            nextPrice = gen0StartingPrice;
        }

        return nextPrice;
    }
}