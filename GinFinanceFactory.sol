// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.6.12;

import "./libraries/SafeMath.sol";
import './interfaces/IGinFinanceFactory.sol';
import './GinFinancePair.sol';

contract GinFinanceFactory is IGinFinanceFactory {
    using SafeMath for uint;

    address public override feeTo;
    address public override feeToSetter;
    address public override feeToAllocSetter;
    address public override defaultFeeSetter;
    address public override pairFeeSetter;

    uint public override feeToAlloc = 5;
    uint public override defaultFee = 30;
    uint public constant override FEE_DENOMINATOR = 10000;

    mapping(address => uint) public pairFee;
    mapping(address => mapping(address => address)) public override getPair;
    address[] public override allPairs;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    event SetPairFeeSetter(address pairFeeSetter);
    event SetPairFee(address indexed pair, uint pairFee);
    event SetDefaultFeeSetter(address defaultFeeSetter);
    event SetDefaultFee(uint defaultFee);
    event SetFeeToAllocSetter(address feeToAllocSetter);
    event SetFeeToAlloc(uint feeToAlloc);
    event SetFeeToSetter(address feeToSetter);
    event SetFeeTo(address feeTo);

    constructor(address _feeToSetter, address _feeToAllocSetter, address _defaultFeeSetter, address _pairFeeSetter) public {
        feeToSetter = _feeToSetter;
        feeToAllocSetter = _feeToAllocSetter;
        defaultFeeSetter = _defaultFeeSetter;
        pairFeeSetter = _pairFeeSetter;
    }

    function pairCodeHash() external pure returns (bytes32) {
        return keccak256(abi.encodePacked(type(GinFinancePair).creationCode));
    }

    function allPairsLength() external override view returns (uint) {
        return allPairs.length;
    }

    function getPairFee(address _pair) public override view returns (uint) {
        return pairFee[_pair] != 0 ? pairFee[_pair] : defaultFee;
    }

    function createPair(address tokenA, address tokenB) external override returns (address pair) {
        require(tokenA != tokenB, 'GinFinanceFactory: IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'GinFinanceFactory: ZERO_ADDRESS');
        require(getPair[token0][token1] == address(0), 'GinFinanceFactory: PAIR_EXISTS'); // single check is sufficient
        bytes memory bytecode = type(GinFinancePair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        GinFinancePair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeTo(address _feeTo) external override {
        require(msg.sender == feeToSetter, 'GinFinanceFactory: FORBIDDEN');
        feeTo = _feeTo;
        emit SetFeeTo(_feeTo);
    }

    function setFeeToSetter(address _feeToSetter) external override {
        require(msg.sender == feeToSetter, 'GinFinanceFactory: FORBIDDEN');
        feeToSetter = _feeToSetter;
        emit SetFeeToSetter(_feeToSetter);
    }

    function setFeeToAlloc(uint _feeToAlloc) external override {
        require(msg.sender == feeToAllocSetter, 'GinFinanceFactory: FORBIDDEN');
        require(_feeToAlloc <= 5, "GinFinanceFactory: FEE_TO_ALLOC_OVERFLOW");
        feeToAlloc = _feeToAlloc;
        emit SetFeeToAlloc(_feeToAlloc);
    }

    function setFeeToAllocSetter(address _feeToAllocSetter) external override {
        require(msg.sender == feeToAllocSetter, 'GinFinanceFactory: FORBIDDEN');
        feeToAllocSetter = _feeToAllocSetter;
        emit SetFeeToAllocSetter(_feeToAllocSetter);
    }

    // Max is 1%
    function setDefaultFee(uint _defaultFee) external override {
        require(msg.sender == defaultFeeSetter, 'GinFinanceFactory: FORBIDDEN');
        require(_defaultFee != 0 && _defaultFee <= 100, "GinFinanceFactory: FEE_OUT_OF_RANGE");
        defaultFee = _defaultFee;
        emit SetDefaultFee(_defaultFee);
    }

    function setDefaultFeeSetter(address _defaultFeeSetter) external override {
        require(msg.sender == defaultFeeSetter, 'GinFinanceFactory: FORBIDDEN');
        defaultFeeSetter = _defaultFeeSetter;
        emit SetDefaultFeeSetter(_defaultFeeSetter);
    }

    // Max is 1%
    function setPairFee(address _pair, uint _fee) external override {
        require(msg.sender == pairFeeSetter, 'GinFinanceFactory: FORBIDDEN');
        require(_fee != 0 && _fee <= 100, 'GinFinanceFactory: FEE_OUT_OF_RANGE');
        pairFee[_pair] = _fee;
        emit SetPairFee(_pair, _fee);
    }

    function setPairFeeSetter(address _pairFeeSetter) external override {
        require(msg.sender == pairFeeSetter, 'GinFinanceFactory: FORBIDDEN');
        pairFeeSetter = _pairFeeSetter;
        emit SetPairFeeSetter(_pairFeeSetter);
    }
}

