// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

import "./Voting.sol";

contract VotingFactory {
    struct Info { 
        address contractAddress;
		string name;
    	uint timestamp;
	}
    address public owner;
    uint public compaignsNum;
    mapping(uint => Info) indexToCampaign;
    
    constructor(){
        owner = msg.sender;
    }
    
    modifier isOwner(){
        require(msg.sender == owner);
        _;
    }
    
    function createNewCampaign(string memory _name, uint targetVotes) external isOwner() {
        Info memory newVoteContract;
		newVoteContract.contractAddress = address(new Voting(targetVotes, owner));
        newVoteContract.name = _name;
        newVoteContract.timestamp= block.timestamp;
        indexToCampaign[compaignsNum + 1] = newVoteContract;
        compaignsNum++;
    }
    
    function getCampaign(uint id) external view returns(uint, address, string memory, uint) {
        return (id, indexToCampaign[id].contractAddress, indexToCampaign[id].name, indexToCampaign[id].timestamp);
    }
}