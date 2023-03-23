// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/forge-std/src/Script.sol";
import "../lib/contracts/contracts/votingStrategy/QuadraticFundingStrategy/QuadraticFundingVotingStrategyImplementation.sol";
import "../lib/contracts/contracts/projectRegistry/ProjectRegistry.sol";
import "../lib/contracts/contracts/program/ProgramFactory.sol";
import "../lib/contracts/contracts/program/ProgramImplementation.sol";

contract MyScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        /* Deploy project registry */
        ProjectRegistry registry = new ProjectRegistry();

        ProgramFactory programFactory = new ProgramFactory();
        programFactory.initialize();

        ProgramImplementation programImplementation = new ProgramImplementation();
        programFactory.updateProgramContract(address(programImplementation));

        QuadraticFundingVotingStrategyImplementation qfVotingStratImpl = new QuadraticFundingVotingStrategyImplementation();
        vm.stopBroadcast();
    }
}
