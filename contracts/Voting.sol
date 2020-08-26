// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

/// @author Youssef Alaa
/// @title Voting contract for managing each voting process
/// @dev This contract is not deployed Initially but is created by VotingFactory
contract Voting{
    //holds the info of each Candidate that will be voted for
    struct Candidate{
        bool exists;
        string name;
        string desc;
        uint voteNum;
    }
    //For registring Votes
    struct Voter {
        uint id;
    	uint timestamp;
    }
    
    uint public targetTotalVotes;
    uint public votesNum;
    uint public candidatesNum;
    address public owner;
    bool public isVoteStarted;
    
    mapping(uint => Candidate) candidates;
    mapping(address => Voter) voterToDetails;

    constructor(uint _targetVotes, address _owner) {
        targetTotalVotes = _targetVotes;
        owner = _owner;
    }
    
    modifier isOwner(){
        require(msg.sender == owner , "is not owner");
        _;
    }
    modifier voteStarted(){
        require(isVoteStarted, "vote is not in progress");
        _;  
    }
    modifier voteStoped(){
        require(!isVoteStarted, "vote is in progress");
        _;
    }
    modifier voteInit(){
        require(!isVoteStarted && votesNum == 0);
        _;
    }
    modifier isNewVoter(address newVoter){
        require(voterToDetails[newVoter].id == 0, "you have vote before");
        _;
    }
    modifier isVoteNotComplete(){
        require(targetTotalVotes > votesNum, "Target Total Votes has been reached");
        _;
    }
    modifier isCandidate(uint id){
        require(candidates[id].exists, "Candidate does not exist");
        _;
    }
    
    /// @notice Add a new candidate to be voted for
    /// @dev Function should be called by owner and before the voting process starts
    /// @param _name Name of Candidate
    /// @param _desc Candidate's Description
    function addCandidate(string memory _name, string memory _desc) external isOwner() voteInit() {
        Candidate memory _candidate;
        _candidate.exists = true;
        _candidate.name = _name;
        _candidate.desc = _desc;
        candidates[candidatesNum + 1] = _candidate;
        candidatesNum ++;
    }
    
    /// @notice Edit candidate's name and description
    /// @dev Function should be called by owner and before the voting process starts
    /// @param id ID of existing Candidate
    /// @param _name Changed name of Candidate
    /// @param _desc Changed candidate's description
    function editCandidate(uint id,string memory _name, string memory _desc) external isOwner() voteInit() isCandidate(id) {
        candidates[id].name = _name;
        candidates[id].desc = _desc;
    }
    
    /// @notice Delete candidate by Id
    /// @dev Function should be called by owner and before the voting process starts
    /// @param id ID of existing Candidate
    function deleteCandidate(uint id) external isOwner() voteInit() isCandidate(id) {
        delete(candidates[id]);
        candidatesNum --;
    }
    
    /// @notice Allow voters to start voting
    /// @dev Function should be called by owner and while voting is stopped
    function startVoting() external isOwner() voteStoped() {
        isVoteStarted = true;
    }
    
    /// @notice Stops the voting process
    /// @dev Function should be called by owner and while voting has started
    function stopVoting() external isOwner() voteStarted() {
        isVoteStarted = false;
    }
    
    /// @notice Vote for a candidate
    /** @dev Function should be called after the voting process has started, targetTotalVotes has not been reached,
    The voter hasn't voted before and is voting to an existing candidate */
    /// @param id ID of existing Candidate
    function vote(uint id) external voteStarted() isVoteNotComplete() isNewVoter(msg.sender) isCandidate(id) {
        candidates[id].voteNum ++;
        // add new voter
        Voter memory _voter;
        _voter.id = votesNum + 1;
        _voter.timestamp = block.timestamp;
        voterToDetails[msg.sender] = _voter;
        // increment voternum
        votesNum ++;
    }
    
    /// @notice Get Candidate details by it's Id
    /// @param id Id of the Candidate
    /// @return Candidate's ID
    /// @return Candidate's name
    /// @return Candidate's description
    /// @return Number of votes that has been voted for this candidate.
    function getCandidate(uint id) external view isCandidate(id) returns(uint, string memory, string memory, uint) {
        return(id, candidates[id].name, candidates[id].desc, candidates[id].voteNum);
    }
    
    /// @notice Get voter's info by his address
    /// @param _voter Voter's address
    /// @return Voter's address
    /// @return Voter's id, 0 = hasn't voted, 1 = has voted
    /// @return Timestamp of when he has voted if he has already voted
    function getVoter(address _voter) external view returns (address, uint, uint)  {
        return(_voter, voterToDetails[_voter].id, voterToDetails[_voter].timestamp);
    }
}