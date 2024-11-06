// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {Auction} from "../src/Auction.sol";
import {MockERC721} from "./mocks/MockERC721.sol";

contract AuctionTest is Test {
    Auction public auction;
    MockERC721 public nft;

    address seller;
    address bidder1;
    address bidder2;

    uint256 constant TOKEN_ID = 1;
    uint256 constant STARTING_BID = 1 ether;
    uint256 constant BIDDING_TIME = 2 hours;
    uint256 constant MIN_BID_INCREMENT = 0.1 ether;

    function setUp() public {
        // 1. 创建基础账户
        seller = makeAddr("seller");
        bidder1 = makeAddr("bidder1");
        bidder2 = makeAddr("bidder2");
        vm.deal(bidder1, 10 ether);
        vm.deal(bidder2, 10 ether);

        // 2. 部署NFT合约并铸造
        nft = new MockERC721("TestNFT", "TNFT");
        vm.startPrank(seller);
        nft.mint(seller, TOKEN_ID);

        // 3. 部署拍卖合约
        auction = new Auction(address(nft), TOKEN_ID, STARTING_BID, BIDDING_TIME, MIN_BID_INCREMENT, "");

        // 4. 授权并开始拍卖
        nft.approve(address(auction), TOKEN_ID);
        auction.startAuction();
        vm.stopPrank();
    }

    // 部署状态测试
    function test_InitialState() public view {
        assertEq(auction.i_seller(), seller);
        assertEq(auction.i_ERC721(), address(nft));
        assertEq(auction.i_tokenId(), TOKEN_ID);
        assertEq(auction.s_highestBid(), STARTING_BID);
        assertEq(auction.s_highestBidder(), address(0));
        assertTrue(auction.s_started());
        assertFalse(auction.s_ended());
        assertEq(nft.ownerOf(TOKEN_ID), address(auction));
    }

    // 出价相关测试
    function test_BasicBid() public {
        uint256 bidAmount = 2 ether;
        vm.prank(bidder1);
        auction.bid{value: bidAmount}();

        assertEq(auction.s_highestBidder(), bidder1);
        assertEq(auction.s_highestBid(), bidAmount);
    }

    function testFail_BidTooLow() public {
        uint256 bidAmount = STARTING_BID + MIN_BID_INCREMENT - 1;
        vm.prank(bidder1);
        auction.bid{value: bidAmount}();
    }

    function test_MultipleBids() public {
        // 第一次出价
        vm.prank(bidder1);
        auction.bid{value: 2 ether}();

        // 第二次出价
        vm.prank(bidder2);
        auction.bid{value: 3 ether}();

        assertEq(auction.s_highestBidder(), bidder2);
        assertEq(auction.s_highestBid(), 3 ether);
        assertEq(auction.s_bids(bidder1), 2 ether);
    }

    // 拍卖结束测试
    function test_EndAuction() public {
        // 出价
        vm.prank(bidder1);
        auction.bid{value: 2 ether}();

        // 时间前进到结束
        vm.warp(block.timestamp + BIDDING_TIME + 1);

        // 结束拍卖
        auction.endAuction();

        assertTrue(auction.s_ended());
        assertEq(nft.ownerOf(TOKEN_ID), bidder1);
    }

    function test_EndAuctionWithNoBids() public {
        vm.warp(block.timestamp + BIDDING_TIME + 1);
        auction.endAuction();

        assertTrue(auction.s_ended());
        assertEq(nft.ownerOf(TOKEN_ID), seller);
    }

    // 取消拍卖测试
    function test_CancelAuction() public {
        vm.prank(seller);
        auction.cancelAuction();

        assertTrue(auction.s_ended());
        assertEq(nft.ownerOf(TOKEN_ID), seller);
    }

    function testFail_NonSellerCancel() public {
        vm.prank(bidder1);
        auction.cancelAuction();
    }

    // 提取出价测试
    function test_WithdrawBid() public {
        // 第一个出价
        vm.prank(bidder1);
        auction.bid{value: 2 ether}();

        // 第二个更高的出价
        vm.prank(bidder2);
        auction.bid{value: 3 ether}();

        // 第一个出价者提取
        uint256 balanceBefore = bidder1.balance;
        vm.prank(bidder1);
        auction.withdrawBid();

        assertEq(bidder1.balance, balanceBefore + 2 ether);
        assertEq(auction.s_bids(bidder1), 0);
    }

    function testFail_HighestBidderWithdraw() public {
        vm.prank(bidder1);
        auction.bid{value: 2 ether}();

        vm.prank(bidder1);
        auction.withdrawBid();
    }
}
