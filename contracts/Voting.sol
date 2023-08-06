// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract VotingSystem {
    
    struct Voter {
        bool registered;
        bool hasVoted;
        address delegate;
        string votername;
        string proposal;
    }
    
    struct Candidate {
        string name;
        uint voteCount;
    }
    
    
    address public admin;
    bool public electionStarted;
    bool public electionEnded;
    
    mapping(address => Voter) public voters;
    Candidate[] public candidates;
    
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the admin can perform this action");
        _;
    }
    
    modifier onlyRegisteredVoter() {
        require(voters[msg.sender].registered, "Only registered voters can perform this action");
        _;
    }
    
    modifier onlyBeforeElection() {
        require(!electionStarted, "This action can only be performed before the election starts");
        _;
    }
    
    modifier onlyDuringElection() {
        require(electionStarted && !electionEnded, "This action can only be performed during the election");
        _;
    }
    
    modifier onlyAfterElection() {
        require(electionEnded, "This action can only be performed after the election ends");
        _;
    }
    

    function startElection(address _admin) public onlyAdmin onlyBeforeElection {
         admin = _admin;
        electionStarted = true;
    }
    
    function endElection(address _admin) public onlyAdmin onlyDuringElection {
        admin = _admin;
        electionEnded = true;
    }
    
    function registerVoter(address _voter, string memory _votername) public onlyAdmin onlyBeforeElection {
        require(!voters[_voter].registered, "Voter is already registered");
        voters[_voter].registered = true;
        voters[_voter].votername = _votername;
    }
    
    function registerCandidate(string memory _name) public onlyAdmin onlyBeforeElection {
        candidates.push(Candidate(_name, 0));
    }
    
    function vote(address _candidate) public onlyRegisteredVoter onlyDuringElection {
        require(!voters[msg.sender].hasVoted, "Voter has already voted");
        require(voters[_candidate].registered, "Candidate is not registered");
        require(_candidate != msg.sender, "Cannot vote for yourself");
        
        voters[msg.sender].hasVoted = true;
        
        for (uint i = 0; i < candidates.length; i++) {
            if (_candidate == address(uint160(uint(keccak256(abi.encodePacked(candidates[i].name)))))) {
                candidates[i].voteCount += 1;
                break;
            }
        }
    }
    
    function delegateVote(address _to) public onlyRegisteredVoter onlyDuringElection {
        require(!voters[msg.sender].hasVoted, "Voter has already voted");
        require(_to != msg.sender, "Cannot delegate vote to yourself");
        
        voters[msg.sender].delegate = _to;
    }
    
    function getVoterDetails(address _voter) public view returns (bool registered, bool hasVoted, address delegate) {
        registered = voters[_voter].registered;
        hasVoted = voters[_voter].hasVoted;
        delegate = voters[_voter].delegate;
    }
    
    function getCandidatesCount() public view returns (uint count) {
        count = candidates.length;
    }
    
    function getCandidateDetails(uint _index) public view returns (string memory name, uint voteCount) {
        require(_index < candidates.length, "Invalid candidate index");
        name = candidates[_index].name;
        voteCount = candidates[_index].voteCount;
    }
    
    function showResults(uint _index) public view onlyAfterElection returns (string memory) {
        require(_index < candidates.length, "Invalid candidate index");
        string memory results;
        
        for (uint i = 0; i < candidates.length; i++) {
            results = string(abi.encodePacked(results, "Candidate: ", candidates[i].name, ", Votes: ", toString(candidates[i].voteCount), "\n"));
        }
        
        return results;
    }
    
    function toString(uint _value) internal pure returns (string memory) {
        if (_value == 0) {
            return "0";
        }
        
        uint temp = _value;
        uint digits;
        
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        
        bytes memory buffer = new bytes(digits);
        while (_value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + _value % 10));
            _value /= 10;
        }
        
        return string(buffer);
    }
}