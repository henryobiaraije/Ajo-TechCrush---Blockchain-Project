// SPDX-License-Identifier: Apache
pragma solidity ^0.8.13;

/// @notice Represents a single ajo participant
    struct AjoParticipant {

        /// @notice The address of this participant
        address participantAddress;

        /// @notice The serial number of this participant. Will be used to determine who go carry the pot and when serially.
        uint256 serialNumber;

        /// @notice The full name of this participant.
        bytes32 participantFullName;
    }