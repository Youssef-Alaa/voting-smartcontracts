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
  const user3 = accounts[3];
  const unprivilegedAddress = accounts[4];
  
  let Voting, VotingFactory;

  before(async () => {
    /* before tests */
  });

  beforeEach(async () => {
    /* before each context */
  });
  describe('check  all contracts functions ', async () => {
    describe('deploying prerequistes once to run test', async () => {
      it('create contracts  ', async () => {
        VotingFactory = await _VotingFactory.new({ from: creatorAddress });
        await VotingFactory.createNewCampaign("testVote", 3, {
          from: creatorAddress 
        });

        let result = await VotingFactory.getCampaign(1);
        result.should.not.be.equal(ZERO_ADDRESS);
        Voting = await _Voting.at(result[1]);
      });
    });
  })
});
