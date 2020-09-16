// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

/// @author Youssef Alaa
/// @title Voting contract for managing each voting process
/// @dev This contract is not deployed Initially but is created by VotingFactory
contract Voting{
    //holds the info of each Candidate that will be voted for
    struct Candidate {
        string name;
        string desc;
        uint voteNum;
    }
    //For registring Voters
    struct Voter {
        bool exists;
        bool abstains;
        bool voted;
    	uint timestamp;
    }

    enum Stage { Init, Vote, Finished }
    Stage public stage;
    // uint public targetTotalVotes;
    uint public votesNum;
    uint public votersNum;
    uint public abstainersNum;
    uint public endTime;
    address public owner;
    bool public thresholdVote;
    Candidate[] candidates;
    mapping(address => Voter) public voterToDetails;

    constructor(address _owner, uint _endTime, bool _thresholdVote) {
        require(_endTime > block.timestamp, "Vote end time can not be in the past");
        owner = _owner;
        stage = Stage.Init;
        endTime = _endTime;
        thresholdVote = _thresholdVote;
    }

    modifier validStage(Stage reqStage) {
        require(stage == reqStage, "Not valid in current stage");
        _;
    }
    modifier isOwner() {
        require(msg.sender == owner , "is not owner");
        _;
    }
    modifier isVoter(address newVoter) {
        require(!voterToDetails[newVoter].voted && voterToDetails[newVoter].exists, "voter does not exist or have voted before");
        _;
    }

    /// @notice Add a new candidate to be voted for
    /// @dev Function should be called by owner and before the voting process starts
    /// @param _name Name of Candidate
    /// @param _desc Candidate's Description
    function addCandidate(string memory _name, string memory _desc) external isOwner() validStage(Stage.Init) {
        Candidate memory _candidate;
        _candidate.name = _name;
        _candidate.desc = _desc;
        candidates.push(_candidate);
    }

    /// @notice Give a certain address the right to vote
    /// @dev Function should be called by owner and before the voting process starts
    /// @param voter address of the user to be allowed
    function addVoter(address voter) external isOwner() {
        require(!voterToDetails[voter].exists, "voter already exists");
        voterToDetails[voter].exists = true;
        votersNum ++;
    }

    /// @notice Edit candidate's name and description
    /// @dev Function should be called by owner and before the voting process starts
    /// @param id ID of existing Candidate
    /// @param _name Changed name of Candidate
    /// @param _desc Changed candidate's description
    function editCandidate(uint id,string memory _name, string memory _desc) external isOwner() validStage(Stage.Init) {
        candidates[id].name = _name;
        candidates[id].desc = _desc;
    }

    /// @notice Delete candidate by Id
    /// @dev Function should be called by owner and before the voting process starts
    /// @param id ID of existing Candidate
    function deleteCandidate(uint id) external isOwner() validStage(Stage.Init) {
        delete(candidates[id]);
    }

    /// @notice Finish voting process
    /// @dev Function should be called by owner and while voting is stopped
    function finishVoting() external isOwner() {
        require(block.timestamp > endTime, "voting time is not finished yet");
        stage = Stage.Finished;
    }

    /// @notice Allow voters to start voting
    /// @dev Function should be called by owner and while voting is stopped
    function startVoting() external isOwner() validStage(Stage.Init) {
        stage = Stage.Vote;
    }

    /// @notice Vote for a candidate
    /** @dev Function should be called after the voting process has started and by a registered voter */
    /// @param id ID of existing Candidate
    function vote(uint id) external validStage(Stage.Vote) isVoter(msg.sender) {
        candidates[id].voteNum ++;
        //checks if the voter abstained before;
        if(voterToDetails[msg.sender].abstains) {
            abstainersNum --;
        }
        // add new voter
        Voter memory _voter;
        _voter.exists = true;
        _voter.abstains = false;
        _voter.voted = true;
        _voter.timestamp = block.timestamp;
        voterToDetails[msg.sender] = _voter;
        // increment voternum
        votesNum ++;
        // finish vote if votes for one candidate is > (VoterNum - VoteAbstain)/2 in a threshold Voting process
        // * 100 is addded to workaround solidity's inability to deal with floats
        if (thresholdVote && (candidates[id].voteNum * 100) > (((votersNum - abstainersNum) * 100)/2)) {
            stage = Stage.Finished;
        }
    }

    /// @notice Abstain from this vote
    /** @dev Function should be called after the voting process has started and by a registered voter */
    function abstain() external validStage(Stage.Vote) isVoter(msg.sender) {
        voterToDetails[msg.sender].abstains = true;
        abstainersNum ++;
        require(reachedThreshold(), "could not count reached threshold");
    }

    /// @notice Get Candidate details by it's Id
    /** @dev When called in voting phase it will exclude the number of votes for that candidate returning 0,
        The real number will be returned when called after voting ends */
    /// @param id Id of the Candidate
    /// @return Candidate's ID
    /// @return Candidate's name
    /// @return Candidate's description
    /// @return Candidate's votes number
    function getCandidate(uint id) external view returns(uint, string memory, string memory, uint) {
        if (stage == Stage.Finished) {
            return(id, candidates[id].name, candidates[id].desc, candidates[id].voteNum);
        } else {
            return(id, candidates[id].name, candidates[id].desc, 0);
        }
    }

    /// @notice Get Candidates number
    /// @return Return the number of registered candidates
    function candidatesNum() external view returns(uint) {
       return(candidates.length);
    }

    /// @return Return id of the winning Candidate
    /// @return Return name of the winning Candidate
    /// @return Return description of the winning Candidate
    /// @return Return Number of votes for the winning Candidate
    function getWinningCandidate() external view validStage(Stage.Finished) returns(uint, string memory, string memory, uint) {
        (uint highestCandidate, uint winningVoteNum) = getHighestCandidate();
        return(highestCandidate, candidates[highestCandidate].name, candidates[highestCandidate].desc, winningVoteNum);
    }

    function reachedThreshold() internal returns(bool) {
        if(thresholdVote) {
            ( , uint winningVoteNum) = getHighestCandidate();
            if((winningVoteNum * 100) > (((votersNum - abstainersNum) * 100)/2)) {
                stage = Stage.Finished;
            }
        }
        return true;
    }

    function getHighestCandidate() internal view returns (uint highestCandidate, uint winningVoteNum) {
        for (uint128 p = 0; p < candidates.length; p++) {
            if (candidates[p].voteNum > winningVoteNum) {
                winningVoteNum = candidates[p].voteNum;
                highestCandidate = p;
            }
        }
        require(winningVoteNum > 0);
    }
}