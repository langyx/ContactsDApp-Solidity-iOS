const ContactsContract = artifacts.require('Contacts');
module.exports = function(_deployer) {
  _deployer.deploy(ContactsContract)
};