// SPDX-License-Identifier: MIT


pragma solidity^0.8.0;




library IterableMapping
{
    struct Map{
        address[] keys;
        mapping(address=>uint256) value;
        mapping(address=>uint256) indexOf;
        mapping(address=>bool) inserted;
    }



    function set(Map storage map, address key, uint256 value) public 
    {
        if(map.inserted[key])
        {
            map.value[key] = value;
        }
        else
        {
            map.inserted[key] = true;
            map.value[key] = value;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function getKeyAtIndex(Map storage map, uint256 _index) public view returns(address)
    {
        return map.keys[_index];
    }

    function getvalue(Map storage map, address _key) public view returns(uint256)
    {
        return map.value[_key];
    }


     function getIndexFromKey(Map storage map, address _key) public view returns(uint256)   
    {
        return map.indexOf[_key];
    }

    function isInserted(Map storage map, address _key) public view returns(bool)
    {
        return map.inserted[_key];
    }


     function getKeyCount(Map storage map) public view returns(uint)
    {
        return map.keys.length;
    }

     function getAllKeys(Map storage map) public view returns(address[] memory)
    {
        return map.keys;
    }

    function remove(Map storage map, address _key) public 
    {
        if(!map.inserted[_key])
        {
            return;
        }
        else
        {
            delete map.inserted[_key];
            delete map.value[_key];

            uint index = map.indexOf[_key];
            address lastKey = map.keys[map.keys.length - 1];

            map.indexOf[lastKey] = index;
            delete map.indexOf[_key];

            map.keys[index] = lastKey;
            // delete mapp.key[mapp.key.length];
            map.keys.pop();

        }
    }

}


contract TestIterableMap {
    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private map;

    function setInMapping(address key, uint256 val) public {
        map.set(key, val);
    }

    function remove(address key) public {
        map.remove(key);
    }

    function getKeyAtIndex(uint256 _index) public view returns(address)
    {
        return map.keys[_index];
    }

    function getvalue(address _key) public view returns(uint256)
    {
        return map.value[_key];
    }


     function getIndexFromKey(address _key) public view returns(uint256)   
    {
        return map.indexOf[_key];
    }

    function isInserted(address _key) public view returns(bool)
    {
        return map.inserted[_key];
    }


     function getKeyCount() public view returns(uint)
    {
        return map.keys.length;
    }

    function getAllKeys() public view returns(address[] memory)
    {
        return map.keys;
    }

   
}
