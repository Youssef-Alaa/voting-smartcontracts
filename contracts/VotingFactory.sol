// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

import "./Voting.sol";

/// @title Factory Contract for creating voting campaigns
/// @author Youssef Alaa
contract VotingFactory {
    //holds the info of each voting campaign
    struct Campaign { 
        address contractAddress;
		string name;
    	uint timestamp;
	}
    address public owner;
    uint public compaignsNum;
    mapping(uint => Campaign) indexToCampaign;
    
    constructor(){
        owner = msg.sender;
    }
    
    modifier isOwner(){
        require(msg.sender == owner);
        _;
    }

    /// @notice Creates a new voting campaign
    /// @param _name Name of the voting campaign
    /// @param targetVotes Number of votes which when reached the vote process will end
    /// @param _owner Address of the owner of the voting campaign
    function createNewCampaign(string memory _name, uint targetVotes, address _owner) external isOwner() {
        Campaign memory newVoteContract;
		newVoteContract.contractAddress = address(new Voting(targetVotes, _owner));
        newVoteContract.name = _name;
        newVoteContract.timestamp= block.timestamp;
        indexToCampaign[compaignsNum + 1] = newVoteContract;
        compaignsNum++;
    }
    
    /// @notice Get Campaign details by it's Id
    /// @param id Id of the voting campaign
    /// @return Campaign's Id
    /// @return Campaign's contract Address
    /// @return Campaign's Name
    /// @return Campaign's creation timestamp
    function getCampaign(uint id) external view returns(uint, address, string memory, uint) {
        return (id, indexToCampaign[id].contractAddress, indexToCampaign[id].name, indexToCampaign[id].timestamp);
    }
}