// SPOX-LICEnse-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
// ReentrancyGuard` 来防止重入攻击
// 所有可能发送 ETH 的函数都使用了 `nonReentrant` 修饰器来防止重入攻击

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

    // 拍卖由卖家开启
    // 合约接收token，确保拍品在合约的控制内。
    constructor(
        address _erc721Address,
        uint256 _tokenId,
        uint256 _startingBid,
        uint256 _biddingtime,
        uint256 _minBidIncrement,
        bytes calldata data
    ) {
        // 拍卖至少1小时
        if (_biddingtime < 1 hours) revert BiddingTimeTooShort();

        // 拍品给到拍卖合约
        IERC721(_erc721Address).safeTransferFrom(msg.sender, address(this), _tokenId, data);

        i_seller = msg.sender;
        i_ERC721 = _erc721Address;
        i_tokenId = _tokenId;
        i_minBidIncrement = _minBidIncrement;
        //   `i_minBidIncrement` 来设置最小加价幅度

        s_started = true;
        s_endTimestamp = block.timestamp + _biddingtime;
        s_highestBidder = msg.sender;
        s_highestBid = _startingBid;
        // 起拍价

        emit AuctionStarted(_tokenId, s_endTimestamp);
    }

    // 优化了 `bid` 函数，处理了首次出价的情况。
    function bid() external payable nonReentrant {
        if (!s_started) revert AuctionNotStarted();
        if (s_ended || block.timestamp >= s_endTimestamp) revert Error_AuctionEnded();
        if (msg.value <= s_highestBid + i_minBidIncrement) revert BidNotHighEnough();
        // 限制最小加价幅度，防止小幅加价导致拍卖时间无限延长。

        // 如果出价时间是最后1分钟内,拍卖延长3分钟
        if (s_endTimestamp - block.timestamp < 1 minutes) {
            s_endTimestamp += 3 minutes;
        }

        if (s_highestBidder != address(0)) {
            s_bids[s_highestBidder] += s_highestBid;
        }

        s_highestBidder = msg.sender;
        s_highestBid = msg.value;
        // s_bids[msg.sender] += msg.value;

        emit HighestBidincreased(msg.sender, msg.value);
    }
    /* 拍卖必须已经开始，且未结束
       新的出价必须高于当前最高出价。 */

    // 撤回出价
    function withdrawBid() external nonReentrant {
        if (msg.sender == s_highestBidder) revert CannotWithdrawHighestBid();

        uint256 amount = s_bids[msg.sender];
        if (amount == 0) revert NothingToWithdraw();
        delete s_bids[msg.sender];

        (bool sent,) = msg.sender.call{value: amount}("");
        if (!sent) revert FailedToWithdrawBid(msg.sender, amount);
    }
    // 当前最高出价者不能调用,防止拍卖无效
    // call 是一个推荐的安全发送 ETH 的方式, 没有 gas 限制问题。

    // 拍卖结束
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
            // 流拍则转回给卖家
            IERC721(i_ERC721).safeTransferFrom(address(this), i_seller, i_tokenId, "");
        }

        emit AuctionEnded(s_highestBidder, s_highestBid);
    }

    // 增加紧急机制
    // cancelAuction 允许卖家取消拍卖
    function cancelAuction() external {
        if (msg.sender != i_seller) revert OnlySellerCanCancel();
        if (s_ended) revert Error_AuctionEnded();

        s_ended = true;
        IERC721(i_ERC721).safeTransferFrom(address(this), i_seller, i_tokenId, "");

        emit AuctionCancelled();
    }

    // 接收NFT
    function onERC721Received(address operator, address from, uint256 _tokenId, bytes calldata data)
        external
        override
        returns (bytes4)
    {
        if (msg.sender != i_ERC721) revert OnlyERC721Supported();
        if (_tokenId != i_tokenId) revert InvalidTokenId();

        return IERC721Receiver.onERC721Received.selector;
    }

    // 查询是否支持接口
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165) returns (bool) {
        return interfaceId == type(IERC721Receiver).interfaceId || interfaceId == type(IERC165).interfaceId;
    }
}
