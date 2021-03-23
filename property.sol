pragma solidity 0.4.23;

contract PropertyTransfer{
    address public da; // da stands for development authority
    uint public totalNoOfProperty;
    
    function PropertyTransfer() public{
        da = msg.sender;
    }
    
    modifier onlyOwner(){ // will check if msg.sender == da
        require(msg.sender == da);
        _;
    }
    
    struct Property{
        string name;
        bool isSold;
    }
    
    mapping(address=>mapping(uint256=>Property)) public propertiesOwner;
    mapping(address=>uint256) individualCountOfPropertyPerOwner;
    
    event PropertyAlloted(address indexed _verifiedOwner, uint256 indexed _totalNoOfPropertyCuurrently, string _propertyName, string _msg);
    event PropertyTransferred(address indexed _from, address indexed _to, string _propertyName, string _msg);
    
    function getPropertyCountOfAnyAddress(address _ownerAddress) constant returns(uint256){
        uint count = 0;
        for(uint i = 0; i < individualCountOfPropertyPerOwner[_ownerAddress]; i++){
            if(propertiesOwner[_ownerAddress][i].isSold == true){
                count++;
            }
        }
        return count;
    }
    
    function allotProperty(address _verifiedOwner, string _propertyName) onlyOwner{
        propertiesOwner[_verifiedOwner][individualCountOfPropertyPerOwner[_verifiedOwner]++].name = _propertyName;
        totalNoOfProperty++;
        PropertyAlloted(_verifiedOwner, individualCountOfPropertyPerOwner[_verifiedOwner], _propertyName, "Property Alloted Successfully");
    }
    
    function isOwner(address _checkOwnerAddress, string _propertyName) constant returns(uint){
        uint i = 0;
        bool flag;
        for(i = 0; i < individualCountOfPropertyPerOwner[_checkOwnerAddress]; i++){
            if(propertiesOwner[_checkOwnerAddress][i].isSold == true){
                break;
            }
            flag = stringsEqual(propertiesOwner[_checkOwnerAddress][i].name, _propertyName);
            if(flag == true){
                break;
            }
        }
        if(flag == true){
            return i;
        }
        else{
            return 99999;
        }
    }
    
    function stringsEqual(string a1, string a2) constant returns(bool){
        return sha3(a1) == sha3(a2) ? true : false;
    }
    
    function transferProperty(address _to, string _propertyName) returns(bool, uint){
        uint256 checkOwner = isOwner(msg.sender, _propertyName);
        bool flag;
        if(checkOwner != 99999 && propertiesOwner[msg.sender][checkOwner].isSold == false){
            propertiesOwner[msg.sender][checkOwner].isSold = true;
            propertiesOwner[msg.sender][checkOwner].name = "Sold";
            propertiesOwner[_to][individualCountOfPropertyPerOwner[_to]++].name = _propertyName;
            
            flag = true;
            PropertyTransferred(msg.sender, _to, _propertyName, "Owner has been changed");
        }
        else{
            flag = false;
            PropertyTransferred(msg.sender, _to, _propertyName, "Owner doesn't own the property");
        }
        return(flag, checkOwner);
    }
}