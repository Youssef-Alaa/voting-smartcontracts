// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

contract Voting{
    struct Candidate{
        bool exists;
        string name;
        string desc;
        uint voteNum;
    }
    struct Voter {
        uint id ;
    	uint timestamp;
    }
    
    uint public TargetTotalVotes;
    uint public votesNum;
    uint public candidatesNum;
    address public owner;
    bool public isVoteStarted;
    
    mapping(uint => Candidate) candidates;
    mapping(address => Voter) voterToDetails;

    constructor(uint _targetVotes , address _owner) {
        TargetTotalVotes = _targetVotes;
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
        require(TargetTotalVotes > votesNum, "Target Total Votes has been reached");
        _;
    }
    modifier isCandidate(uint id){
        require(candidates[id].exists, "Candidate does not exist");
        _;
    }
    
    function addCandidate(string memory _name, string memory _desc) external isOwner() voteInit() {
        Candidate memory _candidate;
        _candidate.exists = true;
        _candidate.name = _name;
        _candidate.desc = _desc;
        candidates[candidatesNum + 1] = _candidate;
        candidatesNum ++;
    }
    
    function editCandidate(uint id,string memory _name, string memory _desc) external isOwner() voteInit() isCandidate(id) {
        candidates[id].name = _name;
        candidates[id].desc = _desc;
    }
    
    function deleteCandidate(uint id) external isOwner() voteInit() isCandidate(id) {
        delete(candidates[id]);
        candidatesNum --;
    }
    
    function startVoting() external isOwner() voteStoped() {
        isVoteStarted = true;
    }
    
    function stopVoting() external isOwner() voteStarted() {
        isVoteStarted = false;
    }
    
    // vote for candidates
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
    
    // get candidate 
    function getCandidate(uint id) external view isCandidate(id) returns(uint, string memory, string memory, uint) {
        return(id, candidates[id].name, candidates[id].desc, candidates[id].voteNum);
    }
  
    // get voter 
    function getVoter(address _voter) external view returns (address, uint, uint)  {
        return(_voter, voterToDetails[_voter].id, voterToDetails[_voter].timestamp);
    }
}