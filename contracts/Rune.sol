// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "./Ownable.sol";
import "./ERC721.sol";

contract Rune is Ownable, ERC721 {

  struct RuneItem {
    uint runeId;
    string name; 
  }

  // the global rune list
  RuneItem[] _runes;

  // rune ownership based on its index in the array
  mapping(uint => address) public _runeOwnersip;

  // Rune count owner has
  mapping(address => uint) _ownerRuneCount;

  // mapping for owner approval for transfer of token, granted by the token owner
  mapping(uint => address) _transferApproval;

  // events to notify front end a new rune was minted
  event MintedRune(uint runeId);

  modifier OnlyOwerOf(uint tokenId) {
    require(msg.sender == _runeOwnersip[tokenId]);
    _;
  }

  constructor() Ownable() public {
    // blank
  }

  function mint(uint runeId, string memory name) public onlyOwner {
    _runes.push(RuneItem(runeId, name));
    uint id = _runes.length - 1;

    // by default ownership is the creator of the contract
    _runeOwnersip[id] = msg.sender;
    _ownerRuneCount[msg.sender] = ++_ownerRuneCount[msg.sender];

    emit MintedRune(id);
  }


  // Trasfer is not part of ERC721 standard
  function transfer(address from, address to, uint256 tokenId) private {
    _ownerRuneCount[from] = _ownerRuneCount[from]--;
    _ownerRuneCount[to] = _ownerRuneCount[to]++;
    _runeOwnersip[tokenId] = to;

    emit Transfer(from, to, tokenId);
  }

  ////////////////////////////////////////////////////
  // ERC721 area
  function balanceOf(address owner) external override view returns (uint256) {
    return _ownerRuneCount[owner];
  }

  function ownerOf(uint256 tokenId) external override view returns (address) {
    return _runeOwnersip[tokenId];
  }

  function transferFrom(address from, address to, uint256 tokenId) external override payable {
    // check if request coming from the new owner or from the original owner of the token
    require(_runeOwnersip[tokenId] == msg.sender || _runeOwnersip[tokenId] == msg.sender);
    transfer(from, to, tokenId);

  }

  function approve(address newOwner, uint256 tokenId) external override OnlyOwerOf(tokenId) payable {
    _transferApproval[tokenId] = newOwner;
    emit Approval(msg.sender, newOwner, tokenId);
  }

  ////////////////////////////////////////////////////
}
