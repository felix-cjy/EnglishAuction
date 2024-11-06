```bash
$ forge test --gas-report

$ forge test --gas-report
[⠆] Compiling...
No files changed, compilation skipped

Ran 10 tests for test/Auction.t.sol:AuctionTest
[PASS] testFail_BidTooLow() (gas: 50065)
[PASS] testFail_HighestBidderWithdraw() (gas: 103658)
[PASS] testFail_NonSellerCancel() (gas: 31597)
[PASS] test_BasicBid() (gas: 74344)
[PASS] test_CancelAuction() (gas: 74457)
[PASS] test_EndAuction() (gas: 155706)
[PASS] test_EndAuctionWithNoBids() (gas: 83986)
[PASS] test_InitialState() (gas: 33040)
[PASS] test_MultipleBids() (gas: 145308)
[PASS] test_WithdrawBid() (gas: 169765)
Suite result: ok. 10 passed; 0 failed; 0 skipped; finished in 7.80ms (26.98ms CPU time)
| src/Auction.sol:Auction contract |                 |       |        |       |         |
|----------------------------------|-----------------|-------|--------|-------|---------|
| Deployment Cost                  | Deployment Size |       |        |       |         |
| 922852                           | 4587            |       |        |       |         |
| Function Name                    | min             | avg   | median | max   | # calls |
| bid                              | 32958           | 55481 | 57158  | 62551 | 8       |
| cancelAuction                    | 21334           | 42642 | 42642  | 63950 | 2       |
| endAuction                       | 76216           | 81040 | 81040  | 85865 | 2       |
| i_ERC721                         | 239             | 239   | 239    | 239   | 1       |
| i_seller                         | 260             | 260   | 260    | 260   | 1       |
| i_tokenId                        | 262             | 262   | 262    | 262   | 1       |
| s_bids                           | 565             | 565   | 565    | 565   | 2       |
| s_ended                          | 377             | 377   | 377    | 377   | 4       |
| s_highestBid                     | 383             | 1049  | 383    | 2383  | 3       |
| s_highestBidder                  | 426             | 1092  | 426    | 2426  | 3       |
| s_started                        | 2388            | 2388  | 2388   | 2388  | 1       |
| startAuction                     | 86116           | 86116 | 86116  | 86116 | 10      |
| withdrawBid                      | 28487           | 30771 | 30771  | 33055 | 2       |


| test/mocks/MockERC721.sol:MockERC721 contract |                 |       |        |       |        |
|-----------------------------------------------|-----------------|-------|--------|-------|--------|
| Deployment Cost                               | Deployment Size |       |        |       |        |
| 966333                                        | 4872            |       |        |       |        |
| Function Name                                 | min             | avg   | median | max   |
# calls |
| approve                                       | 48624           | 48624 | 48624  | 48624 |10      |
| mint                                          | 68767           | 68767 | 68767  | 68767 |10      |
| ownerOf                                       | 576             | 1076  | 576    | 2576  |4       |




Ran 1 test suite in 29.80ms (7.80ms CPU time): 10 tests passed, 0 failed, 0 skipped (10 total tests)

```
