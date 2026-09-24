// SPDX-License-Identifier: Apache
pragma solidity ^0.8.30;

contract Ajo {
    /**
     * @notice The maximum number of participants to participate in an ajo contribution at a time.
     */
    uint256 public constant MAXIMUM_AJO_PARTICIPANTS = 20;

    /**
     * @notice The fixed fee participants would need to pay to join.
     */
    uint256 public constant JOIN_FEE = 1 gwei;

    /**
     * @notice Tracks the total participants that has joined
     */
    uint8 public totalParticipants;

    /**
     * @notice Enables users to join this ajo contribution
     * @return success True if the participant joined successfully.
     */
    function join() public payable returns (bool) {
        // Ensure we have not exceeded the total number of participants.

        // Ensure user doesn't exist yet (by account address).

        // Ensure the user sent the join fee.

        // Add the user as a participant.

        // Track number of users who are joining.

        // Track total number of participants that has joined.
    }
}
