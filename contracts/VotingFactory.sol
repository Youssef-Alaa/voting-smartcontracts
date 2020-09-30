// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

import "./Voting.sol";

/// @title Factory Contract for creating voting campaigns
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
    /// @param endTime Date in unix time when the vote will end
    /// @param _owner Address of the owner of the voting campaign
    /// @param thresholdVote bool true=threshold vote, false= not a threshold vote
    function createNewCampaign(string memory _name, uint endTime, address _owner, bool thresholdVote) external isOwner() {
        Campaign memory newVoteContract;
		newVoteContract.contractAddress = address(new Voting(_owner, endTime, thresholdVote));
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