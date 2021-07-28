// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.0;

interface ICounter {
    function lastExecuted() external view returns (uint256);

    function increaseCount(uint256 amount) external;
}

contract CounterResolver {
    uint256 public count;
    uint256 public lastExecuted;
    address public immutable COUNTER;

    constructor(address _counter) {
        COUNTER = _counter;
    }

    function canExecGetPayload()
        external
        returns (bool canExec, bytes memory execPayload)
    {
        uint256 lastExecuted = ICounter(COUNTER).lastExecuted();

        canExec = (block.timestamp - lastExecuted) > 180;

        execPayload = abi.encodeWithSelector(
            ICounter.increaseCount.selector,
            uint256(100)
        );
    }

    function selector() external pure returns (bytes4) {
        return this.canExecGetPayload.selector;
    }
}
