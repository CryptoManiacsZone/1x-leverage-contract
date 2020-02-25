pragma solidity ^0.5.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interface/IOneSplit.sol";
import "../IHolder.sol";
import "../lib/UniversalERC20.sol";


contract ExchangeOneSplit is IIExchange {

    using SafeMath for uint256;
    using UniversalERC20 for IERC20;

    IOneSplit public constant ONE_SPLIT = IOneSplit(0xDFf2AA5689FCBc7F479d8c84aC857563798436DD);

    function exchangeExpectedReturn(IERC20 fromToken, IERC20 toToken, uint256 amount) public returns(uint256) {
        (uint256 returnAmount,) = ONE_SPLIT.getExpectedReturn(
            fromToken,
            toToken,
            amount,
            4,
            0
        );
        return returnAmount;
    }

    function _exchange(IERC20 fromToken, IERC20 toToken, uint256 amount, uint256 minReturn) internal returns(uint256) {
        fromToken.universalApprove(address(ONE_SPLIT), amount);

        uint256 beforeBalance = toToken.universalBalanceOf(address(this));
        ONE_SPLIT.goodSwap.value(fromToken.isETH() ? amount : 0)(
            fromToken,
            toToken,
            amount,
            minReturn,
            4,
            0
        );

        return toToken.universalBalanceOf(address(this)).sub(beforeBalance);
    }
}