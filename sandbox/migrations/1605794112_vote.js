const web3 = require('web3')
const Vote = artifacts.require("Vote");

const candidates =  ['Louis','Luigi'].map(el => web3.utils.fromAscii(el))

module.exports = function(_deployer) {
    _deployer.deploy(Vote, candidates);
};
