// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

abstract contract ReentrancyGuard {
    bool private _nonReentrant;
    constructor() { _nonReentrant = false; }
    modifier nonReentrant() {
        require(!_nonReentrant, "ReentrancyGuard: reentrant call");
        _nonReentrant = true;
        _;
        _nonReentrant = false;
    }
}
abstract contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() { _owner = msg.sender; emit OwnershipTransferred(address(0), _owner); }
    modifier onlyOwner() { require(_owner == msg.sender, "Ownable: caller is not the owner"); _; }
    function owner() public view returns (address) { return _owner; }
}

contract FantasySports is ReentrancyGuard, Ownable {
    struct Contest {
        address creator;
        string sport;
        string title;
        uint256 entryFee;
        uint256 maxParticipants;
        uint256 participantCount;
        uint256 prizePool;
        uint256 deadline;
        bool active;
        bool resolved;
        address winner;
    }
    Contest[] public contests;
    mapping(address => uint256[]) public userContests;
    mapping(uint256 => mapping(address => bool)) public participants;
    uint256 public contestCount;
    uint256 public totalFees;

    event ContestCreated(uint256 indexed cid, address indexed creator, string sport, string title, uint256 entryFee, uint256 maxParticipants);
    event ContestJoined(uint256 indexed cid, address indexed participant, uint256 fee);
    event ContestResolved(uint256 indexed cid, address indexed winner, uint256 prize);

    function createContest(string memory sport, string memory title, uint256 entryFee, uint256 maxParticipants, uint256 deadline)
        external onlyOwner nonReentrant returns (uint256) {
        require(entryFee > 0, "Zero fee");
        require(maxParticipants > 0, "Zero participants");
        require(deadline > block.timestamp, "Deadline in past");
        Contest storage c = contests.push();
        c.creator = msg.sender;
        c.sport = sport;
        c.title = title;
        c.entryFee = entryFee;
        c.maxParticipants = maxParticipants;
        c.participantCount = 0;
        c.prizePool = 0;
        c.deadline = deadline;
        c.active = true;
        c.resolved = false;
        c.winner = address(0);
        uint256 cid = contests.length - 1;
        contestCount = cid + 1;
        userContests[msg.sender].push(cid);
        emit ContestCreated(cid, msg.sender, sport, title, entryFee, maxParticipants);
        return cid;
    }

    function joinContest(uint256 cid) external payable nonReentrant {
        Contest storage c = contests[cid];
        require(c.active, "Contest inactive");
        require(!c.resolved, "Contest resolved");
        require(!participants[cid][msg.sender], "Already joined");
        require(msg.value == c.entryFee, "Incorrect fee");
        require(block.timestamp < c.deadline, "Deadline passed");
        require(c.participantCount < c.maxParticipants, "Full");
        c.participantCount += 1;
        c.prizePool += c.entryFee;
        totalFees += c.entryFee;
        participants[cid][msg.sender] = true;
        emit ContestJoined(cid, msg.sender, c.entryFee);
    }

    // FIX: winner is now a participant address (not an index), and resolveContest
    // pays the full prizePool to the winner — no longer a one-way lockbox.
    function resolveContest(uint256 cid, address winner) external onlyOwner {
        Contest storage c = contests[cid];
        require(!c.resolved, "Already resolved");
        require(block.timestamp >= c.deadline, "Deadline not passed");
        require(c.participantCount > 0, "No participants");
        require(participants[cid][winner], "Winner not a participant");
        c.resolved = true;
        c.active = false;
        c.winner = winner;
        uint256 prize = c.prizePool;
        c.prizePool = 0;
        (bool ok,) = payable(winner).call{value: prize}("");
        require(ok, "ETH transfer failed");
        emit ContestResolved(cid, winner, prize);
    }

    function getContest(uint256 cid) external view returns (address creator, string memory sport, string memory title, uint256 entryFee, uint256 maxParticipants, uint256 participantCount, uint256 prizePool, uint256 deadline, bool active, bool resolved, address winner) {
        Contest storage c = contests[cid];
        return (c.creator, c.sport, c.title, c.entryFee, c.maxParticipants, c.participantCount, c.prizePool, c.deadline, c.active, c.resolved, c.winner);
    }
}
