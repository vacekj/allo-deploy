// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/forge-std/src/Script.sol";
import "../lib/contracts/contracts/votingStrategy/QuadraticFundingStrategy/QuadraticFundingVotingStrategyImplementation.sol";
import "../lib/contracts/contracts/projectRegistry/ProjectRegistry.sol";
import "../lib/contracts/contracts/program/ProgramFactory.sol";
import "../lib/contracts/contracts/program/ProgramImplementation.sol";
import "forge-std/Test.sol";

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

        /* Using ffi, wait for 4 blocks, and return the current timestamp back to solidity */
        string[] memory inputs = new string[](6);
        inputs[0] = "cargo";
        inputs[1] = "run";
        inputs[2] = "--quiet";
        inputs[3] = "--bin";
        inputs[4] = "wait_for_blocks";
        inputs[5] = "70";

        bytes memory res = vm.ffi(inputs);
        uint256 blockNumber = abi.decode(res, (uint256));
        console.logUint(blockNumber);

        vm.stopBroadcast();
    }
}
