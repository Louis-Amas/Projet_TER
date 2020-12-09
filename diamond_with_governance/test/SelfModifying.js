const SelfModiyingInvestment  = artifacts.require('SelfModifyingInvestment')
const Exchange1  = artifacts.require('Exchange1')
const Exchange2  = artifacts.require('Exchange2')
const Exchange3  = artifacts.require('Exchange3')

const FacetCutAction = {
  Add: 0,
  Replace: 1,
  Remove: 2
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

contract('Self modifying', accounts => {
    describe('Investment token', () => {

        let exchange1;
        let exchange2;
        let exchange3;
        
        let proxyExchange1;
        let proxyExchange2;
        let proxyExchange3;
        let diamondCuts;
        let selfModifyingInvestment;
        before(async() => { 

            exchange1 = await Exchange1.new();
            exchange2 = await Exchange2.new();
            exchange3 = await Exchange3.new();

            diamondCutsExchange1 = [
                [exchange1.address, FacetCutAction.Add, getSelectors(Exchange1)]
            ]

            diamondCutsExchange2 = [
                [exchange2.address, FacetCutAction.Replace, getSelectors(Exchange2)]
            ]

            diamondCutsExchange3 = [
                [exchange3.address, FacetCutAction.Replace, getSelectors(Exchange3)]
            ]

            diamondCuts = [diamondCutsExchange1, diamondCutsExchange2, diamondCutsExchange3];
            selfModifyingInvestment = await SelfModiyingInvestment.new(100, diamondCuts, {from: accounts[0]});
            proxyExchange1 = await Exchange1.at(selfModifyingInvestment.address);
            proxyExchange2 = await Exchange2.at(selfModifyingInvestment.address);
            proxyExchange3 = await Exchange3.at(selfModifyingInvestment.address);
        })

        it("Get token", async() => {
            await proxyExchange1.exchangeEtherToToken({from: accounts[0], value: 6});

            let balance = await selfModifyingInvestment.balanceOf(accounts[0]);
            assert(balance.toNumber() == 60, "Balance should be 60 but is " + balance.toNumber());
            await proxyExchange1.exchangeEtherToToken({from: accounts[0], value: 5});

            balance = await selfModifyingInvestment.balanceOf(accounts[0]);
            assert(balance.toNumber() == 85, "Balance should be 85 but is " + balance.toNumber());
        })

    })
})
