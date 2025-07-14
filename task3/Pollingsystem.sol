// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PollingSystem {

    struct Poll {
        string title;
        string[] options;
        uint endTime;
        mapping(uint => uint) voteCount;
        mapping(address => bool) hasVoted;
        bool exists;
    }

    uint public pollCount = 0;
    mapping(uint => Poll) private polls;

    // Event to emit poll creation
    event PollCreated(uint pollId, string title, uint endTime);

    // Create a new poll
    function createPoll(string memory _title, string[] memory _options, uint _durationMinutes) external {
        require(_options.length >= 2, "At least 2 options required");
        require(_durationMinutes > 0, "Duration must be positive");

        Poll storage newPoll = polls[pollCount];
        newPoll.title = _title;
        newPoll.options = _options;
        newPoll.endTime = block.timestamp + (_durationMinutes * 1 minutes);
        newPoll.exists = true;

        emit PollCreated(pollCount, _title, newPoll.endTime);
        pollCount++;
    }

    // Vote for an option in a poll
    function vote(uint _pollId, uint _optionIndex) external {
        require(_pollId < pollCount, "Poll doesn't exist");
        Poll storage poll = polls[_pollId];
        require(block.timestamp < poll.endTime, "Voting has ended");
        require(!poll.hasVoted[msg.sender], "You have already voted");
        require(_optionIndex < poll.options.length, "Invalid option");

        poll.voteCount[_optionIndex]++;
        poll.hasVoted[msg.sender] = true;
    }

    // View poll details (excluding internal mappings)
    function getPollDetails(uint _pollId) external view returns (string memory title, string[] memory options, uint endTime) {
        require(polls[_pollId].exists, "Poll not found");
        Poll storage poll = polls[_pollId];
        return (poll.title, poll.options, poll.endTime);
    }

    // View votes of a poll
    function getVoteCounts(uint _pollId) external view returns (uint[] memory counts) {
        require(polls[_pollId].exists, "Poll not found");
        Poll storage poll = polls[_pollId];

        uint[] memory results = new uint[](poll.options.length);
        for (uint i = 0; i < poll.options.length; i++) {
            results[i] = poll.voteCount[i];
        }
        return results;
    }

    // Get the winning option
    function getWinningOption(uint _pollId) external view returns (string memory winningOption) {
        require(polls[_pollId].exists, "Poll not found");
        Poll storage poll = polls[_pollId];
        require(block.timestamp > poll.endTime, "Poll still active");

        uint maxVotes = 0;
        uint winningIndex = 0;
        for (uint i = 0; i < poll.options.length; i++) {
            if (poll.voteCount[i] > maxVotes) {
                maxVotes = poll.voteCount[i];
                winningIndex = i;
            }
        }
        return poll.options[winningIndex];
    }
}
