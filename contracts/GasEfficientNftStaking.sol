// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Staking is IERC721Receiver {
    struct Stake {
        uint16 voteId;
        address owner;
    }

    mapping (uint256 => Stake) private stakes;
    ERC721 public nft;

    constructor(address _nftAddress) {
        nft = ERC721(_nftAddress);
    }

    function onERC721Received(
        address operator, 
        address from, 
        uint256 id, 
        bytes calldata data
    ) external override returns (bytes4) {
        require(msg.sender == address(nft), "Wrong NFT");
        uint16 voteId = abi.decode(data, (uint16));
        stakes[id] = Stake(voteId, from);
        return this.onERC721Received.selector;
    }

    function withdrawStake(uint256 id) external {
        address owner = stakes[id].owner;
        require(msg.sender == owner, "Not Owner");
        delete stakes[id];
        nft.transferFrom(address(this), msg.sender, id);
    }
}
