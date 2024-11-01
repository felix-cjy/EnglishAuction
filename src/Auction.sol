// SPOX-LICEnse-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

// 状态加s_前缀.所有状态用internal
contract Auction is IERC721Receiver {
    error CannotWithdrawHighestBid();
    error NothingToWithdraw();
    error FailedToWithdrawBid(address bidder, uint256 amount);
    error BidNotHighEnough();
    error Error_AuctionEnded();
    error FailedToSendEth(address recipient, uint256 amount);
    error NowAuctionsInProgress();
    error TooEarlyToEnd();
    error OnlyERC721Supported();
    error Cooling();

    address internal immutable i_seller;
    address internal immutable i_ERC721;
    uint256 internal immutable i_bidCD;
    // Cool Down Time

    bool internal s_started;
    // s_ended?
    uint256 internal s_endTimestamp;
    address internal s_highestBidder;
    uint256 internal s_highestBid;
    uint256 internal s_tokenId;

    mapping(address bidder => uint256 totalBiddedEth) s_pendingReturns;

    event AuctionStarted(uint256 indexed tokenId, uint256 indexed endTimestamp);
    event HighestBidincreased(address indexed bidder, uint256 indexed amount);
    event AuctionEnded(address indexed winner, uint256 indexed winningBid);

    // 拍卖由卖家开启
    // 合约接收token，确保拍品在合约的控制内。
    // 未设置拍品
    constructor(
        address _erc721Address,
        uint256 _biddingtime,
        uint256 _bidCD,
        uint256 _startingBid,
        uint256 _tokenId,
        bytes calldata data
    ) {
        // 至少1小时
        require(_biddingtime >= 3600);

        i_seller = msg.sender;
        i_ERC721 = _erc721Address;

        // 拍品给到拍卖平台
        IERC721(i_ERC721).safeTransferFrom(i_seller, address(this), _tokenId, data);

        s_started = true;
        s_endTimestamp = block.timestamp + _biddingtime;
        // bidding time竞标时间

        s_tokenId = _tokenId;
        i_bidCD = _bidCD;

        s_highestBidder = msg.sender;
        s_highestBid = _startingBid;
        // 起拍价

        emit AuctionStarted(_tokenId, s_endTimestamp);
    }

    // 查询
    // function getTokenIdOnAuction() external view returns (uint256) {
    //     return s_tokenIdOnAuction;
    // }

    function bid() external payable {
        if (!s_started) revert NowAuctionsInProgress();
        if (block.timestamp >= s_endTimestamp) revert Error_AuctionEnded();
        if (msg.value <= s_highestBid) revert BidNotHighEnough();
        if(i_bidCD) revert Cooling();

        // 把之前最高竞标者和竞标价存进回款映射
        if (s_highestBid > 0) {
            s_pendingReturns[s_highestBidder] += s_highestBid;
        }

        s_highestBidder = msg.sender;
        s_highestBid = msg.value;
        // s_bids[msg.sender] += msg.value;

        emit HighestBidincreased(msg.sender, msg.value);
    }
    /* 拍卖必须已经开始，且未结束（检查当前时间是否超过结束时间戳）。
    新的出价必须高于当前最高出价。 */

    function getBidCd

    // 撤回出价
    function withdrawBid() external {
        if (msg.sender == s_highestBidder) revert CannotWithdrawHighestBid();

        uint256 amount = s_pendingReturns[msg.sender];
        if (amount == 0) revert NothingToWithdraw();
        delete s_pendingReturns[msg.sender];

        (bool sent,) = msg.sender.call{value: amount}("");
        if (!sent) revert FailedToWithdrawBid(msg.sender, amount);
    }
    // 当前最高出价者不能调用,防止拍卖无效
    // call 是一个推荐的安全发送 ETH 的方法，因为它处理了潜在的 gas 限制问题。

    // 拍卖结束
    function endAuction() public {
        // 拍卖要已经开始, 当前时间超过结束时间
        if (!s_started) revert NowAuctionsInProgress();
        if (block.timestamp < s_endTimestamp) revert TooEarlyToEnd();

        s_started = false;

        IERC721(i_ERC721).safeTransferFrom(address(this), s_highestBidder, s_tokenId, "");

        (bool sent,) = i_seller.call{value: s_highestBid}("");
        if (!sent) revert FailedToSendEth(i_seller, s_highestBid);

        emit AuctionEnded(s_highestBidder, s_highestBid);
        // emit AuctionEnded(s_tokenIdOnAuction, s_fractionalizedAmountOnAuction, s_highestBidder, s_highestBid);
    }

    // 接收NFT 完成
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        external
        returns (bytes4)
    {
        if (msg.sender != address(i_ERC721)) {
            revert OnlyERC721Supported();
        }

        return IERC721Receiver.onERC721Received.selector;
    }

    // 查询是否支持接口  完成
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165) returns (bool) {
        return interfaceId == type(IERC721Receiver).interfaceId || interfaceId == type(IERC165).interfaceId;
    }
}
