pragma experimental ABIEncoderV2;
import "./Register.sol";
import "./VotingDB.sol";

 //smart contract that is used for voting
// keeps tracl of candidates and there votes, keeps track of who voted, and finds winner.


contract Ballot
{
    address electionAuthority;

    // creates candidate objects
    struct candidate
    {
        string name;     //stores names of candidate
        uint voteCount; // stores vote count of candidate
    }

    Register R;  // sets variable to represent the voting register contract
    VotingDB VD; // sets variable to represent the VotingDB contract



    string Proposal; // stores the proposal being voted on
    candidate[] candidates; // stores the candidate objects
    uint electionEndTime; //stores t7he election end time
    mapping (address => bool) voted; // maps what addresses have already voted
    string[] candidateNames; // stores the names of all the canidates

    //modifier to revert addresses that have voted
    modifier has_voted()
    {
        if(voted[msg.sender]) revert();
        _;
    }

    //modifier to revert addresses that have not registered
    modifier is_Registered()
    {
        if(!R.is_registeredB(msg.sender)) revert();
        _;
    }

    //modifier to revert addresses that are not the election authority
    modifier only_election_authority()
    {
        if (msg.sender != electionAuthority) revert();
        _;
    }

    //modifier the reverts if it is not within the time of the election
    modifier Only_Durring_election()
    {
        if (electionEndTime == 0 || electionEndTime > block.timestamp) revert();
        _;
    }


    // modifier that reverts if the election hasn't or is still taking place
    modifier Only_after_election()
    {
        if(electionEndTime < block.timestamp) revert();
        _;
    }

    // contract constructor; takes inputs of Proposal, an array of canidate names, durration of the poll, and the contract address
   // of the voter registration and the voting data base.
    constructor(string _Propsal, string[] memory Names, uint _Poll_Duration, address _reg, address _dataB) public
    {
        electionEndTime = block.timestamp + _Poll_Duration; // used _Poll_Duration to set enlection end time
        electionAuthority = msg.sender; // sets contract deployer as contract owner.
        Proposal = _Propsal; //stores the Proposal name
        candidateNames = Names;// stores names of candidates

        R = Register(_reg); // sets the registration address to R
        VD = VotingDB(_dataB); // sets voting data base to VD

        //creates the candidate object for each of the names and sets vote count to 0
        for (uint i = 0; i < Names.length; i++)
        {
            candidates.push(candidate({
                name: Names[i],
                voteCount: 0
            }));
        }
    }

    //returns the Proposal being voted on
    function get_Propsal() public view returns(string)
    {
        return(Proposal);
    }

    //return the list of canidates
    function get_Candidates() public view returns(string[])
    {
        return(candidateNames);
    }

    //voting funtion; input the name of who you are voting for and your accounts crypto key
    function vote(string _vote, string _CryptoKey) public
    has_voted() //checks of the user has voted yet
    Only_Durring_election() //checks that the election is going on
    is_Registered() //checks if the voter is regestered to vote
    {
        // creates a boolean to check if thier accounts key matches the one entered
        bool temp = keccak256(abi.encodePacked((R.get_keyB(msg.sender)))) == keccak256(abi.encodePacked((_CryptoKey)));
        if(temp)
        {
            // sets the users address to has voted if key matches
            voted[msg.sender] = true;
            // loops through the candidate pool to find the name of the candidate that matches the name the entered
            for(uint i = 0; i < candidateNames.length; i++){
                //checks of names match
                bool temp2 = keccak256(abi.encodePacked((candidates[i].name))) == keccak256(abi.encodePacked((_vote)));
                //when the name match increases votecount by 1 for that canidate
                if(temp2){
                    candidates[i].voteCount += 1;
                }
            }

            // Inserts the users vote into the voting database
            VD.Insert(Proposal, _vote, _CryptoKey, msg.sender, address(this)); //Inserts the Proposal being voted on, what they voted
                                                                              // their Crypto phrase Key, thier addres, and this
        }                                                                    // contract's address
        else
        {
            revert();
        }

    }


    //returns the winner after the eclection ends
    function get_Winner() public view returns(string, uint)
    {
        if(electionEndTime < block.timestamp) revert(); // checks if the election ended
        string memory winner; // stores winners name
        uint winning_number = 0; // stores winning number for votes
        //loops through the canidates to check what one has the most votes
        for(uint i = 0; i < candidates.length; i++)
        {
            bool temp = candidates[i].voteCount > winning_number; // compairs the vote counts a candidate aggasins the winning_number value
            // if temp is true sets the winning vote number and the winner to the values for that canidate
            if(temp)
            {
                winning_number = candidates[i].voteCount;
                winner = candidates[i].name;
            }


        }
        return(winner, winning_number); //returns the winner and winning amount of votes.
    }




}
