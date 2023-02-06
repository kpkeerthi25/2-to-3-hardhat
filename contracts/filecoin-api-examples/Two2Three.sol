pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/Counters.sol";

import { MarketAPI } from "../lib/filecoin-solidity/contracts/v0.8/MarketAPI.sol";
import { CommonTypes } from "../lib/filecoin-solidity/contracts/v0.8/types/CommonTypes.sol";
import { MarketTypes } from "../lib/filecoin-solidity/contracts/v0.8/types/MarketTypes.sol";
import { Actor, HyperActor } from "../lib/filecoin-solidity/contracts/v0.8/utils/Actor.sol";
import { Misc } from "../lib/filecoin-solidity/contracts/v0.8/utils/Misc.sol";

contract Two2Three {

    using Counters for Counters.Counter;
    Counters.Counter private _migrationAdId;

    address public owner;
    address constant CALL_ACTOR_ID = 0xfe00000000000000000000000000000000000005;
    uint64 constant DEFAULT_FLAG = 0x00000000;
    uint64 constant METHOD_SEND = 0;
    

    constructor() {
        owner = msg.sender;
    }

    struct MigrationAd{
        uint adId;
        bytes cid;
        uint size;
        uint reward;
        address creator;
        uint64 providerId;
        string authUrl;
        uint64 dealId;
        bool isRewardClaimed;
    }

    mapping(uint256 => MigrationAd) private idToMigrationAd;

    function createMigrationAd(
        uint size
    ) public payable{
        _migrationAdId.increment();
        uint adId = _migrationAdId.current();
        idToMigrationAd[adId] = MigrationAd(
            adId,
            "",
            size,
            msg.value,
            msg.sender,
            0,
            "",
            0,
            false
        );
    }

    function get_myAds() public view returns (MigrationAd[] memory) {
        uint totalItemCount = _migrationAdId.current();
        uint adCount=0;
        uint currentIndex = 0;
        for(uint i=0; i<totalItemCount; i++) {
          if(idToMigrationAd[i+1].creator == msg.sender) {
            adCount = adCount + 1;
          }
        }
        MigrationAd[] memory items = new MigrationAd[](adCount);
        for (uint i = 0; i < totalItemCount; i++) {
          if (idToMigrationAd[i + 1].creator == msg.sender) {
            uint currentId = i + 1;
            MigrationAd storage currentItem = idToMigrationAd[currentId];
            items[currentIndex] = currentItem;
            currentIndex += 1;
          }
        }
        return items;
    }

    function claim_ad(uint adId, uint64 providerID, string memory url) public{
        require(idToMigrationAd[adId].providerId==0,"ad already in claimed state");
        idToMigrationAd[adId].providerId = providerID;
        idToMigrationAd[adId].authUrl = url;
    }
    function get_ad(uint adId) public view returns (MigrationAd memory){
        return idToMigrationAd[adId];
    }

    function get_dealDetails(uint64 deal_id) public returns (uint64) {
        MarketTypes.GetDealProviderReturn memory providerRet = MarketAPI.getDealProvider(MarketTypes.GetDealProviderParams({id: deal_id}));
        return providerRet.provider;

    }

    function claim_bounty(uint64 deal_id, uint adId) public {
        
        MarketTypes.GetDealDataCommitmentReturn memory commitmentRet = MarketAPI.getDealDataCommitment(MarketTypes.GetDealDataCommitmentParams({id: deal_id}));
        MarketTypes.GetDealProviderReturn memory providerRet = MarketAPI.getDealProvider(MarketTypes.GetDealProviderParams({id: deal_id}));
        bytes memory cidraw = commitmentRet.data;

        // mocking this check since the filecoin specific provider/actorId of the existing deal provider is unknown
        // require(idToMigrationAd[adId].providerId == providerRet.provider, "the deal is not made by the claimed provider");
        
        idToMigrationAd[adId].dealId = deal_id;
        idToMigrationAd[adId].cid = cidraw;

        // send reward to provider 
        send(providerRet.provider,idToMigrationAd[adId].reward);
        idToMigrationAd[adId].isRewardClaimed = true;
    }

    function call_actor_id(uint64 method, uint256 value, uint64 flags, uint64 codec, bytes memory params, uint64 id) public returns (bool, int256, uint64, bytes memory) {
        (bool success, bytes memory data) = address(CALL_ACTOR_ID).delegatecall(abi.encode(method, value, flags, codec, params, id));
        (int256 exit, uint64 return_codec, bytes memory return_value) = abi.decode(data, (int256, uint64, bytes));
        return (success, exit, return_codec, return_value);
    }

    // send reward FIL to the filecoin actor at actor_id
    function send(uint64 actorID, uint reward) internal {
        bytes memory emptyParams = "";
        delete emptyParams;
        HyperActor.call_actor_id(METHOD_SEND, reward, DEFAULT_FLAG, Misc.NONE_CODEC, emptyParams, actorID);

    }

}