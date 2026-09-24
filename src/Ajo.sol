// SPDX-License-Identifier: Apache
pragma solidity ^0.8.30;

import {AjoParticipant} from "./types/common.sol";

contract Ajo {

    // =====================================================
    //                       ERRORS
    // =====================================================

    /// @notice When there is no more chance to accept more people, this error will be thrown.
    error AjoMaxParticipantsReached();

    error InsufficientJoinFee(uint256 whatYouSent, uint256 whatIsRequired);

    // =====================================================
    //                       CONSTANTS
    // =====================================================
    /**
     * @notice The maximum number of participants to participate in an ajo contribution at a time.
     */
    uint256 public constant MAXIMUM_AJO_PARTICIPANTS = 20;

    /**
     * @notice The fixed fee participants would need to pay to join.
     */
    uint256 public constant JOIN_FEE = 1 gwei;

    // =====================================================
    //                       STATES
    // =====================================================
    /**
     * @notice Tracks the total participants that has joined
     */
    uint8 public totalParticipants;

    /// @notice Stores all participants
    /// @security Intentionally made this private to prevent it generating getter and setters as anyone here must pay first. As security conscious guy we I be na.
    mapping(address => AjoParticipant) private participants;

    /**
     * @notice Enables users to join this ajo contribution
     *
     * @notice mustPayJoinFee Ensures the user cannot join without paying the join fee.
     * @notice ensureWeAreStillAcceptingParticipants Ensures we don't register more people than needed.
     *
     * @return success True if the participant joined successfully.
     */
    function join() public payable mustPayJoinFee ensureWeAreStillAcceptingParticipants returns (bool) {
        // Ensure we have not exceeded the total number of participants.
        if (totalParticipants >= MAXIMUM_AJO_PARTICIPANTS) {
            revert(AjoMaxParticipantsReached());
        }

        // Ensure user doesn't exist yet (by account address).
        //        usersExist = participants.co

        // Ensure the user sent the join fee.

        // Add the user as a participant.

        // Track number of users who are joining.

        // Track total number of participants that has joined.

        return true;
    }

    /// @notice This ensures each participant just pay a fixed fee when joining.
    modifier mustPayJoinFee()  {
        if (msg.value < JOIN_FEE) {
            revert(InsufficientJoinFee(msg.value, JOIN_FEE));
        }
        _; // Continue from here.
    }

    /// @notice This ensures we won't register more participants than allowed.
    modifier ensureWeAreStillAcceptingParticipants(){
        if (totalParticipants >= MAXIMUM_AJO_PARTICIPANTS) {
            revert(AjoMaxParticipantsReached());
        }
        _; // continue from here.
    }

}
