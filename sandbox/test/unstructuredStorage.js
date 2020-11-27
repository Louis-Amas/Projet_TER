const Web3 = require('web3')
const encodeCall = require('./helpers/encodeCall')

const Vote  = artifacts.require('Vote')
const DelegateVote = artifacts.require('DelegateVote')
const OwnableProxy  = artifacts.require('OwnableProxy')

const candidates = ['Louis', 'Luigi'].map(name => Web3.utils.fromAscii(name))

contract('Proxy', accounts => {

    describe('Proxy initialize', () => {

        const initializeData = encodeCall('initialize', ['bytes32[]'], [candidates]);
        let vote
        let proxy
        let proxyVote


        before(async () => {
            vote = await Vote.new(candidates, {from: accounts[0]})
            proxy = await OwnableProxy.new({from: accounts[0]})
            proxyVote = await Vote.at(proxy.address)
        })

        it('Proxy update implementation', async() => {
            await proxy.upgradeToAndCall(vote.address, initializeData, {from: accounts[0]})
            const address = await proxy.getImplementation()
            assert.equal(vote.address, address, 'Proxy address is not correct')

            const chairperson = await proxyVote.chairperson()
            assert(accounts[0], chairperson, 'Chairperson is not correct')

            const proposal0 = await proxyVote.proposals(0);
            const proposal1 = await proxyVote.proposals(1);
            assert(proposal0, candidates[0], 'Proposal 0 is not correct')
            assert(proposal1, candidates[1], 'Proposal 1 is not correct')
        })
    })

    describe('Proxy vote test methods', () => {

        const initializeData = encodeCall('initialize', ['bytes32[]'], [candidates])
        let vote
        let proxy
        let proxyVote

        let delegateVote
        let delegateProxyVote

        before(async () => {
            vote = await Vote.new(candidates, {from: accounts[0]})
            proxy = await OwnableProxy.new({from: accounts[0]})
            proxyVote = await Vote.at(proxy.address)
            delegateVote = await DelegateVote.new({from: accounts[0]})
            delegateProxyVote = await DelegateVote.at(proxy.address)

            await proxy.upgradeToAndCall(vote.address, initializeData, {from: accounts[0]})
        })

        it('Authorize account 1 to vote', async () => {
            await proxyVote.giveRightToVote(accounts[0], {from: accounts[0]})
            let res = await proxyVote.voters(accounts[0])
            assert(true, res.hasRightToVote, 'Account do not have right to vote')
        })

        it('Change implementation of vote', async() => {
            await proxy.upgradeTo(delegateVote.address)
            await Promise.all(accounts.slice(1, 3).map(account => 
                delegateProxyVote.giveRightToVote(account)))
            
            await delegateProxyVote.delegateVote(accounts[0], {from: accounts[1]})
            await delegateProxyVote.delegateVote(accounts[0], {from: accounts[2]})

            await delegateProxyVote.vote(0, {from: accounts[0]})


            const proposal0 = await proxyVote.proposals(0);
            assert(3, proposal0.voteCount.toNumber(), 'Vote count should be 3')

        })

        
    })
});
