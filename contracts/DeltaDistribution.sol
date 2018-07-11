pragma solidity ^ 0.4 .24;

import "./ERC20.sol";

contract DeltaDistribution {

    function multisend(address _tokenAddr, address[] dests, uint256[] values) returns(
        uint256
    ) {
        uint256 i = 0;
        while (i < dests.length) {
            ERC20(_tokenAddr).transfer(dests[i], values[i]);
            i += 1;
        }
        return (i);
    }
}