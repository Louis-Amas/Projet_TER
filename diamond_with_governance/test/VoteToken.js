const VoteToken  = artifacts.require('VoteToken')


const getHolders = async(voteToken) => {
    const arr = [];
    const countOfHolders = await voteToken.getHoldersCount();
    for (let i = 0; countOfHolders > i ; ++i) {
        arr.push(await voteToken.holders(i));
    }
    return arr
}


contract('Vote Token', accounts => {
    describe('Test vote token', () => {

        let voteToken;
        const holders = accounts.slice(1,3)

        before(async() => {
            voteToken = await VoteToken.new(holders, 100, {from: accounts[0]});
        })

        it('Verify holders after init', async() =>{
            const arr = await getHolders(voteToken);
            assert(arr[0] === holders[0], "Should be equal")
            assert(arr[1] === holders[1], "Should be equal")
        })

        it('Give money to some one', async() =>{
            await voteToken.transfer(accounts[0], 50, {from: holders[0]})
            const arr = await getHolders(voteToken);
            assert(arr.length === 3, "Should equal 3")
        });

        it('Give all money to someone', async() =>{
            await voteToken.transfer(accounts[0], 50, {from: holders[0]})
            const arr = await getHolders(voteToken);
            assert(arr.length === 2, "Should equal 2")
            assert(arr[0], accounts[0], 'Should equal accounts[0]')
            assert(arr[1], holders[0], 'Should equal holders[0]')
        });

        it('Give to himself', async() =>{
            await voteToken.transfer(accounts[0], 100, {from: accounts[0]})
            const arr = await getHolders(voteToken);
            assert(arr.length === 2, "Should equal 2")
        });

    })
})
