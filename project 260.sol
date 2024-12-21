// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DIYCraftSimulation {
    struct CraftItem {
        uint256 id;
        string name;
        string material;
        address creator;
        uint256 price;
        bool forSale;
    }

    uint256 public nextItemId;
    mapping(uint256 => CraftItem) public craftItems;
    mapping(address => uint256[]) public creatorItems;

    event ItemCreated(uint256 indexed id, string name, string material, address indexed creator);
    event ItemListed(uint256 indexed id, uint256 price);
    event ItemSold(uint256 indexed id, address indexed buyer);

    // Create a new craft item
    function createItem(string memory name, string memory material) public {
        uint256 itemId = nextItemId;
        craftItems[itemId] = CraftItem({
            id: itemId,
            name: name,
            material: material,
            creator: msg.sender,
            price: 0,
            forSale: false
        });
        creatorItems[msg.sender].push(itemId);
        nextItemId++;
        emit ItemCreated(itemId, name, material, msg.sender);
    }

    // List an item for sale
    function listItem(uint256 itemId, uint256 price) public {
        CraftItem storage item = craftItems[itemId];
        require(msg.sender == item.creator, "Only the creator can list this item");
        require(!item.forSale, "Item is already for sale");
        require(price > 0, "Price must be greater than zero");

        item.price = price;
        item.forSale = true;

        emit ItemListed(itemId, price);
    }

    // Purchase an item
    function buyItem(uint256 itemId) public payable {
        CraftItem storage item = craftItems[itemId];
        require(item.forSale, "Item is not for sale");
        require(msg.value == item.price, "Incorrect price sent");

        address creator = item.creator;
        item.forSale = false;
        item.price = 0;
        item.creator = msg.sender;

        payable(creator).transfer(msg.value);

        emit ItemSold(itemId, msg.sender);
    }

    // Get items created by a user
    function getItemsByCreator(address creator) public view returns (uint256[] memory) {
        return creatorItems[creator];
    }
}
