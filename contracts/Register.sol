pragma solidity >=0.4.0 <0.6.0;


//Smart contract to keep track of registered voters sepratly from ballot
// Contract is ment to be deployed by the Election Authority

contract Register{

    //creates the voter constructor, this stores a boolean value that represents is a user can vote
    //and stores the voters Crypto Phrase key
    struct voter
    {
        bool BoolVote;
        string CryptoKey;
    }

    //sets need variables for the contract
    address electionAuthority;
    mapping (address => voter) voters; // a mapping value for all Registered voters to tie
                                      // the users public address to the voter object the represents them

    //keeps track of resistered voters
    modifier registered_voters()
    {
        if (voters[msg.sender].BoolVote) revert();
        _;
    }

    //Sets the owner of the contract as the Election Authority when the contract is launched
    constructor() public
    {
        electionAuthority = msg.sender;
    }

    //Registers voters; sets the BoolVote value to true and saves thier Crypto Phrase key in the voter object
    function register_voter(address addr, string _CryptoKey) public //input is the account's public key
    registered_voters() //modifier to prevent voters from registering more then once
    {
        if (msg.sender != addr) revert(); // Checks to see if the account being added is comming from the same sender.
        voters[addr].BoolVote = true; //sets voter address to true
        voters[addr].CryptoKey = _CryptoKey; //stores thier Crypto Phrase key in the voter object
    }


     //function that checks if a user is regestered to vote and returns a boolean
    function is_registered() public view returns(bool)
    {
       return voters[msg.sender].BoolVote;
    }

    //function the returns a users crypto phrase key
    function get_key() public view returns(string)
    {
        return voters[msg.sender].CryptoKey;
    }


    // this is ment to be used by the Ballot contract to return a users CryptoKey so it can be compared
    function get_keyB(address addr) public returns(string)
    {
        return voters[addr].CryptoKey;
    }


    //this is ment to be used by the Ballot contract to return if a user is eligable to vote
    function is_registeredB(address addr) public returns(bool)
    {
       return voters[addr].BoolVote;
    }
}
