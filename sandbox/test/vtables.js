const encodeCall = require('./helpers/encodeCall')

const VTableProxy  = artifacts.require('VTableProxy')
const Token_V0_Storage  = artifacts.require('Token_V0_Storage')

const Mint  = artifacts.require('Mint')
const Burn  = artifacts.require('Burn')
const TransferTo  = artifacts.require('TransferTo')

const BurnUpgraded  = artifacts.require('BurnUpgraded')
const Token_V1_Storage  = artifacts.require('Token_V1_Storage')
const GetBurnedCoin  = artifacts.require('GetBurnedCoin')

contract('Vtables', accounts => {
    describe('Initialize VTableProxy', () => {
        let proxy;

        let storage;
        let mint;
        let burn;
        let transferTo;

        let storageProxy;
        let mintProxy;
        let burnProxy;
        let transferToProxy;
        let getBurnedCoinProxy;


        let mintSignature
        let burnSignature
        let transferToSignature

        let burnedCoinSignature
        let getBurnedCoinSignature
        before(async() => {

            storage = await Token_V0_Storage.new({from: accounts[0]})
         
            proxy = await VTableProxy.new(storage.address, {from: accounts[0]})


            mint = await Mint.new({from: accounts[0]})
            burn = await Burn.new({from: accounts[0]})
            transferTo = await TransferTo.new({from: accounts[0]})

            storageProxy = await Token_V0_Storage.at(proxy.address)
            mintProxy = await Mint.at(proxy.address)
            burnProxy = await Burn.at(proxy.address)
            transferToProxy = await TransferTo.at(proxy.address)


            mintSignature = "mint(address,uint256)"
            burnSignature = "burn(uint256)"
            transferToSignature = "transferTo(address,uint256)"

            burnedCoinSignature = "burnedCoin()"
            getBurnedCoinSignature = "getBurnedCoin()"
        })

        it('verify that everything is well initialized', async() => {
            await storageProxy.initialize(accounts[0])

            let admin = await storageProxy.admin()
            let adminMint = await mintProxy.admin()

            assert(admin === accounts[0])
            assert(admin === adminMint)
        })

        it('add implementations', async() => {
            await proxy.addImplementationFromName(mintSignature, mint.address)
            await proxy.addImplementationFromName(burnSignature, burn.address)
            await proxy.addImplementationFromName(transferToSignature, transferTo.address)

            let impl = await proxy.getImplementationFromName(mintSignature)
            assert(impl == mint.address, "Address of implementation should be equal")

            impl = await proxy.getImplementationFromName(burnSignature)
            assert(impl == burn.address, "Address of implementation should be equal")

            impl = await proxy.getImplementationFromName(transferToSignature)
            assert(impl == transferTo.address, "Address of implementation should be equal")
        })

        it('Use mint', async() => {
            await mintProxy.mint(accounts[1], 200, {from: accounts[0]})
            let total_amount = await storageProxy.total_amount()
            assert(total_amount.toNumber() == 200)

            let balance = await storageProxy.getMyBalance({from: accounts[1]})
            assert(balance.toNumber() === 200, 'Value should be 200 but is ' + balance.toNumber())
        })

        it('Use burn', async() => {
            await burnProxy.burn(100, {from: accounts[1]})
            let total_amount = await storageProxy.total_amount()
            assert(total_amount.toNumber() == 100)

            balance = await storageProxy.getMyBalance({from: accounts[1]})
            assert(balance.toNumber() === 100, 'Value should be 100 but is ' + balance.toNumber())
        })

        it('Use transferTo', async() => {
            await transferToProxy.transferTo(accounts[3], 60, {from: accounts[1]})
            let total_amount = await storageProxy.total_amount()
            assert(total_amount.toNumber() == 100)

            balance = await storageProxy.getMyBalance({from: accounts[3]})
            assert(balance.toNumber() === 60, 'Value should be 50 but is ' + balance.toNumber())

            balance = await storageProxy.getMyBalance({from: accounts[1]})
            assert(balance.toNumber() === 40, 'Value should be 50 but is ' + balance.toNumber())
        })

        it('Change implementation of burn', async() => {
            const burnUpgraded = await BurnUpgraded.new({from: accounts[0]})
            const getBurnedCoin = await GetBurnedCoin.new({from: accounts[0]})
            
            await proxy.addImplementationFromName(burnSignature, burnUpgraded.address)
            await proxy.addImplementationFromName(burnedCoinSignature, burnUpgraded.address)
            await proxy.addImplementationFromName(getBurnedCoinSignature, getBurnedCoin.address)

            impl = await proxy.getImplementationFromName(burnSignature)
            assert(impl == burnUpgraded.address, "Address of implementation should be equal")

            burnProxy = await BurnUpgraded.at(proxy.address)
            storageProxy = await Token_V1_Storage.at(proxy.address)
            getBurnedCoinProxy = await GetBurnedCoin.at(proxy.address)

        })

        it('test upgrade burn', async() => { 
            
            await burnProxy.burn(10, {from: accounts[3]})
            
            balance = await burnProxy.getMyBalance({from: accounts[3]})
            assert(balance.toNumber() === 50, 'Value should be 50 but is ' + balance.toNumber())

            balance = await burnProxy.burnedCoin();
            assert(balance == 10, 'Value should be 10 but is ' + balance.toNumber())

            await getBurnedCoinProxy.getBurnedCoin({from: accounts[1]})
            balance = await burnProxy.burnedCoin();
            
            assert(balance == 0, 'Value should be 0 but is ' + balance.toNumber())


            balance = await burnProxy.getMyBalance({from: accounts[1]})
            assert(balance.toNumber() === 50, 'Value should be 50 but is ' + balance.toNumber())


        })
    })
})
