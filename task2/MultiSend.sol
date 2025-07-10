// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MultiSend {
    // Event for successful transfers
    event Sent(address indexed recipient, uint256 amount);

    // Payable function to distribute Ether
    function distributeEther(address[] calldata recipients) external payable {
        uint256 totalRecipients = recipients.length;
        require(totalRecipients > 0, "No recipients provided");
        require(msg.value > 0, "No Ether sent");

        uint256 amountPerRecipient = msg.value / totalRecipients;
        require(amountPerRecipient > 0, "Insufficient Ether to divide");

        for (uint256 i = 0; i < totalRecipients; i++) {
            (bool success, ) = payable(recipients[i]).call{value: amountPerRecipient}("");
            require(success, "Transfer failed to one of the recipients");
            emit Sent(recipients[i], amountPerRecipient);
        }

        // Refund any leftover wei due to division remainder
        uint256 leftover = msg.value - (amountPerRecipient * totalRecipients);
        if (leftover > 0) {
            (bool refundSuccess, ) = payable(msg.sender).call{value: leftover}("");
            require(refundSuccess, "Refund failed");
        }
    }
}
