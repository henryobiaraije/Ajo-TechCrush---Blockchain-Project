// SPDX-License-Identifier: Apache
pragma solidity ^0.8.13;

contract AjoRegistry {

    // =====================================================
    //                       ERRORS
    // =====================================================

    /// @notice When there is no more chance to accept more people, this error will be thrown.
    error JoinAjoMaxParticipantsReached();

    /// @notice when the participant no wan pay the join fee.
    error JoinInsufficientJoinFee(uint256 whatYouSent, uint256 whatIsRequired);

    /// @notice Thrown when a participant tries to join more than onces.
    error JoinYouHaveJoinedBefore(AjoParticipant yourPreviousDetail);

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
    /// @notice Intentionally made this private to prevent it generating getter and setters as anyone here must pay first. As security conscious guy we I be na.
    mapping(address => AjoParticipant) private participants;

    /**
     * @notice Enables users to join this ajo contribution
     *
     * @param fullName The name of the participant
     *
     * @notice (1) mustPayJoinFee Ensures the user cannot join without paying the join fee.
     * @notice (2) ensureWeAreStillAcceptingParticipants` Ensures we don't register more people than needed.
     * @notice (2) preventDoubleJoiningByOneParticipant Ensures a user cannot register more than onces.
     *
     * @return success True if the participant joined successfully.
     */
    function join(bytes32 _fullName) public payable
    mustPayJoinFee
    ensureWeAreStillAcceptingParticipants
    preventDoubleJoiningByOneParticipant
    returns (bool) {

        // Add the user as a participant.
        uint256 newUserSerialNumber = totalParticipants + 1;
        participants[msg.sender] = AjoParticipant({
            participantAddress: msg.sender,
            serialNumber: newUserSerialNumber,
            participantFullName: _fullName
        });

        // Track number of users who are joining.
        totalParticipants += 1;

        return true;
    }

    // =====================================================
    //                       MODIFIERS
    // =====================================================

    /// @notice This ensures each participant just pay a fixed fee when joining.
    modifier mustPayJoinFee()  {
        if (msg.value < JOIN_FEE) {
            revert JoinInsufficientJoinFee(msg.value, JOIN_FEE);
        }
        _; // Continue from here.
    }

    /// @notice This ensures we won't register more participants than allowed.
    modifier ensureWeAreStillAcceptingParticipants(){
        if (totalParticipants >= MAXIMUM_AJO_PARTICIPANTS) {
            revert JoinAjoMaxParticipantsReached();
        }
        _; // continue from here.
    }

    /// @notice Prevents duplicate joining by one participant.
    modifier preventDoubleJoiningByOneParticipant(){
        // Lets use serial number to save gas. address will work too but will be more costly
        if (participants[msg.sender].serialNumber != 0) {
            revert JoinYouHaveJoinedBefore(participants[msg.sender]);
        }
        _; // continue.
    }

}