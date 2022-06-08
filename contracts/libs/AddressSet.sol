// SPDX-License-Identifier: GPL-3.0

/// @title A generic Set<address>
// Based on https://github.com/rob-Hitchens/UnorderedKeySet

/*********************************
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░█████████░░█████████░░░ *
 * ░░░░░░██░░░████░░██░░░████░░░ *
 * ░░██████░░░████████░░░████░░░ *
 * ░░██░░██░░░████░░██░░░████░░░ *
 * ░░██░░██░░░████░░██░░░████░░░ *
 * ░░░░░░█████████░░█████████░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 *********************************/

pragma solidity ^0.8.6;

library AddressSet {
  struct Set {
    mapping(address => uint) pointers;
    address[] addresses;
  }

  function insert(Set storage self, address key) internal {
    require(key != address(0), "AddressSet - Address cannot be 0x0");
    if (!exists(self, key)) {
      self.addresses.push(key);
      self.pointers[key] = self.addresses.length - 1;
    }
  }

  function remove(Set storage self, address key) internal {
    require(exists(self, key), "AddressSet - Address does not exist in the set.");
    address keyToMove = self.addresses[count(self)-1];
    uint rowToReplace = self.pointers[key];
    self.pointers[keyToMove] = rowToReplace;
    self.addresses[rowToReplace] = keyToMove;
    delete self.pointers[key];
    self.addresses.pop();
  }

  function count(Set storage self) internal view returns(uint) {
    return(self.addresses.length);
  }

  function exists(Set storage self, address key) internal view returns(bool) {
    if(self.addresses.length == 0) return false;
    return self.addresses[self.pointers[key]] == key;
  }

  function addressAtIndex(Set storage self, uint index) internal view returns(address) {
    return self.addresses[index];
  }
}