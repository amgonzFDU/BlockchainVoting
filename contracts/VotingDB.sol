pragma experimental ABIEncoderV2;

// holds the voting database and the funtiuons to add data to the data base and query data from the data base
contract VotingDB{


    //creates the data object for each new point of data entered
    struct data{
        uint index;
        address user_Key;
        address Balot_Address;
        string Crypyo_phrase;
        string proposal;
        string vote;

    }


    data[] DataBase; //ceates an array of the data objects to creates a database
    uint index_count; //keeps an index of the values being added
    address electionAuthority; //keeps track of the contract creator

    //constructor of the contract
    constructor() public
    {
        electionAuthority = msg.sender; //sets contract creator to contract owner
        index_count = 1; // sets index to start at one
    }

    //modifier for contract owner
    modifier only_election_authority()
    {
        if (msg.sender != electionAuthority) revert();
        _;
    }


    //inserts the voter data into the database
    function Insert(string _proposal, string _vote, string _Crypyo_phrase, address _user_Key, address _Balot_Address) public
    {
        //creates a new data object based on the inputs then uses .push to add it into the data base
        DataBase.push(data({
            index: index_count,
            user_Key: _user_Key,
            Balot_Address: _Balot_Address,
            Crypyo_phrase: _Crypyo_phrase,
            proposal: _proposal,
            vote: _vote
        }));
        index_count++; // increases index by 1
    }

     //arrays of strings can not be returned in solidity so out strings need to be convered into bytes32 values
    // funtion was borrowed from https://ethereum.stackexchange.com/questions/9142/how-to-convert-a-string-to-bytes32
    function stringToBytes32(string memory source) private returns (bytes32 result)
    {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
        return 0x0;
        }

        assembly
        {
        result := mload(add(source, 32))
        }
    }


    //Query based users crypto phrase key.
    // returns all values in the data base that match the input
    function Query1(string __Crypyo_phrase) public view returns( address[] _Balot_Address,
        address[] _user_Key, bytes32[] _Crypyo_phrase, bytes32[] _proposal ,bytes32[] _vote)
    {

          // solidity can not return objects arrays so we need to create temparay individual arrays for each data point then return them all together
         // solidity can also only handle a certain amount of values per funtion before running into an overflow error
        // because of this index could not be returned.
        address[] memory add_user = new address[](index_count);
        address[] memory add_ballot = new address[](index_count);
        bytes32[] memory CrPrase = new bytes32[](index_count);
        bytes32[] memory prop = new bytes32[](index_count);
        bytes32[] memory temp_vote = new bytes32[](index_count);

        uint j = 0; // creates and index value for adding values to the temparay arrays

        //interates through the database
        for(uint i = 0; i < DataBase.length; i++){

            //bool funtion that compares the Crypyo phrase with the one in the data base
            bool temp = keccak256(abi.encodePacked((__Crypyo_phrase))) == keccak256(abi.encodePacked((DataBase[i].Crypyo_phrase)));

            // if they match then the values at that point in the data base are stored in the temparay arrays
            if(temp){
                data storage Data = DataBase[i]; //creats a data object to store the data point to then store in the other arrays since memory values can be stored into arrays
                add_user[j] = Data.user_Key;  // adds the users public address
                add_ballot[j] = Data.Balot_Address; // adds contract address
                CrPrase[j] = stringToBytes32(Data.Crypyo_phrase); //coverts the Crypyo phrase from a string to bytes then adds it to the array
                prop[j] = stringToBytes32(Data.proposal); // coverts the proposal from a string to bytes then adds it to the array
                temp_vote[j] = stringToBytes32(Data.vote); // coverts the vote from a string to bytes then adds it to the array
                j++; // increase the index for the next value to be added
                //though the data points are stored in differnt arrays matching data points from the same data object will be stored at the same index
            }
        }
        //returns the arrays the data points have been added to
        return( add_ballot, add_user, CrPrase, prop, temp_vote);
    }


     //Query based users public address
    // structure is the same as as the perviouse Query except for the "bool temp" value
    function Query2(address user_addr) public view returns( address[] _Balot_Address,
        address[] _user_Key, bytes32[] _Crypyo_phrase, bytes32[] _proposal ,bytes32[] _vote)
    {

       address[] memory add_user = new address[](index_count);
        address[] memory add_ballot = new address[](index_count);
        bytes32[] memory CrPrase = new bytes32[](index_count);
        bytes32[] memory prop = new bytes32[](index_count);
        bytes32[] memory temp_vote = new bytes32[](index_count);

        uint j = 0;
        for(uint i = 0; i < DataBase.length; i++){

            bool temp = user_addr == DataBase[i].user_Key; //compares the user address search to addresses that match in the data base
            if(temp){
                data storage Data = DataBase[i];
                add_user[j] = Data.user_Key;
                add_ballot[j] = Data.Balot_Address;
                CrPrase[j] = stringToBytes32(Data.Crypyo_phrase);
                prop[j] = stringToBytes32(Data.proposal);
                temp_vote[j] = stringToBytes32(Data.vote);
                j++;
            }
        }
        return( add_ballot, add_user, CrPrase, prop, temp_vote);
    }


     //Query based on ballot address  or the address of the contract the ballot took place on.
    // structure is the same as as the perviouse Query except for the "bool temp" value
    function Query3(address ballot_addr) public view returns( address[] _Balot_Address,
        address[] _user_Key, bytes32[] _Crypyo_phrase, bytes32[] _proposal ,bytes32[] _vote)
    {

        address[] memory add_user = new address[](index_count);
        address[] memory add_ballot = new address[](index_count);
        bytes32[] memory CrPrase = new bytes32[](index_count);
        bytes32[] memory prop = new bytes32[](index_count);
        bytes32[] memory temp_vote = new bytes32[](index_count);

        uint j = 0;
        for(uint i = 0; i < DataBase.length; i++){

            bool temp = ballot_addr == DataBase[i].Balot_Address; //compares the contract address search to addresses that match in the data base
            if(temp){
                data storage Data = DataBase[i];
                add_user[j] = Data.user_Key;
                add_ballot[j] = Data.Balot_Address;
                CrPrase[j] = stringToBytes32(Data.Crypyo_phrase);
                prop[j] = stringToBytes32(Data.proposal);
                temp_vote[j] = stringToBytes32(Data.vote);
                j++;
            }
        }
        return( add_ballot, add_user, CrPrase, prop, temp_vote);
    }

    function Full_db() public view returns( address[], address[], bytes32[] , bytes32[] ,bytes32[])
    {
        address[] memory add_user = new address[](index_count);
        address[] memory add_ballot = new address[](index_count);
        bytes32[] memory CrPrase = new bytes32[](index_count);
        bytes32[] memory prop = new bytes32[](index_count);
        bytes32[] memory temp_vote = new bytes32[](index_count);
        uint j = 0;
        for(uint i = 0; i < DataBase.length; i++){

            data storage Data = DataBase[i];
            add_user[j] = Data.user_Key;
            add_ballot[j] = Data.Balot_Address;
            CrPrase[j] = stringToBytes32(Data.Crypyo_phrase);
            prop[j] = stringToBytes32(Data.proposal);
            temp_vote[j] = stringToBytes32(Data.vote);
            j++;
        }
        return( add_ballot, add_user, CrPrase, prop, temp_vote);

    }


}
