// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@chainlink/contracts/src/v0.8/AutomationCompatible.sol";

contract AssetValidator is ChainlinkClient, AutomationCompatibleInterface {
    event RequestUrl(string url, uint256 time);
    event RequestRes(uint256 time,bytes32 root);
    using Chainlink for Chainlink.Request;

    string private _url = "https://ap-jov.colyseus.dev/chain/get-root";
    uint256 private fee;
    bytes32 private jobId;
    bytes32 public root;
    mapping(bytes32 => address) public requestParams;

    // update root internal
    uint256 public immutable interval;
    // last update timestamp
    uint256 public lastTimeStamp;

    constructor(uint256 interval_) {
        interval = interval_;

        setChainlinkToken(0x326C977E6efc84E512bB9C30f76E30c160eD06FB);
        setChainlinkOracle(0x40193c8518BB267228Fc409a613bDbD8eC5a97b3);
        jobId = "ca98366cc7314957b8c012c72f05aeeb";

        fee = (1 * LINK_DIVISIBILITY) / 10;
    }

    function fulfill(bytes32 _requestId, bytes32 _val)
        public
        recordChainlinkFulfillment(_requestId)
    {
        root = _val;
        lastTimeStamp = block.timestamp;
        emit RequestRes(block.timestamp,_val);

    }

    function checkUpkeep(
        bytes calldata /* checkData */
    )
        external
        view
        override
        returns (
            bool upkeepNeeded,
            bytes memory /* performData */
        )
    {
        upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;
        // We don't use the checkData in this example. The checkData is defined when the Upkeep was registered.
    }

    // any api
    function performUpkeep(
        bytes calldata /* performData */
    ) public override {
        Chainlink.Request memory req = buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfill.selector
        );

        req.add("get", _url);

        req.add("path", "root");

        int256 timesAmount = 1;
        req.addInt("times", timesAmount);

        emit RequestUrl(_url, block.timestamp);

       sendChainlinkRequest(req, fee);
    }

    //
    function verify(
        uint256 coinAmount,
        uint256 boxAmount,
        bytes32[] calldata proof
    ) external view returns (bool valid) {
        bytes32 leaf = keccak256(
            abi.encodePacked(msg.sender, coinAmount, boxAmount)
        );
        valid = MerkleProof.verify(proof, root, leaf);
    }
}
