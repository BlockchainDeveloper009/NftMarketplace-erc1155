// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Collection2SingleMinting is ERC1155, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _nftSold;

    //collections
    uint256[] public supplies = [1, 1, 1, 1, 1, 1, 1, 1];
    uint256[] public minted = [0, 0, 0, 0, 0, 0, 0, 0];
    address automatedContractOperator;
    //string baseURI="ipfs://QmPQZK5ma6PVAhvZFwxEiHpMdGnEyHR2nZwjC3bkm9rPuY/{id}.json";
    string baseURI = "ipfs://QmPQZK5ma6PVAhvZFwxEiHpMdGnEyHR2nZwjC3bkm9rPuY/";
    string constructorURI = string(abi.encodePacked(baseURI, "{id}.json"));
    event mintSuccess(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId
    );

    mapping(uint256 => NftData) nftTracker;

    //[token]
    mapping(uint256 => mapping(address => bool)) public member;
    string public name = "Legends of Krump";
    //  _price is the price of one Crypto Dev NFT
    uint256 public _price = 2000 gwei;
    struct NftData {
        uint256 totalSupplies;
        uint256 minted;
        address operator;
        address currentOwner;
    }

    constructor() ERC1155(baseURI) {}

    // to Put NFT to Opensea
    function uri(
        uint256 _tokenId
    ) public view override returns (string memory) {
        require(_tokenId <= supplies.length - 1, "NFT does not exist");
        return
            string(
                abi.encodePacked(baseURI, Strings.toString(_tokenId), ".json")
            );
    }

    function mintByTokenId(uint256 _tokenId) public payable {
        require(
            !member[_tokenId][msg.sender],
            "You have already claimed this NFT."
        );
        require(_tokenId <= supplies.length - 1, "NFT does not exist");
        uint256 index = _tokenId;

        require(
            minted[index] + 1 <= supplies[index],
            "All the NFT have been minted"
        );
        require(msg.value >= _price, "Ether sent is not correct");
        _mint(msg.sender, _tokenId, 1, "");
        setApprovalForAll(address(this), true);

        // "" is data which is set empty
        minted[index] += 1;
        member[_tokenId][msg.sender] = true;
    }

    //to be used By cross-mint, latest
    function mintByExternalAutoTokenId(
        address _to,
        uint quantity,
        address _operator
    ) public payable {
        uint256 _tokenId = _tokenIds.current();
        require(nftTracker[_tokenId].minted == 0, " NFT have been minted");
        require(msg.value >= _price, "Ether sent is not correct");

        nftTracker[_tokenId] = NftData(1, 0, _operator, address(0x00));
        _mint(_to, _tokenId, quantity, "");
        _tokenIds.increment();
        setApprovalForAll(_operator, true);
        // "" is data which is set empty
        nftTracker[_tokenId].currentOwner = _to;
        nftTracker[_tokenId].minted = 1;
        member[_tokenId][msg.sender] = true;
    }

    function totalNftMinted() public view returns (uint256) {
        return _tokenIds.current(); //minted[_tokenId];
    }

    function isTokenMinted(uint256 _tokenId) public view returns (bool) {
        return nftTracker[_tokenId].minted == 1;
    }

    function getOperator(uint256 _tokenId) public view returns (address) {
        return nftTracker[_tokenId].operator;
    }

    function setCurrentOwner(
        uint256 _tokenId,
        address cOwner
    ) public onlyOwner {
        nftTracker[_tokenId].currentOwner = cOwner;
    }

    function getCurrentOwner(uint256 _tokenId) public view returns (address) {
        return nftTracker[_tokenId].currentOwner;
    }

    function setSuperOperator(address _operator) public onlyOwner {
        automatedContractOperator = _operator;
        setApprovalForAll(_operator, true);
    }

    // should pass ipfs://QmPQZK5ma6PVAhvZFwxEiHpMdGnEyHR2nZwjC3bkm9rPuY/{id}.json
    function setURI(string memory newuri) public onlyOwner {
        baseURI = newuri;
        _setURI(newuri);
    }
}
