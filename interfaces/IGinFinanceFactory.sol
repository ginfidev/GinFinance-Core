// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.6.12;

interface IGinFinanceFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    event SetPairFee(address indexed pair, uint pairFee);
    event SetDefaultFee(uint defaultFee);
    event SetFeeToAlloc(uint feeToAlloc);
    event SetFeeToSetter(address feeToSetter);
    event SetFeeTo(address feeTo);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function feeToAlloc() external view returns (uint);
    function defaultFee() external view returns (uint);
    function FEE_DENOMINATOR() external view returns (uint);
    function getPairFee(address pair) external view returns (uint);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
    function setFeeToAlloc(uint) external;
    function setDefaultFee(uint) external;
    function setPairFee(address pair, uint fee) external;
}
