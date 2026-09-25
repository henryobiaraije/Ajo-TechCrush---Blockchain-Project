// SPDX-License-Identifier: Apache
pragma solidity ^0.8.13;

import {AjoParticipant} from "../types/common.sol";

abstract contract AjoRegistry {

    // =====================================================
    //                       ERRORS
    // =====================================================

    /// @notice When there is no more chance to accept more people, this error will be thrown.
    error AjoRegistryJoinAjoMaxParticipantsReached();

    /// @notice when the participant no wan pay the join fee.
    error AjoRegistryJoinInsufficientJoinFee(uint256 whatYouSent, uint256 whatIsRequired);

    /// @notice Thrown when a participant tries to join more than onces.
    error AjoRegistryJoinYouHaveJoinedBefore(AjoParticipant yourPreviousDetail);

    /// @notice Thrown when the participant is not found.
    /// @dev usually returned when trying to retrieve a particular participant.
    error AjoRegistryParticipantNotFound();

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
     * @notice Changed this to private for security reasons. Now, only join() in AjoRegistry can change it.
     */
    uint8 private totalParticipants;

    /// @notice Stores all participants
    /// @notice Intentionally made this private to prevent it generating getter and setters as anyone here must pay first. As security conscious guy we I be na.
    mapping(address => AjoParticipant) private participants;

    /// @notice A list of participants for easy access from web2.
    /// @dev Can also be used for pagination later.
    AjoParticipant[] private listOfParticipants;

    /**
     * @notice Enables users to join this ajo contribution
     *
     * @param _fullName The name of the participant
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
        listOfParticipants.push(participants[msg.sender]);

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
            revert AjoRegistryJoinInsufficientJoinFee(msg.value, JOIN_FEE);
        }
        _; // Continue from here.
    }

    /// @notice This ensures we won't register more participants than allowed.
    modifier ensureWeAreStillAcceptingParticipants(){
        if (totalParticipants >= MAXIMUM_AJO_PARTICIPANTS) {
            revert AjoRegistryJoinAjoMaxParticipantsReached();
        }
        _; // continue from here.
    }

    /// @notice Prevents duplicate joining by one participant.
    modifier preventDoubleJoiningByOneParticipant(){
        // Lets use serial number to save gas. address will work too but will be more costly
        if (participants[msg.sender].serialNumber != 0) {
            revert AjoRegistryJoinYouHaveJoinedBefore(participants[msg.sender]);
        }
        _; // continue.
    }

    // =====================================================
    //                       GETTERS
    // =====================================================

    /// @notice Returns the total participants since we've changed it to private.
    function getTotalParticipants() public view returns (uint8){
        return totalParticipants;
    }

    /// @notice Returns an array containing all the participants.
    /// Will use pagination after expanding.
    /// @return AjoParticipant A list of participants.
    function getListOfParticipants() public view returns (AjoParticipant[] memory){
        return listOfParticipants;
    }

    /// @notice Return participant by participant address
    function getParticipantByAddress(address participantAddress) public view returns (AjoParticipant memory){
        if (participants[msg.sender].participantAddress == address(0)) {
            revert AjoRegistryParticipantNotFound();
        }
        return participants[msg.sender];
    }
}