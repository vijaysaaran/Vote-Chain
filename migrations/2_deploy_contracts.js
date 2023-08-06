var VotingSystem = artifacts.require("./Voting.sol");
module.exports = function(deployer) {
  
  deployer.deploy(VotingSystem);
 
};
