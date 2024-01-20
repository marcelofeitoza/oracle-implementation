// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

contract Oracle {
    uint256 public eth_usd_price;
    uint256 public eth_eur_price;
    uint256 public eth_btc_price;

    mapping(address => bool) public is_oracle;

    constructor() {
        is_oracle[msg.sender] = true;
    }

    modifier only_oracle() {
        require(is_oracle[msg.sender], "You are not the oracle.");
        _;
    }

    function update_prices(uint256 _usd, uint256 _eur, uint256 _btc)
        public
        only_oracle
    {
        eth_usd_price = _usd;
        eth_eur_price = _eur;
        eth_btc_price = _btc;
    }

    function add_oracle(address _newOracle) public only_oracle {
        is_oracle[_newOracle] = true;
    }

    function remove_oracle(address _oracle) public only_oracle {
        is_oracle[_oracle] = false;
    }
}
