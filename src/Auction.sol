// SPOX-LICEnse-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Auction is IERC721Receiver, ReentrancyGuard {
    error TooEarlyToEnd();
    error BidNotHighEnough();
    error NothingToWithdraw();
    error Error_AuctionEnded();
    error BiddingTimeTooShort();
    error OnlyERC721Supported();
    error NoAuctionsInProgress();
    error CannotWithdrawHighestBid();
    error FailedToSendEth(address recipient, uint256 amount);
    error FailedToWithdrawBid(address bidder, uint256 amount);
    error InvalidTokenId();
    error OnlySellerCanCancel();
    error AuctionNotStarted();

    address public immutable i_seller;
    address public immutable i_ERC721;
    uint256 public immutable i_tokenId;
    uint256 public immutable i_minBidIncrement;

    bool public s_started;
    bool public s_ended;
    uint256 public s_endTimestamp;

    address public s_highestBidder;
    uint256 public s_highestBid;

    mapping(address bidder => uint256 totalBiddedETH) public s_bids;

    event AuctionStarted(uint256 indexed tokenId, uint256 indexed endTimestamp);
    event HighestBidincreased(address indexed bidder, uint256 indexed amount);
    event AuctionEnded(address indexed winner, uint256 indexed winningBid);
    event AuctionCancelled();

    constructor(
        address _erc721Address,
        uint256 _tokenId,
        uint256 _startingBid,
        uint256 _biddingtime,
        uint256 _minBidIncrement,
        bytes calldata data
    ) {
        if (_biddingtime < 1 hours) revert BiddingTimeTooShort();

        IERC721(_erc721Address).safeTransferFrom(msg.sender, address(this), _tokenId, data);

        i_seller = msg.sender;
        i_ERC721 = _erc721Address;
        i_tokenId = _tokenId;
        i_minBidIncrement = _minBidIncrement;

        s_started = true;
        s_endTimestamp = block.timestamp + _biddingtime;
        s_highestBidder = msg.sender;
        s_highestBid = _startingBid;

        emit AuctionStarted(_tokenId, s_endTimestamp);
    }

    function bid() external payable nonReentrant {
        if (!s_started) revert AuctionNotStarted();
        if (s_ended || block.timestamp >= s_endTimestamp) revert Error_AuctionEnded();
        if (msg.value <= s_highestBid + i_minBidIncrement) revert BidNotHighEnough();

        if (s_endTimestamp - block.timestamp < 1 minutes) {
            s_endTimestamp += 3 minutes;
        }

        if (s_highestBidder != address(0)) {
            s_bids[s_highestBidder] += s_highestBid;
        }

        s_highestBidder = msg.sender;
        s_highestBid = msg.value;

        emit HighestBidincreased(msg.sender, msg.value);
    }

    function withdrawBid() external nonReentrant {
        if (msg.sender == s_highestBidder) revert CannotWithdrawHighestBid();

        uint256 amount = s_bids[msg.sender];
        if (amount == 0) revert NothingToWithdraw();
        delete s_bids[msg.sender];

        (bool sent,) = msg.sender.call{value: amount}("");
        if (!sent) revert FailedToWithdrawBid(msg.sender, amount);
    }

    function endAuction() public nonReentrant {
        // 拍卖要已经开始, 当前时间超过结束时间
        if (!s_started) revert AuctionNotStarted();
        if (s_ended) revert Error_AuctionEnded();
        if (block.timestamp < s_endTimestamp) revert TooEarlyToEnd();

        s_ended = true;

        if (s_highestBidder != address(0)) {
            IERC721(i_ERC721).safeTransferFrom(address(this), s_highestBidder, i_tokenId, "");
            (bool sent,) = i_seller.call{value: s_highestBid}("");
            if (!sent) revert FailedToSendEth(i_seller, s_highestBid);
        } else {
            IERC721(i_ERC721).safeTransferFrom(address(this), i_seller, i_tokenId, "");
        }

        emit AuctionEnded(s_highestBidder, s_highestBid);
    }

    function cancelAuction() external {
        if (msg.sender != i_seller) revert OnlySellerCanCancel();
        if (s_ended) revert Error_AuctionEnded();

        s_ended = true;
        IERC721(i_ERC721).safeTransferFrom(address(this), i_seller, i_tokenId, "");

        emit AuctionCancelled();
    }

    function onERC721Received(address operator, address from, uint256 _tokenId, bytes calldata data)
        external
        override
        returns (bytes4)
    {
        if (msg.sender != i_ERC721) revert OnlyERC721Supported();
        if (_tokenId != i_tokenId) revert InvalidTokenId();

        return IERC721Receiver.onERC721Received.selector;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165) returns (bool) {
        return interfaceId == type(IERC721Receiver).interfaceId || interfaceId == type(IERC165).interfaceId;
    }
}
