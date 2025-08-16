// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/* ── OpenZeppelin imports ───────────────────────────────────────────── */
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/* ── NFT Contract ───────────────────────────────────────────────────── */
contract MyFullNFT is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    ERC721Burnable,
    ERC2981,
    Pausable,
    ReentrancyGuard,
    Ownable
{
    using Counters for Counters.Counter;

    Counters.Counter private _nextId;

    uint256 public mintPrice;          // wei per mint (public)
    uint256 public maxSupply;          // hard cap
    bool    public publicMintOpen;     // toggle public mint
    string  private _baseTokenURI;     // optional baseURI (used if you prefer base+tokenId style)

    /* ── Constructor ────────────────────────────────────────────────── */
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 mintPrice_,
        uint256 maxSupply_,
        string memory baseURI_,
        address royaltyReceiver,
        uint96 royaltyFeeNumerator  // e.g. 500 = 5% (denominator 10000)
    )
        ERC721(name_, symbol_)
        Ownable()                   // OZ v4: owner = deployer
    {
        mintPrice = mintPrice_;
        maxSupply = maxSupply_;
        _baseTokenURI = baseURI_;

        // default royalty for all tokens
        _setDefaultRoyalty(royaltyReceiver, royaltyFeeNumerator);
    }

    /* ── Minting ────────────────────────────────────────────────────── */
    /// Owner mint (free, direct to any address) with custom tokenURI
    function ownerMint(address to, string calldata tokenURI_) external onlyOwner whenNotPaused {
        _mintWithURI(to, tokenURI_);
    }

    /// Public mint (paid), mints to msg.sender with custom tokenURI
    function publicMint(string calldata tokenURI_) external payable nonReentrant whenNotPaused {
        require(publicMintOpen, "Public mint closed");
        require(msg.value == mintPrice, "Incorrect price");
        _mintWithURI(msg.sender, tokenURI_);
    }

    function _mintWithURI(address to, string calldata tokenURI_) internal {
        require(totalSupply() < maxSupply, "Max supply reached");
        uint256 tokenId = _nextId.current();
        _nextId.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, tokenURI_); // from ERC721URIStorage
    }

    /* ── Admin: controls & config ───────────────────────────────────── */
    function setPublicMintOpen(bool open) external onlyOwner { publicMintOpen = open; }
    function setMintPrice(uint256 newPrice) external onlyOwner { mintPrice = newPrice; }
    function setMaxSupply(uint256 newMax) external onlyOwner { require(newMax >= totalSupply(), "Below current supply"); maxSupply = newMax; }
    function setBaseURI(string calldata newBase) external onlyOwner { _baseTokenURI = newBase; }
    function setDefaultRoyalty(address receiver, uint96 feeNumerator) external onlyOwner { _setDefaultRoyalty(receiver, feeNumerator); }
    function deleteDefaultRoyalty() external onlyOwner { _deleteDefaultRoyalty(); }

    function pause() external onlyOwner { _pause(); }
    function unpause() external onlyOwner { _unpause(); }

    /// withdraw collected ETH from public mints
    function withdraw(address payable to) external onlyOwner {
        require(to != address(0), "Zero address");
        to.transfer(address(this).balance);
    }

    /* ── Internals / overrides (multiple inheritance glue) ──────────── */
    // Optional baseURI support (only used by ERC721URIStorage when its stored URI is empty)
    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    // Block transfers/mints while paused
    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable)
        whenNotPaused
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    // Required overrides for URIStorage & Enumerable
    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId); // returns stored URI (or baseURI+id if you use that pattern)
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, ERC2981)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
