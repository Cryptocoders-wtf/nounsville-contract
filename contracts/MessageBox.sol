// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import { IMessageBox } from './interfaces/IMessageBox.sol';
import { AddressSet } from "./libs/AddressSet.sol";

contract MessageBox is Ownable, IMessageBox {
  using AddressSet for AddressSet.Set;

  mapping(address => mapping(address => mapping(uint256 => Message))) messages;
  mapping(address => mapping(address => uint256)) messageCounts;
  mapping(address => AddressSet.Set) senders;

  constructor() {
  }

	function _sendAppMessage(address _to, string memory _text, string memory _imageURL, address _app, uint256 _messageId) internal returns (uint256) {
    address from = msg.sender;
    Message memory message;
    message.sender = from;
    message.receiver = _to;
    message.text = _text;
    message.imageURL = _imageURL;
    message.app = _app;
    message.messageId = _messageId;
    message.isRead = false;
    message.isDeleted = false;
    message.timestamp = block.timestamp;

    uint256 index = messageCounts[_to][from];
    messages[_to][from][index] = message;
    messageCounts[_to][from] = index + 1;
    senders[_to].insert(from);
    emit MessageReceived(from, _to, index);
    return index;
  }

	function sendAppMessage(address _to, string memory _text, string memory _imageURL, address _app, uint256 _messageId) external override returns (uint256) {
    return _sendAppMessage(_to, _text, _imageURL, _app, _messageId);
  }

	function send(address _to, string memory _text) external override returns (uint256) {
    return _sendAppMessage(_to, _text, "", address(0), 0);
  }

	function numberOfSenders() external view override returns (uint256) {
    return senders[msg.sender].count();
  }

	function getSender(uint256 _index) external view override returns (address) {
    return senders[msg.sender].addressAtIndex(_index);
  }

	function numberOfMessages(address _from) external view override returns (uint256) {
    return messageCounts[msg.sender][_from];
  }

	function getMessage(address _from, uint256 _index) external view override returns (Message memory) {
    return messages[msg.sender][_from][_index];
  }

	function markRead(address _from, uint256 _index, bool _isRead) external override returns (Message memory) {
    Message storage message = messages[msg.sender][_from][_index];
    message.isRead = _isRead;
    emit MessageRead(message.sender, msg.sender, _index, _isRead);
    return message;
  }

	function markDeleted(address _from, uint256 _index, bool _isDeleted) external override returns (Message memory) {
    Message storage message = messages[msg.sender][_from][_index];
    message.isDeleted = _isDeleted;
    emit MessageDeleted(message.sender, msg.sender, _index, _isDeleted);
    return message;
  }
}