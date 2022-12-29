// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@chainlink/contracts/src/v0.8/AutomationCompatible.sol";

contract AssetValidator is
    ChainlinkClient,
    AutomationCompatibleInterface,
    Ownable
{
    event RequestUrl(string url, uint256 time);
    event RequestRes(uint256 time, bytes32 root);
    using Chainlink for Chainlink.Request;

    string private _url = "https://ap-jov.colyseus.dev/chain/get-root";
    uint256 private fee;
    bytes32 private jobId;
    bytes32 public _root;
    // string public root;
    mapping(bytes32 => address) public requestParams;

    // update root internal
    uint256 public immutable interval;
    // last update timestamp
    uint256 public lastTimeStamp;

    constructor(uint256 interval_) {
        interval = interval_;

        setChainlinkToken(0x326C977E6efc84E512bB9C30f76E30c160eD06FB);
        setChainlinkOracle(0x40193c8518BB267228Fc409a613bDbD8eC5a97b3);
        jobId = "7da2702f37fd48e5b1b9a5715e3509b6";

        fee = (1 * LINK_DIVISIBILITY) / 10;
    }

    function fulfill(bytes32 _requestId, bytes32 _val)
        public
        recordChainlinkFulfillment(_requestId)
    {
        _root = _val;
        // root = _val;
        lastTimeStamp = block.timestamp;
        emit RequestRes(block.timestamp, _val);
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


        emit RequestUrl(_url, block.timestamp);

        sendChainlinkRequest(req, fee);
    }

    //
    function verify(
        address user,
        uint256 coinAmount,
        uint256 boxAmount,
        bytes32[] calldata proof
    ) external view returns (bool valid) {
        bytes32 leaf = keccak256(
            abi.encodePacked(user, coinAmount, boxAmount)
        );
        valid = MerkleProof.verify(proof, _root, leaf);
    }

    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(
            link.transfer(msg.sender, link.balanceOf(address(this))),
            "Unable to transfer"
        );
    }

    function fromHexChar(uint8 c) public pure returns (uint8) {
        if (bytes1(c) >= bytes1("0") && bytes1(c) <= bytes1("9")) {
            return c - uint8(bytes1("0"));
        }
        if (bytes1(c) >= bytes1("a") && bytes1(c) <= bytes1("f")) {
            return 10 + c - uint8(bytes1("a"));
        }
        if (bytes1(c) >= bytes1("A") && bytes1(c) <= bytes1("F")) {
            return 10 + c - uint8(bytes1("A"));
        }
        revert("fail");
    }

    // Convert an hexadecimal string to raw bytes
    function fromHexToBytes32(string memory s)
        public
        pure
        returns (bytes32 value)
    {
        bytes memory ss = bytes(s);
        require(ss.length % 2 == 0); // length must be even
        bytes memory r = new bytes(32);
        for (uint256 i = 0; i < 32; ++i) {
            r[i] = bytes1(
                fromHexChar(uint8(ss[2 * i])) *
                    16 +
                    fromHexChar(uint8(ss[2 * i + 1]))
            );
        }

        assembly {
            value := mload(add(r, 32))
        }
    }
}
