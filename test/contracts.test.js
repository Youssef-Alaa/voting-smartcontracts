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

// function capitalize(str) {
//   return str.replace(/\b\w/g, l => l.toUpperCase());
// }
const _Voting = artifacts.require('Voting');
const _VotingFactory = artifacts.require('VotingFactory');

function delay(interval) 
{
   return it('should delay', done => 
   {
      setTimeout(() => done(), interval)

   }).timeout(interval + 100) // The extra 100ms should guarantee the test will not fail due to exceeded timeout
};

contract('Voting', accounts => {
  /* create named accounts for contract roles */
  const creatorAddress = accounts[0];
  const user1 = accounts[1];
  const user2 = accounts[2];
  const campaignOwner = accounts[3];
  const voter1 = accounts[4];
  const voter2 = accounts[5];
  const voter3 = accounts[6];
  const voter4 = accounts[7];
  const deadline = Math.round(Date.now() / 1000) + 30;
  let Voting, Voting2, VotingFactory;

  // before(async () => {
  //   /* before tests */
  // });

  // beforeEach(async () => {
  //   /* before each context */
  // });
  describe('deploying prerequistes once to run test', async () => {
    it('Deploying contracts', async () => {
      VotingFactory = await _VotingFactory.new({ from: creatorAddress });
      await VotingFactory.createNewCampaign("testVote", deadline, creatorAddress, true, {
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
    it('Stage Init', async () => {
      let voteStatus = await Voting.stage();
      console.log(voteStatus);
      voteStatus.toNumber().should.be.equal(0);
    });
    it('contract should have 3 candidates', async () => {
      let candidatesNo = await Voting.candidatesNum();
      candidatesNo.toNumber().should.equal(3);
    });
    it('Vote should fail before Voting starts', async () => {
      await truffleAssert.reverts(Voting.vote(2, { from: user1 }), "Not valid in current stage");
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
    it('Creator Adding voters', async () => {
      await Voting.addVoter(user1, {
        from: creatorAddress
      });
      await Voting.addVoter(user2, {
        from: creatorAddress
      });
      await Voting.addVoter(voter1, {
        from: creatorAddress
      });
      await Voting.addVoter(voter2, {
        from: creatorAddress
      });
      await Voting.addVoter(voter3, {
        from: creatorAddress
      });
      await Voting.addVoter(voter4, {
        from: creatorAddress
      });
      let voter1exists = await Voting.voterToDetails(user1);
      voter1exists[0].should.be.equal(true);
      let voter2exists = await Voting.voterToDetails(user2);
      voter2exists[0].should.be.equal(true);
      let voter3exists = await Voting.voterToDetails(voter1);
      voter3exists[0].should.be.equal(true);
      let voter4exists = await Voting.voterToDetails(voter2);
      voter4exists[0].should.be.equal(true);
      let voter5exists = await Voting.voterToDetails(voter3);
      voter5exists[0].should.be.equal(true);
      let voter6exists = await Voting.voterToDetails(voter4);
      voter6exists[0].should.be.equal(true);
    });
    it('Voters number should be 6', async () => {
      let votersNo = await Voting.votersNum();
      votersNo.toNumber().should.equal(6);
    });
    it('Start voting', async () => {
      await Voting.startVoting({ from: creatorAddress });
      let voteStatus = await Voting.stage();
      console.log(voteStatus);
      voteStatus.toNumber().should.be.equal(1);
    });
    it('Random 4 Votes and 1 abstain', async () => {
      let tx1 = await Voting.vote(2, { from: user1 });
      let tx2 = await Voting.vote(0, { from: user2 });
      let tx3 = await Voting.vote(2, { from: voter1 });
      let tx5 = await Voting.abstain( { from: voter3 });
      tx1.receipt.status.should.equal(true);
      tx2.receipt.status.should.equal(true);
      tx3.receipt.status.should.equal(true);
      tx5.receipt.status.should.equal(true);
    });
    it('User can not vote twice', async () => {
      await truffleAssert.reverts(Voting.vote(1, { from: user1 }), "voter does not exist or have voted before");
    });
    it('Votes number should equal 3', async () => {
      let votesNo = await Voting.votesNum();
      votesNo.toNumber().should.equal(3);
    });
    // delay(40000);
    // it('Finishing vote', async () => {
    //   await Voting.finishVoting({ from: creatorAddress });
    //   let voteStatus = await Voting.stage();
    //   console.log(voteStatus);
    //   voteStatus.toNumber().should.be.equal(2);
    // });
    it('Voting phase should be finished by one more vote', async () => {
      let tx4 = await Voting.vote(2, { from: voter2 });
      tx4.receipt.status.should.equal(true);
      let voteStatus = await Voting.stage();
      voteStatus.toNumber().should.be.equal(2);
    });
    it('User can not vote after votes reached', async () => {
      await truffleAssert.reverts(Voting.vote(1, { from: voter4 }), "Not valid in current stage");
    });
    it('Voting should be stopped after end time', async () => {
      let voteStatus = await Voting.stage();
      console.log(voteStatus);
      voteStatus.toNumber().should.be.equal(2);
    });
    it('Candidate3 Should got 3 votes', async () => {
      let candidate = await Voting.getCandidate(2);
      candidate[3].toNumber().should.be.equal(3);
    });
    it('Winner Should return candidate3', async () => {
      let candidate = await Voting.getWinningCandidate();
      candidate[0].toNumber().should.be.equal(2);
    });
  });
  describe('New Voting Campaign with different owner', async () => {
    it('Deploying contract', async () => {
      await VotingFactory.createNewCampaign("testVote", deadline, campaignOwner, false, {
        from: creatorAddress
      });
      let result = await VotingFactory.getCampaign(2);
      result[1].should.not.be.equal(ZERO_ADDRESS);
      Voting2 = await _Voting.at(result[1]);
    });
    it('Check owner of the new campaign', async () => {
      let owner = await Voting2.owner();
      owner.should.be.equal(campaignOwner);
    });
  });
});
