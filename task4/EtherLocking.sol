// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CryptoLocker {

    struct Lock {
        uint amount;
        uint unlockTime;
    }

    mapping(address => Lock) public locks;

    event Deposited(address indexed user, uint amount, uint unlockTime);
    event Withdrawn(address indexed user, uint amount);

    // Deposit Ether with a lock-in time (in seconds)
    function deposit(uint _lockTimeInSeconds) external payable {
        require(msg.value > 0, "Must send some Ether");
        require(_lockTimeInSeconds > 0, "Lock time must be greater than zero");
        require(locks[msg.sender].amount == 0, "Existing lock found");

        locks[msg.sender] = Lock({
            amount: msg.value,
            unlockTime: block.timestamp + _lockTimeInSeconds
        });

        emit Deposited(msg.sender, msg.value, locks[msg.sender].unlockTime);
    }

    // Withdraw after lock-in time
    function withdraw() external {
        Lock storage userLock = locks[msg.sender];
        require(userLock.amount > 0, "No locked funds found");
        require(block.timestamp >= userLock.unlockTime, "Funds are still locked");

        uint amountToSend = userLock.amount;
        userLock.amount = 0; // Reset to prevent reentrancy
        userLock.unlockTime = 0;

        payable(msg.sender).transfer(amountToSend);
        emit Withdrawn(msg.sender, amountToSend);
    }

    // View remaining lock time
    function getRemainingLockTime(address user) external view returns (uint) {
        if (block.timestamp >= locks[user].unlockTime) return 0;
        return locks[user].unlockTime - block.timestamp;
    }
}
