pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/EventTickets.sol";
import "../contracts/EventTicketsV2.sol";

contract TestEventTicket {
    uint public initialBalance = 1 ether;
    EventTickets myEvent1 = new EventTickets("My Party", "www.myparty.com",10);
    address buyer = address(this);

    function testreadEvent() public {
        (string memory description,, uint totalTickets,, bool isOpen) = myEvent1.readEvent();
        Assert.equal(description, "My Party","Description do not match");
        Assert.isTrue(isOpen, "Event is closed");
        Assert.equal(totalTickets, 10, "total tickets should be 10");
    }

    function testbuyTickets() public {
        bool r;
        myEvent1.buyTickets.value(0.25 ether)(2);
        (string memory description, string memory website, uint totalTickets, uint sales, bool isOpen) = myEvent1.readEvent();
        Assert.equal(website, "www.myparty.com", "url does not match");
        Assert.equal(sales, 2,"Sales should be 2");
        Assert.equal(totalTickets,8,"8 tickets should remain");
        Assert.equal(buyer.balance, 1 ether - 200 wei, "Balance should be 200 wei less");

        // buy more tickets than is available
        (r,) = address(myEvent1).call.value(5000)(abi.encodePacked(myEvent1.buyTickets.selector, uint(20)));
        Assert.isFalse(r, "Cannot buy more tickets than available");

        // not enought ether sent
        (r,) = address(myEvent1).call.value(1)(abi.encodePacked(myEvent1.buyTickets.selector, uint(3)));
        Assert.isFalse(r, "not enough ether sent");
    }

    function testgetBuyerTicketCount() public {
        uint ticketCount = myEvent1.getBuyerTicketCount(buyer);
        Assert.equal(ticketCount, 2,"Tickets bought should be 2");
    }

    function testgetRefund() public {
        myEvent1.getRefund();
        (string memory description, string memory website, uint totalTickets, uint sales, bool isOpen) = myEvent1.readEvent();
        Assert.equal(totalTickets, 10, "Total tickets should be 10");

        uint ticketCount = myEvent1.getBuyerTicketCount(buyer);
        Assert.equal(ticketCount, 0,"Tickets i own should be 0 b/c of refund");
        Assert.equal(buyer.balance, 1 ether,"not equal");
    }

    function testendSale() public {
        myEvent1.endSale();
        (string memory description, string memory website, uint totalTickets, uint sales, bool isOpen) = myEvent1.readEvent();
        Assert.isFalse(isOpen, "Sale ended");
        Assert.equal(buyer.balance, 1 ether, "Balance shoudl be 1 ether");
    }

    function() external payable{}
}