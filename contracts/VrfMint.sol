// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

error AlreadyInitialized();
error RangeOutOfBounds();

contract VrfMint is
    ERC721URIStorage,
    VRFConsumerBaseV2,
    Ownable,
    ChainlinkClient
{
    // Types
    enum Breed {
        HEAD_1,
        HEAD_2,
        HEAD_3,
        HEAD_4,
        HAND_1,
        HAND_2,
        HAND_3,
        HAND_4,
        BODY_1,
        BODY_2,
        BODY_3,
        BODY_4,
        FOOT_1,
        FOOT_2,
        FOOT_3,
        FOOT_4,
        HEAD_5,
        HAND_5,
        BODY_5,
        FOOT_5
    }

    // Chainlink VRF Variables
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    uint64 private immutable i_subscriptionId;
    bytes32 private i_gasLane =
        0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f;
    uint32 private i_callbackGasLimit = 2500000;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    // NFT Variables
    uint256 private s_tokenCounter;
    mapping(uint256 => Breed) private s_tokenIdToBreed;
    uint256 internal constant MAX_CHANCE_VALUE = 100;
    string[] internal s_hackmonTokenUris;
    bool private s_initialized;

    // any api
    using Chainlink for Chainlink.Request;

    uint256 public val;
    bytes32 private jobId;
    uint256 private fee;

    mapping(address => uint32) public canMintAmount;
    mapping(bytes32 => address) public requestParams;
    mapping(uint256 => address) public s_requestIdToSender;

    // Events
    event AmountMint(address minter, uint32 amount);
    event NftRequested(uint256 indexed requestId, address requester);
    event NftMinted(Breed breed, address minter);

    event RequestAmount(bytes32 indexed requestId, uint256 amount);
    event RequestUrl(string url, address requester);

    constructor(
        address vrfCoordinatorV2,
        uint64 subscriptionId,
        string[20] memory hackmonTokenUris
    ) VRFConsumerBaseV2(vrfCoordinatorV2) ERC721("HackMon", "HACK") {
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_subscriptionId = subscriptionId;
        _initializeContract(hackmonTokenUris);
        s_tokenCounter = 0;

        // any api
        setChainlinkToken(0x326C977E6efc84E512bB9C30f76E30c160eD06FB);
        setChainlinkOracle(0x40193c8518BB267228Fc409a613bDbD8eC5a97b3);
        jobId = "ca98366cc7314957b8c012c72f05aeeb";
        fee = (1 * LINK_DIVISIBILITY) / 10;
    }

    function getAmount() public returns (bytes32 requestId) {
        Chainlink.Request memory req = buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfill.selector
        );

        uint256 value = uint160(msg.sender);
        bytes memory allBytes = bytes(Strings.toHexString(value, 20));

        string memory newString = string(allBytes);

        string memory url = string(
            abi.encodePacked(
                "https://ap-jov.colyseus.dev/chain/can-mint-amount?",
                newString
            )
        );

        req.add("get", url);

        req.add("path", "message,canMint");

        int256 timesAmount = 1;
        req.addInt("times", timesAmount);

        emit RequestUrl(url, msg.sender);

        requestId = sendChainlinkRequest(req, fee);
        requestParams[requestId] = msg.sender;
    }

    function fulfill(bytes32 _requestId, uint256 _val)
        public
        recordChainlinkFulfillment(_requestId)
    {
        emit RequestAmount(_requestId, _val);
        address requester = requestParams[_requestId];
        uint32 _amount = uint32(_val);
        canMintAmount[requester] = _amount;
    }

    function mint() public returns (uint256 requestId) {
        uint32 _amount = canMintAmount[msg.sender];

        requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            _amount
        );

        s_requestIdToSender[requestId] = msg.sender;
        emit NftRequested(requestId, msg.sender);

        canMintAmount[msg.sender] = 0;
        emit AmountMint(msg.sender, _amount);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {
        address fishOwner = s_requestIdToSender[requestId];

        for (uint i = 0; i < randomWords.length; i++) {
            uint256 newItemId = s_tokenCounter;
            s_tokenCounter = s_tokenCounter + 1;
            uint256 moddedRng = randomWords[i] % MAX_CHANCE_VALUE;
            Breed dogBreed = getBreedFromModdedRng(moddedRng);
            _safeMint(fishOwner, newItemId);
            _setTokenURI(newItemId, s_hackmonTokenUris[uint256(dogBreed)]);
            emit NftMinted(dogBreed, fishOwner);
        }
    }

    function getChanceArray() public pure returns (uint256[20] memory) {
        return [
            10,
            18,
            22,
            24,
            34,
            42,
            46,
            48,
            58,
            66,
            70,
            72,
            82,
            90,
            94,
            96,
            97,
            98,
            99,
            MAX_CHANCE_VALUE
        ];
    }

    function _initializeContract(string[20] memory hackmonTokenUris) private {
        if (s_initialized) {
            revert AlreadyInitialized();
        }
        s_hackmonTokenUris = hackmonTokenUris;
        s_initialized = true;
    }

    function getBreedFromModdedRng(uint256 moddedRng)
        public
        pure
        returns (Breed)
    {
        uint256 cumulativeSum = 0;
        uint256[20] memory chanceArray = getChanceArray();
        for (uint256 i = 0; i < chanceArray.length; i++) {
            // if (moddedRng >= cumulativeSum && moddedRng < cumulativeSum + chanceArray[i]) {
            if (moddedRng >= cumulativeSum && moddedRng < chanceArray[i]) {
                return Breed(i);
            }
            // cumulativeSum = cumulativeSum + chanceArray[i];
            cumulativeSum = chanceArray[i];
        }
        revert RangeOutOfBounds();
    }

    function gethackmonTokenUris(uint256 index)
        public
        view
        returns (string memory)
    {
        return s_hackmonTokenUris[index];
    }

    function getInitialized() public view returns (bool) {
        return s_initialized;
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }

    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(
            link.transfer(msg.sender, link.balanceOf(address(this))),
            "Unable to transfer"
        );
    }
}
