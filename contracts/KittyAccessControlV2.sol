// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;


import "@openzeppelin/contracts/security/Pausable.sol";

contract KittyAccessControlV2 is Pausable {
    /*새로운 컨트렉트 주소로 컨트랙트 업그레이드 시 발생하는 이벤트 */
    event ContractUpgrade(address newContract);
    /*컨트렉트에서 import 하는 컨트렉트 주소를 세팅해주는 역활의 계정 */
    address public ceoAddress;
    /*kittyCore에서 돈을 인출하는 역활의계정 */
    address public cfoAddress;
    /*크립토키티의 전반적인 운영에 기여하는 계정 
    서비스 운영용 함수 호출
    */
    address public cooAddress;
    /*크립토 키티 서비스 중지 여부 표식 */
    // bool public paused = false;
     
    /*CEO계정만 호출할수 있도록 해주는 제약자 */
    modifier onlyCEO() {
        require(msg.sender == ceoAddress);
        _;
    }
    /*CFO계정만 호출할수 있도록 해주는 제약자 */
    modifier onlyCFO() {
        require(msg.sender == cfoAddress);
        _;
    } 
    /*COO계정만 호출할수 있도록 해주는 제약자 */
    modifier onlyCOO() {
        require(msg.sender == cooAddress);
        _;
    }
    /*onlyCLevel
    CEO,CFO,COO계정만 호출할수 있도록 하는 제약자
     */
    modifier onlyCLevel() {
        require(
            msg.sender == cooAddress ||
            msg.sender == ceoAddress ||
            msg.sender == cfoAddress
        );
        _;
    }

    /*CEO계정 세팅함수 CEO계정만 호출가능*/
    function setCEO(address _newCEO) public onlyCEO {
        require(_newCEO != address(0));

        ceoAddress = _newCEO;
    }

    /*CFO계정 세팅함수 CFO계정만 호출가능*/
    function setCFO(address _newCEO) public onlyCEO {
        require(_newCEO != address(0));

        ceoAddress = _newCEO;
    }

    /*COO계정 세팅함수 COO계정만 호출가능*/
    function setCOO(address _newCEO) public onlyCEO {
        require(_newCEO != address(0));

        ceoAddress = _newCEO;
    }

    /*KittuCore컨트렉트에 쌓인 ETH를 CFO계정으로 인출하는 함수 CFO계정만 호출가능 */
    function withdrawBalance() external onlyCFO {
        // cfoAddress.transfer(this.balance);
        (bool success, ) = payable(cfoAddress).call{value: address(this).balance}("");
        require(success, "Failed to send Ether");
    }
    /*KittyCore가 paused상태가 아닌 경우에만 호출가능하도록 하는 제약자 */    
    // modifier whenNotPaused() {
    //     require(!paused);
    //     _;
    // }
    // /*KittyCore가 Paused상태일떄만 호출가능하도록 하는 제약자 */
    // modifier whenPaused {
    //      require(paused);
    //      _;
    //  }

     /*kittyCore를 pause시키는 함수 unpaused상태에서 CLevel계정만 호출가능 */
    function pause() public onlyCLevel {
        // paused = true;
        _pause();
    }
    /*kittyCore를 unpaused 시키는 함수 paused상태에서 CEO계정만 호출가능*/
    function unpause() public virtual onlyCEO {
        // paused = false;
        _unpause();
    }

}