const Contacts = artifacts.require("Contacts");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
 contract("Contacts", function (accounts) {

   let instance;
   beforeEach('should setup the contract instance', async () => {
    instance = await Contacts.deployed();
  });

   it("should be equal zero", async function () {
    let value = await instance.getCount({'from': accounts[0]});
    return assert.equal(value, 0);
  });

   it("should be equal two after adding contact", async function () {
    await instance.addContact("Yannis", "0612", {'from': accounts[0]});
    await instance.addContact("Yannis", "0612", {'from': accounts[0]});
    let value = await instance.getCount({'from': accounts[0]});
    return assert.equal(value, 2);
  });

   it("first contact name should be equal yannis", async function () {
    let firstContact = await instance.getContact(1, {'from': accounts[0]});
    return assert.equal(firstContact['0'], "Yannis");
  });


 });
