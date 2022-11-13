// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

error AlreadyInitialized();
error RangeOutOfBounds();

contract VrfMint is ERC721URIStorage, VRFConsumerBaseV2, Ownable {

    
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

    // VRF Helpers
    mapping(uint256 => address) public s_requestIdToSender;

    // Events
    event NftRequested(uint256 indexed requestId, address requester);
    event NftMinted(Breed breed, address minter);

    constructor(
        address vrfCoordinatorV2,
        uint64 subscriptionId,
        string[10] memory fishTokenUris
    ) VRFConsumerBaseV2(vrfCoordinatorV2) ERC721("Piexel Flying fish", "PFF") {
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_subscriptionId = subscriptionId;
        _initializeContract(fishTokenUris);
    }

    function mint() public returns (uint256 requestId) {
       
        requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );

        s_requestIdToSender[requestId] = msg.sender;
        emit NftRequested(requestId, msg.sender);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        address fishOwner = s_requestIdToSender[requestId];
        uint256 newItemId = s_tokenCounter;
        s_tokenCounter = s_tokenCounter + 1;
        uint256 moddedRng = randomWords[0] % MAX_CHANCE_VALUE;
        Breed dogBreed = getBreedFromModdedRng(moddedRng);
        _safeMint(fishOwner, newItemId);
        _setTokenURI(newItemId, s_fishTokenUris[uint256(dogBreed)]);
        emit NftMinted(dogBreed, fishOwner);
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
}