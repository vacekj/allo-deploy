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
import "../lib/contracts/contracts/settings/AlloSettings.sol";
import "../lib/forge-std/src/Test.sol";
import "../lib/forge-std/src/console.sol";

contract DeployAllo is Script {
    struct InitAddress {
        IVotingStrategy votingStrategy; // Deployed voting strategy contract
        IPayoutStrategy payoutStrategy; // Deployed payout strategy contract
    }

    struct InitRoundTime {
        uint256 applicationsStartTime; // Unix timestamp from when round can accept applications
        uint256 applicationsEndTime; // Unix timestamp from when round stops accepting applications
        uint256 roundStartTime; // Unix timestamp of the start of the round
        uint256 roundEndTime; // Unix timestamp of the end of the round
    }

    struct InitMetaPtr {
        MetaPtr roundMetaPtr; // MetaPtr to the round metadata
        MetaPtr applicationMetaPtr; // MetaPtr to the application form schema
    }

    struct InitRoles {
        address[] adminRoles; // Addresses to be granted DEFAULT_ADMIN_ROLE
        address[] roundOperators; // Addresses to be granted ROUND_OPERATOR_ROLE
    }

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerPubKey = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
        vm.startBroadcast(deployerPrivateKey);

        ProjectRegistry registry = new ProjectRegistry();

        ProgramFactory programFactory = new ProgramFactory();
        programFactory.initialize();

        ProgramImplementation programImplementation = new ProgramImplementation();
        programFactory.updateProgramContract(address(programImplementation));

        QuadraticFundingVotingStrategyFactory qfVotingStrategyFactory = new QuadraticFundingVotingStrategyFactory();
        qfVotingStrategyFactory.initialize();

        QuadraticFundingVotingStrategyImplementation qfVotingStratImpl = new QuadraticFundingVotingStrategyImplementation();
        qfVotingStratImpl.initialize();

        qfVotingStrategyFactory.updateVotingContract(
            address(qfVotingStratImpl)
        );

        MerklePayoutStrategyFactory merkleFactory = new MerklePayoutStrategyFactory();
        merkleFactory.initialize();

        MerklePayoutStrategyImplementation merkleImpl = new MerklePayoutStrategyImplementation();
        merkleImpl.initialize();

        merkleFactory.updatePayoutImplementation(payable(merkleImpl));

        AlloSettings settings = new AlloSettings();
        settings.initialize();

        RoundFactory roundFactory = new RoundFactory();
        roundFactory.initialize();

        RoundImplementation roundImpl = new RoundImplementation();

        roundFactory.updateRoundImplementation(payable(roundImpl));
        roundFactory.updateAlloSettings(address(settings));

        bytes memory params = generateAndEncodeRoundParam(
            address(qfVotingStratImpl),
            payable(merkleImpl),
            deployerPubKey
        );

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

        for (uint256 i = 0; i < metaPtrs.length; i++) {
            registry.createProject(metaPtrs[i]);
        }

        address payable roundAddress = payable(
            roundFactory.create(params, deployerPubKey)
        );
        RoundImplementation round = RoundImplementation(roundAddress);

        vm.stopBroadcast(); 
    }

    function generateAndEncodeRoundParam(
        address votingContract,
        address payable payoutContract,
        address adminAddress
    ) public view returns (bytes memory) {
        uint256 currentTimestamp = block.timestamp;
        MetaPtr memory roundMetaPtr = MetaPtr(
            1,
            "bafybeia4khbew3r2mkflyn7nzlvfzcb3qpfeftz5ivpzfwn77ollj47gqi"
        );
        MetaPtr memory applicationMetaPtr = MetaPtr(
            1,
            "bafkreih3mbwctlrnimkiizqvu3zu3blszn5uylqts22yvsrdh5y2kbxaia"
        );
        address[] memory roles = new address[](1);
        roles[0] = adminAddress;
        uint256 matchAmount = 100;
        address token = address(0);
        uint32 roundFeePercentage = 0;
        address roundFeeAddress = address(0);
        InitAddress memory initAddress = InitAddress(
            QuadraticFundingVotingStrategyImplementation(votingContract),
            MerklePayoutStrategyImplementation(payoutContract)
        );
        uint256 SECONDS_PER_SLOT = 12;
        InitRoundTime memory initRoundTime = InitRoundTime(
            currentTimestamp + 1,
            currentTimestamp + SECONDS_PER_SLOT * 4,
            currentTimestamp + SECONDS_PER_SLOT * 6,
            currentTimestamp + SECONDS_PER_SLOT * 8
        );
        InitMetaPtr memory initMetaPtr = InitMetaPtr(
            roundMetaPtr,
            applicationMetaPtr
        );
        InitRoles memory initRoles = InitRoles(roles, roles);

        return
            abi.encode(
                initAddress,
                initRoundTime,
                matchAmount,
                token,
                roundFeePercentage,
                roundFeeAddress,
                initMetaPtr,
                initRoles
            );
    }
}
