// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "./KittyAccessControl.sol";
/*상속 */
contract KittyBase is KittyAccessControl {

/*Kitty가 민팅될떄마다 Birth이벤트발생 */
event Birth(address indexed owner, uint256 kittyId, uint256 matronId, uint256 sireId, uint256 genes);

/* Kitty가 transfer될떄마다 Transfer이벤트발생*/
event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

}