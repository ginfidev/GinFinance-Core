// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.6.12;

interface IGinFinanceCallee {
    function GinFinanceCall(address sender, uint amount0, uint amount1, bytes calldata data) external;
}
