// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PurchaseAgreement{
    uint public value;
    address payable public seller;
    address payable public buyer;


    enum State{ Created, Locked, Release, Inacitve}
    State public state;

    constructor() payable  {
        seller = payable(msg.sender);
        value = msg.value / 2;

    }
 /// The function cannot be called at the current state.
    error InvalidState();
/// Only the buyer can call this function
    error OnlyBuyer();
    /// Only the seller can call this function
    error OnlySeller();

    modifier inState(State _state) {
        if(state != _state){
            revert InvalidState();
        }
        _;
    }

    modifier onlyBuyer(){
        if(msg.sender != buyer){
            revert OnlyBuyer();
        }
        _;
    }

    modifier  onlySeller(){
        if(msg.sender != seller){
            revert OnlySeller();
        }
        _;
    }

    function confirmPurchase() external inState(State.Created) payable {
        require(msg.value==2*value,"Please send 2x times  the purchase amount.");
        buyer =  payable(msg.sender);
        state = State.Locked;
    }

    function confirmReceived() external onlyBuyer inState(State.Locked) {
        state = State.Release;
        buyer.transfer(value);
        
    }

    function paySeller() external  onlySeller inState(State.Release){
      state = State.Inacitve;
      seller.transfer(3 * value);

    }

    function abort() external onlySeller inState(State.Created){
            state = State.Inacitve;
            seller.transfer(address(this).balance);
    }
}



