// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/forge-std/src/Script.sol";
import "../lib/contracts/contracts/votingStrategy/QuadraticFundingStrategy/QuadraticFundingVotingStrategyImplementation.sol";
import "../lib/contracts/contracts/projectRegistry/ProjectRegistry.sol";
import "../lib/contracts/contracts/program/ProgramFactory.sol";
import "../lib/contracts/contracts/program/ProgramImplementation.sol";
import "../lib/contracts/contracts/votingStrategy/QuadraticFundingStrategy/QuadraticFundingVotingStrategyFactory.sol";
import "../lib/contracts/contracts/payoutStrategy/MerklePayoutStrategy/MerklePayoutStrategyFactory.sol";
import "../lib/contracts/contracts/payoutStrategy/MerklePayoutStrategy/MerklePayoutStrategyImplementation.sol";
import "../lib/contracts/contracts/round/RoundFactory.sol";
import "../lib/contracts/contracts/round/RoundImplementation.sol";
import "../lib/contracts/contracts/round/IRoundImplementation.sol";
import "../lib/contracts/contracts/settings/AlloSettings.sol";
import "../lib/forge-std/src/Test.sol";
import "../lib/forge-std/src/console.sol";

contract ApplyToRound is Script {

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        string memory key = "ROUND_ADDRESS";
        address output = vm.envAddress(key);
        console.log("%s", output);

        RoundImplementation round = RoundImplementation(payable(output));
        MetaPtr[] memory metaPtrs = new MetaPtr[](4);
        metaPtrs[0] = MetaPtr(
            1,
            "bafybeiekytxwrrfzxvuq3ge5glfzlhkuxjgvx2qb4swodhqd3c3mtc5jay"
        );
        metaPtrs[1] = MetaPtr(
            1,
            "bafybeih2pise44gkkzj7fdws3knwotppnh4x2gifnbxjtttuv7okw4mjzu"
        );
        metaPtrs[2] = MetaPtr(
            1,
            "bafybeiceggy6uzfxsn3z6b2rraptp3g2kx2nrwailkjnx522yah43g5tyu"
        );
        metaPtrs[3] = MetaPtr(
            1,
            "bafybeiceggy6uzfxsn3z6b2rraptp3g2kx2nrwailkjnx522yah43g5tyu"
        );

        ApplicationStatus[] memory statuses = new ApplicationStatus[](4);

        /* Apply to round with all the projects */
        for (uint256 i = 0; i < metaPtrs.length; i++) {
            statuses.push(ApplicationStatus());
        }

        vm.stopBroadcast();
    }
}
