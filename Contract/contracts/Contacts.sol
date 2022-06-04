// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Contacts {

  struct Contact {
    uint id;
    string name;
    string phone;
  }
  
  constructor() public {
    // createContact('Yannis', '123123123');
  }
  
  mapping(address => uint) private contactsCount;
  mapping(address => mapping (uint => Contact)) private contacts;

  function getCount() external view returns(uint)  {
    address from = msg.sender;
    return contactsCount[from];
  }
  
  function addContact(string calldata _name, string calldata _phone) external returns(uint) {
    address from = msg.sender;
    uint count = contactsCount[from];
    contacts[from][count] = Contact(count, _name, _phone);
    contactsCount[from]++;
    return count;
  }

  function getContact(uint index) external view returns(string memory, string memory) {
   address from = msg.sender;
   Contact memory contact = contacts[from][index];
   return (contact.name, contact.phone);
 }

}