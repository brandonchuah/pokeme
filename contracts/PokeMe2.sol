// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.0;

import {Gelatofied} from "./Gelatofied.sol";
import {GelatoBytes} from "./GelatoBytes.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract PokeMe2 is ReentrancyGuard, Gelatofied {
    using SafeMath for uint256;
    using GelatoBytes for bytes;
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using EnumerableSet for EnumerableSet.AddressSet;

    uint256 public id;
    mapping(bytes32 => address) public calleeOfTask;
    mapping(bytes32 => address) public execAddresses;
    mapping(address => uint256) public balanceOfCallee;
    mapping(address => EnumerableSet.Bytes32Set) internal _createdTasks;

    constructor(address payable _gelato) Gelatofied(_gelato) {}

    event TaskCreated(
        address execAddress,
        bytes4 selector,
        address resolver,
        bytes resolverData
    );
    event TaskCancelled(bytes32 task);

    function createTask(
        address _execAddress,
        bytes4 _execSelector,
        address _resolver,
        bytes calldata _resolverData
    ) external {
        bytes32 _task = getTaskHash(_execAddress, _execSelector);

        require(
            calleeOfTask[_task] == address(0),
            "PokeMe: createTask: Sender already started task"
        );

        _createdTasks[msg.sender].add(_task);
        calleeOfTask[_task] = msg.sender;
        execAddresses[_task] = _execAddress;

        emit TaskCreated(_execAddress, _execSelector, _resolver, _resolverData);
    }

    function cancelTask(bytes32 _task) external {
        require(
            calleeOfTask[_task] != address(0),
            "PokeMe: cancelTask: Sender did not start task yet"
        );

        _createdTasks[msg.sender].remove(_task);
        delete calleeOfTask[_task];
        delete execAddresses[_task];

        emit TaskCancelled(_task);
    }

    function exec(
        uint256 _txFee,
        address _execAddress,
        bytes calldata _execData
    ) external gelatofy(_txFee, ETH) {
        bytes32 task = getTaskHash(
            _execAddress,
            _execData.calldataSliceSelector()
        );
        require(
            calleeOfTask[task] != address(0),
            "PokeMe: exec: Sender did not start task yet"
        );

        address _callee = calleeOfTask[task];
        require(_callee != address(0), "PokeMe: exec: No task found");

        (bool success, ) = _execAddress.call(_execData);
        require(success, "PokeMe: exec: Execution failed");

        uint256 _balanceOfCallee = balanceOfCallee[_callee];

        balanceOfCallee[_callee] = _balanceOfCallee.sub(_txFee);
    }

    function depositFunds(address _receiver) external payable {
        require(msg.value != 0, "PokeMe: depositFunds: No ether sent");

        balanceOfCallee[_receiver] = balanceOfCallee[_receiver].add(msg.value);
    }

    function withdrawFunds(uint256 _amount) external nonReentrant {
        uint256 balance = balanceOfCallee[msg.sender];

        require(
            balance >= _amount,
            "PokeMe: withdrawFunds: Sender has insufficient balance"
        );

        balanceOfCallee[msg.sender] = balance.sub(_amount);

        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "PokeMe: withdrawFunds: Withdraw funds failed");
    }

    function getTaskHash(address _execAddress, bytes4 _selector)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encode(_execAddress, _selector));
    }
}