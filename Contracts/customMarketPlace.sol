// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

contract customMarketPlace is ERC1155Holder {
    IERC1155 public nftContract;

    event ItemListed(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price
    );

    constructor(address _nftContract) {
        nftContract = IERC1155(_nftContract);
    }

    // function getCurrentOwner(uint256 _tokenId) public view returns (address) {
    //     return nftContract.getCurrentOwner(_tokenId);
    // }

    function tranferToken(
        address owner,
        uint256 tokenId,
        uint256 amount
    ) external payable {
        nftContract.safeTransferFrom(owner, msg.sender, tokenId, 1, "");
        //nftContract.transferOwnership(owner);
    }
}
