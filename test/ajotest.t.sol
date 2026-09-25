// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "../lib/forge-std/src/Test.sol";
import {Ajo} from "../src/Ajo.sol";
import {AjoRegistry} from "../src/registry/AjoRegistry.sol";
import {AjoParticipant} from "../src/types/common.sol";

contract AjoTest is Test {
    Ajo public newAjo;

    // actors
    address public ade = makeAddr("ade");
    address public musa = makeAddr("musa");

    // names (the contract stores names as bytes32)
    bytes32 constant ADE_NAME = "Ade";

    uint256 constant JOIN_FEE = 1 gwei;

    function setUp() public {
        newAjo = new Ajo();

        // give actors ETH so they can pay to join
        vm.deal(ade, 1 ether);
        vm.deal(musa, 1 ether);
    }

    // a) join is payable
    function testJoinIsPayable() public {
        vm.prank(ade);
        newAjo.join{value: JOIN_FEE}(ADE_NAME);

        assertEq(address(newAjo).balance, JOIN_FEE);
    }

    // b) cannot exceed maximum participants (20)
    function testCannotExceedMaxParticipants() public {
        uint256 max = newAjo.MAXIMUM_AJO_PARTICIPANTS();

        // fill the club
        for (uint256 i = 1; i <= max; i++) {
            address member = makeAddr(vm.toString(i));
            vm.deal(member, 1 ether);
            vm.prank(member);
            newAjo.join{value: JOIN_FEE}("Member");
        }

        // one extra person tries to join
        address extra = makeAddr("extra");
        vm.deal(extra, 1 ether);

        vm.expectRevert(AjoRegistry.AjoRegistryJoinAjoMaxParticipantsReached.selector);
        vm.prank(extra);
        newAjo.join{value: JOIN_FEE}("Extra");
    }

    // c) a participant cannot join twice
    function testCannotJoinTwice() public {
        vm.prank(ade);
        newAjo.join{value: JOIN_FEE}(ADE_NAME);

        // the error returns ade's previous details, so we rebuild them
        AjoParticipant memory previous = AjoParticipant({
            participantAddress: ade,
            serialNumber: 1,
            participantFullName: ADE_NAME
        });

        vm.expectRevert(
            abi.encodeWithSelector(
                AjoRegistry.AjoRegistryJoinYouHaveJoinedBefore.selector,
                previous
            )
        );
        vm.prank(ade);
        newAjo.join{value: JOIN_FEE}(ADE_NAME);
    }

    // d) must send the right fixed amount: too little
    function testCannotJoinWithLessThanJoinFee() public {
        uint256 sent = 0.5 gwei;

        vm.expectRevert(
            abi.encodeWithSelector(
                AjoRegistry.AjoRegistryJoinInsufficientJoinFee.selector,
                sent,
                JOIN_FEE
            )
        );
        vm.prank(ade);
        newAjo.join{value: sent}(ADE_NAME);
    }

    // d) must send the right fixed amount: too much
    // NOTE: this will FAIL until the contract checks `msg.value != JOIN_FEE`
    function testCannotJoinWithMoreThanJoinFee() public {
        vm.expectRevert();
        vm.prank(ade);
        newAjo.join{value: 2 gwei}(ADE_NAME);
    }

    // f) participant is added to the mapping after joining
    // NOTE: this will FAIL until getParticipantByAddress uses its input instead of msg.sender
    function testParticipantAddedToMapping() public {
        vm.prank(ade);
        newAjo.join{value: JOIN_FEE}(ADE_NAME);

        AjoParticipant memory p = newAjo.getParticipantByAddress(ade);

        assertEq(p.participantAddress, ade);
        assertEq(p.participantFullName, ADE_NAME);
        assertEq(p.serialNumber, 1);

        assertEq(newAjo.getTotalParticipants(), 1);
    }
}