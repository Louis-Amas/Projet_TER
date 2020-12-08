const VoteToken  = artifacts.require('VoteToken')
const DiamondWithGovernance  = artifacts.require('DiamondWithGovernance')
const Test1Facet = artifacts.require('Test1Facet')
const Test2Facet = artifacts.require('Test2Facet')
const FacetCutAction = {
  Add: 0,
  Replace: 1,
  Remove: 2
}

const Status = {
  Open: 0,
  Accepted: 1,
  Refused: 2
}
const getSelectors = (contract) => {
  const selectors = contract.abi.reduce((acc, val) => {
    if (val.type === 'function') {
      acc.push(val.signature)
      return acc
    } else {
      return acc
    }
  }, [])
  return selectors
}

contract('Vote Token', accounts => {
    describe('Test vote token', () => {

        const holders = accounts.slice(0, 4)
        let voteToken;
        let diamondWithGovernance;
        let test1;
        let test2;
        let diamondCuts;


        before(async() => {
            voteToken = await VoteToken.new(holders, 100, {from: accounts[0]});
            test1 = await Test1Facet.new();
            test2 = await Test2Facet.new();
            diamondWithGovernance = await DiamondWithGovernance.new(voteToken.address, {from: accounts[0]})
            
            test1Proxy = await Test1Facet.at(diamondWithGovernance.address);
            test2Proxy = await Test2Facet.at(diamondWithGovernance.address);

            diamondCuts = [
                [test1.address, FacetCutAction.Add, getSelectors(Test1Facet)],
                [test2.address, FacetCutAction.Add, getSelectors(Test2Facet)]
            ]
        })

        it('Ask for an upgrade', async() => {
            await diamondWithGovernance.askForUpgrade(diamondCuts, {from: holders[0]});
            const upgrades = await diamondWithGovernance.getUpgrade(0);
            assert(upgrades.length === diamondCuts.length, "Upgrades length should be equal ");
            assert(upgrades[0].address === diamondCuts[0].address, "Address should be equal");
            assert(upgrades[1].address === diamondCuts[1].address, "Address should be equal");
        })

        // it('Ask for an upgrade but not holder', async() => {
        //     await diamondWithGovernance.askForUpgrade(diamondCuts, {from: accounts[0]});
        //
        /* }) */
        it('Vote for an upgrade', async() => {
            await diamondWithGovernance.vote(0, {from: holders[1]});
            let status = await diamondWithGovernance.getStatus(0);
            assert(status == Status.Open, `Status should be ${Status.Open} but is ${status}`);

            await diamondWithGovernance.vote(0, {from: holders[2]});
            status = await diamondWithGovernance.getStatus(0);

            assert(status == Status.Accepted, `Status should be ${Status.Accepted} but is ${status}`);
        });

        it('Check if upgrades has worked', async() => {
            let res = await test1Proxy.test1();
            assert(res == true, `Status should be ${true} but is ${res}`);
            
            res = await test2Proxy.test2();
            assert(res == false, `Status should be ${false} but is ${res}`);
        });

    })
})
