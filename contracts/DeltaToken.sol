pragma solidity ^0.4.23;


import "./StandardToken.sol";

contract DeltaToken  is StandardToken{
   
    address public teamTokensAddress;
    address public advisorsTokensAddress;
    address public partnerTokensAddress;
    address public marketingTokensAddress;
    address public ecosystemTokenAddress;
    address public reserveTokenAddress;

    uint256 public teamMaxTokensPhase1;
    uint256 public teamMaxTokensPhase2;
    uint256 public teamMaxTokensPhase3;

    uint256 public teamTokensReleasePhase1;
    uint256 public teamTokensReleasePhase2;
    uint256 public teamTokensReleasePhase3;
    uint256 public teamTokensWithdrawl;

    uint256 public partnerTokenReleasePhase1;
    uint256 public partnerTokenReleasePhase2;


    uint256 public partnerTokensWithdrawl;
    uint256 public advisorTokensWithdrawl;

    uint256 public partnerMaxTokensPhase1;
    uint256 public partnerMaxTokensPhase2;



    uint256 public reserveTokenReleasePhase;

    string public constant name = "DeLA";
    uint256 public constant decimals = 18;
    string public constant symbol = "DeLA";

    mapping(address=>uint256) public privateSaleAddresses;
    uint256 public privateSaleLockTime;
    
    
    using SafeMath for uint256;
    
     /* ICO status */
    enum State {
        Active,
        Closed
    }

    event Closed();

    State public state;

    constructor() public {
        owner = msg.sender;
        totalSupply_ = 10000000000 ether;  //as decimals is 18 so ether means multiple with 10 ** 18
        teamTokensAddress = 0x3b4bAD4e80da522B41820b5Cc0531cEAd4631b55; 
        partnerTokensAddress = 0x6163f86BDde5C25187497a8A1c5f21b3d8ca8a31;
        advisorsTokensAddress = 0x4e1650f1df1C8E257EE2D672CbE60AA7a7c76214; 
        marketingTokensAddress = 0x7A374CC5FDf66bA41bc77ca98cEacc5C3D7507d5;
        ecosystemTokenAddress = 0xeE8aC1734519f00253ca5dD9eCcDC2cAeCadf9Cc; 
        reserveTokenAddress = 0x94E5FA1038e57aB1Ba1e2f76666007f615aB1A64; 
        balances[owner] = 4000000000 ether;
        balances[teamTokensAddress] = 1500000000 ether;
        balances[partnerTokensAddress] = 400000000 ether;
        balances[advisorsTokensAddress] = 600000000 ether;
        balances[marketingTokensAddress] = 1500000000 ether;
        balances[ecosystemTokenAddress] = 1000000000 ether;
        balances[reserveTokenAddress] = 1000000000 ether;

        emit Transfer(address(0), owner, balances[owner]);
        emit Transfer(address(0), teamTokensAddress, balances[teamTokensAddress]);
        emit Transfer(address(0), partnerTokensAddress, balances[partnerTokensAddress]);
        emit Transfer(address(0), advisorsTokensAddress, balances[advisorsTokensAddress]);
        emit Transfer(address(0), marketingTokensAddress, balances[marketingTokensAddress]);
        emit Transfer(address(0), ecosystemTokenAddress, balances[ecosystemTokenAddress]);
        emit Transfer(address(0), reserveTokenAddress, balances[reserveTokenAddress]);


        state = State.Active;


        teamMaxTokensPhase1 = balances[teamTokensAddress].div(2); //50 % tokens for phase1 of 12 month
        teamMaxTokensPhase2 = teamMaxTokensPhase1 + teamMaxTokensPhase1.div(2); //25 % tokens for phase 2 of next 6 
                                                                                //months and 50 of phase 1 so that max 75% limit
        teamMaxTokensPhase3 = teamMaxTokensPhase2 + teamMaxTokensPhase1.div(2); //25% tokens for phase 3 of next 6 months and can be 100%


        partnerMaxTokensPhase1 = balances[partnerTokensAddress].div(2);
        partnerMaxTokensPhase2 = balances[partnerTokensAddress].sub(partnerMaxTokensPhase1);
    }


    function close() onlyOwner public {
        require(state == State.Active);
        state = State.Closed;


        teamTokensReleasePhase1 = 1530085200;  //block.timestamp + 365 seconds;
        teamTokensReleasePhase2 = 1530085800;   //block.timestamp + 182 seconds;
        teamTokensReleasePhase3 = 1530086400; //block.timestamp + 182 seconds;

        partnerTokenReleasePhase1 = 1530087000;//block.timestamp + 182 seconds;
        partnerTokenReleasePhase2 = 1530087600;//block.timestamp + 182 seconds;


        reserveTokenReleasePhase = 1530090600;//block.timestamp  + 365 seconds;
        privateSaleLockTime = 1530084000; //TODO change before live lock time of 12:20 PKTime and 16:20 KR time  
                                         //block.timestamp + 182 seconds; //6 month lock tokens
        
        emit Closed();
    }


    function () public payable {
        revert();
    }



    modifier checkTokensLock (uint256 _value) {
        uint256 currentTime = block.timestamp;
        if (msg.sender == teamTokensAddress) {
             require(state == State.Closed);
            require(currentTime >= teamTokensReleasePhase1);
            if(currentTime < teamTokensReleasePhase2) {
                require(teamTokensWithdrawl.add(_value) <= teamMaxTokensPhase1); 
                teamTokensWithdrawl = teamTokensWithdrawl.add(_value); 
                _; 
            }else if(currentTime < teamTokensReleasePhase3){
                require(teamTokensWithdrawl.add(_value) <= teamMaxTokensPhase2); 
                teamTokensWithdrawl = teamTokensWithdrawl.add(_value); 
                _; 
            }
            else{
                _;
            }

        } else if( msg.sender == partnerTokensAddress ) {
             require(state == State.Closed);
            require(currentTime >= partnerTokenReleasePhase1);
            if(currentTime < partnerTokenReleasePhase2){
                require(partnerTokensWithdrawl.add(_value) <= partnerMaxTokensPhase1); 
                partnerTokensWithdrawl = partnerTokensWithdrawl.add(_value);
                _;
            }else{
                _;
            }
        }
        else if(msg.sender == reserveTokenAddress){
             require(state == State.Closed);
            require(currentTime>=reserveTokenReleasePhase);
            _;
        }
        else if(privateSaleAddresses[msg.sender]>0){
            require(state == State.Closed);
            uint256 lockedTokens = privateSaleAddresses[msg.sender];
            uint256 userTotalTokens = balances[msg.sender];
            if( userTotalTokens.sub(_value) >= lockedTokens){
                _;
            }else{
                require(currentTime >= privateSaleLockTime);
                _;
            }
        }else{
            _;
        }
    }

    function privateSale(address _to, uint256 _value, uint256 bonus) onlyOwner public {
        uint256 totalCoins = _value + bonus;
        super.transfer(_to,totalCoins);
        privateSaleAddresses[_to] = privateSaleAddresses[_to].add(bonus);

    }
    function transfer(address _to, uint256 _value) public checkTokensLock(_value) returns (bool) {
        super.transfer(_to,_value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public checkTokensLock(_value) returns (bool){
        super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public checkTokensLock(_value) returns (bool) {
        super.approve(_spender, _value);
    }

    function increaseApproval(address _spender, uint _addedValue) public checkTokensLock(_addedValue) returns (bool) {
        super.increaseApproval(_spender, _addedValue);
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public  returns (bool) {
        super.decreaseApproval(_spender, _subtractedValue);
    }
    
}
