pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

//모든 키립토 옥션의 근간이기능이 되는 부분
contract ClockAuctionBase is ERC721Holder {

    struct Auction {
        address seller;//nft소유자이자 판매자
        uint128 startingPrice;//경매시작가
        uint128 endingPrice;//경매종료가
        uint64 duration;//경매기간
        uint64 startedAt;//경매 시작 시간
    }
    //연동될 NFT컨트렉트
    IERC721 public nonFungibleContract;

  //컨트렉트가 거래마다 마진으로 남기는 퍼센티지
    uint256 public ownerCut;
    //토큰 id에 대한 옥션 데이터 매핑 변수
    mapping (uint256 => Auction) tokenIdToAuction;
   //옥션생길떄 발생
    event AuctionCreated(uint256 tokenId, uint256 startingPrice, uint256 endingPrice, uint256 duration);
    //경매성사시 발생
    event AuctionSuccessful(uint256 tokenId, uint256 totalPrice, address winner);
    //옥션 취소시 발생
    event AuctionCancelled(uint256 tokenId);

      //이더를 받을수 없게 payble타입지정x
    fallback() external {}

    //value가 uint64으로 표현가능한지 체크
    modifier canBeStoredWith64Bits(uint256 _value) {
        require(_value <= 18446744073709551615, "_value exceeds 64 bits limit");
        _;
    }
    //value가 uint128으로 표현가능한지 체크

    modifier canBeStoredWith128Bits(uint256 _value) {
        require(_value < 340282366920938463463374607431768211455, "_value exceeds 128 bits limit");
        _;
    }

   //토큰 에 해당하는 nft가 _claimant의 소유인지 여부 반환
    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return (nonFungibleContract.ownerOf(_tokenId) == _claimant);
    }

   //_owner로부터 옥션 컨트렉트로 가져옴
    function _escrow(address _owner, uint256 _tokenId) internal {
        nonFungibleContract.safeTransferFrom(_owner, address(this), _tokenId);
    }

  //_receiver으로 nft전송
    function _transfer(address _receiver, uint256 _tokenId) internal {
        nonFungibleContract.safeTransferFrom(address(this), _receiver, _tokenId);
    }

//옥션 생성함수
    function _addAuction(uint256 _tokenId, Auction memory _auction) internal {
      
        require(_auction.duration >= 1 minutes, "auction duration should be greater than or equal to 1 minutes");

        tokenIdToAuction[_tokenId] = _auction;
        
        emit AuctionCreated(
            uint256(_tokenId),
            uint256(_auction.startingPrice),
            uint256(_auction.endingPrice),
            uint256(_auction.duration)
        );
    }
//옥션취소하고 판매자에게 해당키티를 돌려주는 함수
    function _cancelAuction(uint256 _tokenId, address _seller) internal {
        _removeAuction(_tokenId);
        _transfer(_seller, _tokenId);
        emit AuctionCancelled(_tokenId);
    }

     //실제로 옥션에 가격을 제안하고 성사시키는 함수
     //현재 옥션에 올라와 있는 해당 NFT의 현재 가격이상으로 가격제안을 했는지 체크함
     //판매 금액을 판매자에게 전송하기전에 옥션데이터 삭제함
     //판매 금액의 일정퍼센티지만큼은 수수료로써 플랫폼에 남기고 나머지 금액을 판매자에게 전송함
    function _bid(uint256 _tokenId, uint256 _bidAmount)
        internal
        returns (uint256)
    {
        Auction storage auction = tokenIdToAuction[_tokenId];

   
        require(_isOnAuction(auction), "this _tokenId is not on the auction");

        uint256 price = _currentPrice(auction);
        require(_bidAmount >= price, "_bidAmount should be greater than or equal to auction's current price");


        address seller = auction.seller;

        
        _removeAuction(_tokenId);

        if (price > 0) {
           
            uint256 auctioneerCut = _computeCut(price);
            uint256 sellerProceeds = price - auctioneerCut;

          
            (bool success, ) = payable(seller).call{ value: sellerProceeds }("");
            require(success, "Failed to send sellerProceeds to seller");
        }

        emit AuctionSuccessful(_tokenId, price, msg.sender);

        return price;
    }

    //해당 NFT에 대한 옥션 데이터삭제
    function _removeAuction(uint256 _tokenId) internal {
        delete tokenIdToAuction[_tokenId];
    }

   //해당 옥션데이터가 세팅되어 있는지를체크함으로써 옥션에 등록되어 있는지 여부 반환
    function _isOnAuction(Auction storage _auction) internal view returns (bool) {
        return (_auction.startedAt > 0);
    }
   //해당 옥션이 등록된 후 지난 시간을 계산하여 해당옥션의 현재 가격을 계산하여 반환
    function _currentPrice(Auction storage _auction)
        internal
        view
        returns (uint256)
    {
        uint256 secondsPassed = 0;
        
        
        if (block.timestamp > _auction.startedAt) {
            secondsPassed = block.timestamp - _auction.startedAt;
        }

        return _computeCurrentPrice(
            _auction.startingPrice,
            _auction.endingPrice,
            _auction.duration,
            secondsPassed
        );
    }

   //옥션의 현재 가격을 계산하여 반환
    function _computeCurrentPrice(
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        uint256 _secondsPassed
    )
        internal
        pure
        returns (uint256)
    {
      
        if (_secondsPassed >= _duration) {
         
            return _endingPrice;
        } else {
        
            int256 totalPriceChange = int256(_endingPrice) - int256(_startingPrice);
            
        
            int256 currentPriceChange = totalPriceChange * int256(_secondsPassed) / int256(_duration);
            
           
            int256 currentPrice = int256(_startingPrice) + currentPriceChange;
            
            return uint256(currentPrice);
        }
    }
    //해당 가격에 대해 플랫폼에 남길 퍼센티지만큼의 amount를 계산하여 반환
    function _computeCut(uint256 _price) internal view returns (uint256) {
     

        return _price * ownerCut / 10000;
    }

}