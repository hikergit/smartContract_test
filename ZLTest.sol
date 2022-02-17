// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title ZLTest
 */
contract ZLTest {

    address constant SERVER_ADDR = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    mapping(address => bool) public serverAllowd;
    mapping(address => bool) public transactionInitialized;
    mapping(address => uint) public levels;

    modifier validAddr() {
        require(msg.sender != address(0x0), "Invalid address");
        _;
    }

    function setServerAllowed(bytes32 _ethSignedMessageHash, bytes memory _signature) validAddr external {
        address signer = recoverSigner(_ethSignedMessageHash, _signature);
        require(signer == SERVER_ADDR, "Invalid");
        serverAllowd[msg.sender] = true;
    }

    function setTxIntializd(bytes32 _ethSignedMessageHash, bytes memory _signature) validAddr external {
       address signer = recoverSigner(_ethSignedMessageHash, _signature);
        require(signer == SERVER_ADDR, "Invalid");
        transactionInitialized[msg.sender] = true;
    }

    function levelUp() validAddr external {
        require(serverAllowd[msg.sender], "Msg sender did not allowed by server");
        require(transactionInitialized[msg.sender], "Msg sender did not intialize tx");
        require(levels[msg.sender] < 5, "Msg sender already reached max level");
        levels[msg.sender] ++;
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature)
        public
        pure
        returns (address)
    {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        public
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        // implicitly return (r, s, v)
    }
}
