// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import '@chainlink/contracts/src/v0.8/ChainlinkClient.sol';
import '@chainlink/contracts/src/v0.8/ConfirmedOwner.sol';
import '@openzeppelin/contracts/utils/Strings.sol';

error AlreadyInitialized();
error RangeOutOfBounds();

contract VrfMint is ERC721URIStorage, VRFConsumerBaseV2, Ownable,ChainlinkClient {

    
    // Types
    enum Breed {
        PTEROPHYLLUM_SCALARE,
        SIAMESE_FIGHTING_FISH,
        RAINBOW_TROUT,
        SEMICOSSYPHUS_PULCHER,
        DEEP_SEA_LANTERNFISH,
        SWORDFISH,
        GREAT_WHITE_SHARK,
        GOLDEN_SEA_EEL,
        NEPHROPS_NORVEGICUS,
        GREEN_SEA_TURTLE
    }

    // Chainlink VRF Variables
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    uint64 private immutable i_subscriptionId;
    bytes32 private i_gasLane = 0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f;
    uint32 private i_callbackGasLimit = 2500000;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    // NFT Variables
    uint256 private s_tokenCounter;
    mapping(uint256 => Breed) private s_tokenIdToBreed;
    uint256 internal constant MAX_CHANCE_VALUE = 100;
    string[] internal s_fishTokenUris;
    bool private s_initialized;


    // any api
    using Chainlink for Chainlink.Request;

    uint256 public volume;
    // string public btc;
    // string public usd;

    bytes32 private jobId;
    uint256 private fee;

    event RequestAmount(bytes32 indexed requestId, uint256 amount);
    event RequestUrl(string url,address requester);

    mapping(address => uint32) public canMintAmount;
    mapping(bytes32 => address) public requestParams;


    // VRF Helpers
    mapping(uint256 => address) public s_requestIdToSender;

    // Events
    event NftRequested(uint256 indexed requestId, address requester);
    event NftMinted(Breed breed, address minter);


    

    constructor(
        address vrfCoordinatorV2,
        uint64 subscriptionId,
        string[10] memory fishTokenUris
    ) VRFConsumerBaseV2(vrfCoordinatorV2) ERC721("Piexel Flying fish", "PFF")  {
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_subscriptionId = subscriptionId;
        _initializeContract(fishTokenUris);
        s_tokenCounter = 0;

        // any api
        setChainlinkToken(0x326C977E6efc84E512bB9C30f76E30c160eD06FB);
        setChainlinkOracle(0x40193c8518BB267228Fc409a613bDbD8eC5a97b3);
        jobId = 'ca98366cc7314957b8c012c72f05aeeb';
        fee = (1 * LINK_DIVISIBILITY) / 10;
    }


    function mintAll() public returns (bytes32 requestId) {
        Chainlink.Request memory req = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);


        uint256 value = uint160(msg.sender);
        bytes memory allBytes = bytes(Strings.toHexString(value, 20));

        string memory newString = string(allBytes);

        string memory url=string(abi.encodePacked('https://ap-jov.colyseus.dev/chain/can-mint-amount?',newString));

        // Set the URL to perform the GET request on
        req.add('get', url);


        req.add('path', 'message,canMint'); // Chainlink nodes 1.0.0 and later support this format

        // Multiply the result by 1000000000000000000 to remove decimals
        int256 timesAmount = 1;
        req.addInt('times', timesAmount);

        emit RequestUrl(url,msg.sender);

        // Sends the request
        // return sendChainlinkRequest(req, fee);

         requestId=sendChainlinkRequest(req, fee);
        requestParams[requestId]=msg.sender;

    }

    function fulfill(bytes32 _requestId, uint256 _volume) public recordChainlinkFulfillment(_requestId) {
        emit RequestAmount(_requestId, _volume);
        // volume = _volume;
        address requester=requestParams[_requestId];
        uint32 _amount = uint32(_volume);
        canMintAmount[requester]=_amount;

        // _mint(_amount);
    }

    function _mint() public returns (uint256 requestId) {
        uint32 _amount=canMintAmount[msg.sender];

       
        requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            _amount
        );

        s_requestIdToSender[requestId] = msg.sender;
        emit NftRequested(requestId, msg.sender);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        address fishOwner = s_requestIdToSender[requestId];

        for (uint i = 0; i <= randomWords.length; i++) {
            uint256 newItemId = s_tokenCounter;
            s_tokenCounter = s_tokenCounter + 1;
            uint256 moddedRng = randomWords[i] % MAX_CHANCE_VALUE;
            Breed dogBreed = getBreedFromModdedRng(moddedRng);
            _safeMint(fishOwner, newItemId);
            _setTokenURI(newItemId, s_fishTokenUris[uint256(dogBreed)]);
            emit NftMinted(dogBreed, fishOwner);
        }
    }

    function getChanceArray() public pure returns (uint256[10] memory) {
        return [10,20,30,40,50,55,70,80,90, MAX_CHANCE_VALUE];
    }

    function _initializeContract(string[10] memory fishTokenUris) private {
        if (s_initialized) {
            revert AlreadyInitialized();
        }
        s_fishTokenUris = fishTokenUris;
        s_initialized = true;
    }

    function getBreedFromModdedRng(uint256 moddedRng) public pure returns (Breed) {
        uint256 cumulativeSum = 0;
        uint256[10] memory chanceArray = getChanceArray();
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

    

   

    function getfishTokenUris(uint256 index) public view returns (string memory) {
        return s_fishTokenUris[index];
    }

    function getInitialized() public view returns (bool) {
        return s_initialized;
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }

    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(link.transfer(msg.sender, link.balanceOf(address(this))), 'Unable to transfer');
    }
}