const BigNumber = web3.BigNumber;

require('chai')
  .use(require('chai-bignumber')(BigNumber))
  .should();
const {
  shouldFail,
  BN,
  constants,
  expectEvent
} = require('@openzeppelin/test-helpers');
const truffleAssert = require('truffle-assertions');

const { ZERO_ADDRESS } = constants;

function capitalize(str) {
  return str.replace(/\b\w/g, l => l.toUpperCase());
}
const _Voting = artifacts.require('Voting');
const _VotingFactory = artifacts.require('VotingFactory');

contract('VotingFactory', accounts => {
  /* create named accounts for contract roles */
  const creatorAddress = accounts[0];
  const user1 = accounts[1];
  const user2 = accounts[2];
  const campaignOwner = accounts[3];
  const unprivilegedAddress = accounts[4];
  
  let Voting, Voting2, VotingFactory;
  let targetTotalVotes = 3;
  // before(async () => {
  //   /* before tests */
  // });

  // beforeEach(async () => {
  //   /* before each context */
  // });
  describe('deploying prerequistes once to run test', async () => {
    it('Deploying contracts', async () => {
      VotingFactory = await _VotingFactory.new({ from: creatorAddress });
      await VotingFactory.createNewCampaign("testVote", targetTotalVotes, creatorAddress, {
        from: creatorAddress 
      });
      let result = await VotingFactory.getCampaign(1);
      result[1].should.not.be.equal(ZERO_ADDRESS);
      Voting = await _Voting.at(result[1]);
    });
  });
  describe('checking Voting Factory functions', async () => {
    it('owner should be creator', async () => {
      let owner = await VotingFactory.owner();
      owner.should.be.equal(creatorAddress);
    });
    it('campaigns number should be 1', async () => {
      let campaignsNo = await VotingFactory.compaignsNum();
      campaignsNo.toNumber().should.equal(1);
    });
  });
  describe('checking Voting Campaign functions', async () => {
    it('owner should be creator', async () => {
      let owner = await Voting.owner();
      owner.should.be.equal(creatorAddress);
    });
    it('check target total votes', async () => {
      let totalVotes = await Voting.targetTotalVotes();
      totalVotes.toNumber().should.equal(targetTotalVotes);
    });
    it('Vote should not be started', async () => {
      let voteStatus = await Voting.isVoteStarted();
      voteStatus.should.be.equal(false);
    });
    it('Creator adding Candidates', async () => {
      let tx1 = await Voting.addCandidate("Candidate0", "Candidate0 desc", {
        from: creatorAddress 
      });
      let tx2 = await Voting.addCandidate("Candidate2", "Candidate2 desc", {
        from: creatorAddress 
      });
      let tx3 = await Voting.addCandidate("Candidate3", "Candidate3 desc", {
        from: creatorAddress 
      });
      tx1.receipt.status.should.equal(true);
      tx2.receipt.status.should.equal(true);
      tx3.receipt.status.should.equal(true);
    });
    it('contract should have 3 candidates', async () => {
      let candidatesNo = await Voting.candidatesNum();
      candidatesNo.toNumber().should.equal(3);
    });
    it('Vote should fail before Voting starts', async () => {
      await truffleAssert.reverts(Voting.vote(2, { from: user1 }), "vote is not in progress");
    });
    it('Votes number should still equal 0', async () => {
      let votesNo = await Voting.votesNum();
      votesNo.toNumber().should.equal(0);
    });
    it('Creator Editing candidate', async () => {
      await Voting.editCandidate(1, "Candidate1", "Candidate1 desc", {
        from: creatorAddress
      });
      let candidate = await Voting.getCandidate(1);
      candidate[1].should.be.equal("Candidate1");
    });
    it('Start voting', async () => {
      await Voting.startVoting({ from: creatorAddress });
      let voteStatus = await Voting.isVoteStarted();
      voteStatus.should.be.equal(true);
    });
    it('Vote to non existing candidate should fail', async () => {
      await truffleAssert.reverts(Voting.vote(0, { from: user1 }), "Candidate does not exist");
    });
    it('Regular Votes', async () => {
      let tx1 = await Voting.vote(2, { from: creatorAddress });
      let tx2 = await Voting.vote(3, { from: user1 });
      tx1.receipt.status.should.equal(true);
      tx2.receipt.status.should.equal(true);
    });
    it('User can not vote twice', async () => {
      await truffleAssert.reverts(Voting.vote(1, { from: creatorAddress }), "you have vote before");
    });
    it('One more vote', async () => {
      let tx3 = await Voting.vote(3, { from: user2 });
      tx3.receipt.status.should.equal(true);
    });
    it('Votes number should equal 3', async () => {
      let votesNo = await Voting.votesNum();
      votesNo.toNumber().should.equal(3);
    });
    it('User can not vote after votes reached', async () => {
      await truffleAssert.reverts(Voting.vote(1, { from: creatorAddress }), "Target Total Votes has been reached");
    });
    it('Candidate3 Should got 2 votes', async () => {
      let candidate = await Voting.getCandidate(3);
      candidate[3].toNumber().should.be.equal(2);
    });
  });
  describe('New Voting Campaign with different owner', async () => {
    it('Deploying contract', async () => {
      await VotingFactory.createNewCampaign("testVote2", targetTotalVotes, campaignOwner, {
        from: creatorAddress 
      });
      let result = await VotingFactory.getCampaign(2);
      result[1].should.not.be.equal(ZERO_ADDRESS);
      Voting2 = await _Voting.at(result[1]);
    });
    it('Check owner of the campaign', async () => {
      let owner = await Voting2.owner();
      owner.should.be.equal(campaignOwner);
    });
  });
});
