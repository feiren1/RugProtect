//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface ISpeeDrive {
    event RampPairCreated(string onRampName, string offRampName);
    event RampEntered(string name, address driver);
    event RampExited(string name, address driver, uint256 fee);

    /**
        @notice creates a new ramp location
        @dev creates a new ramp, emits RampCreated
        Must check if ramp already exists
        @param onRampName The name of the on ramp in the ramp pair
        @param offRampName The name of the off ramp in the ramp pair
        @param fee The fee charged upon exit for this ramp pair
     */
    function createRampPair(
        string calldata onRampName,
        string calldata offRampName,
        uint256 fee
    ) external;

    /**
        @notice Makes a ramp pair inactive, fee will not be charged for ramp
        @dev Can only be called by the contract owner
        @param onRampName The name of the on ramp in the ramp pair
        @param offRampName The name of the off ramp in the ramp pair
     */
    function turnOffRampPair(
        string calldata onRampName,
        string calldata offRampName
    ) external;

    /**
        @notice driver enters ramp
        @dev checks if ramp exists, check if balance of driver exceeds allowance, set allowance for contract, checks if ramp is on ramp
        @param name The name of the ramp the driver is entering
     */
    function enterRamp(string calldata name) external;

    /**
        @notice driver exits ramp
        @dev checks if ramp exists, check if ramp is off ramp, deduct fee from allowance
        @param name The name of the ramp the driver is exiting
     */
    function exitRamp(string calldata name) external payable;
}

contract SpeeDrive is ISpeeDrive, Ownable, Pausable {
    struct RampPair {
        bool exists;
        bool isAlive;
        uint256 fee;
    }
    mapping(bytes32 => RampPair) private _rampPairs;
    mapping(address => string) private _driverOnRamps;
    mapping(address => bool) private _driverIsOnHighway;
    ERC20 internal _spd;

    function setSPD(address a) external onlyOwner {
        _spd = ERC20(a);
    }

    function togglePause() external onlyOwner {
        paused() ? _unpause() : _pause();
    }

    function createRampPair(
        string calldata onRampName,
        string calldata offRampName,
        uint256 fee
    ) external override whenNotPaused {
        RampPair storage r = _rampPairs[getRampPairId(onRampName, offRampName)];
        require(!r.exists, "Ramp exists");
        r.exists = true;
        r.isAlive = true;
        r.fee = fee;
        emit RampPairCreated(onRampName, offRampName);
    }

    function turnOffRampPair(
        string calldata onRampName,
        string calldata offRampName
    ) external override onlyOwner {}

    function enterRamp(string calldata name) external override whenNotPaused {
        require(!_driverIsOnHighway[msg.sender], "Driver already on highway");
        require(
            _spd.allowance(msg.sender, address(this)) >= 10,
            "Allowance does not exceed 10 SPD"
        );
        _driverIsOnHighway[msg.sender] = true;
        _driverOnRamps[msg.sender] = name;
        emit RampEntered(name, msg.sender);
    }

    function exitRamp(
        string calldata name
    ) external payable override whenNotPaused {
        require(_driverIsOnHighway[msg.sender], "Driver is not on highway");
        _driverIsOnHighway[msg.sender] = false;
        RampPair storage r = _rampPairs[
            _getExistingRampPairId(_driverOnRamps[msg.sender], name)
        ];
        require(r.exists, "Ramp pair does not exist");
        require(r.isAlive, "Ramp pair is not active");
        _spd.transferFrom(msg.sender, address(this), r.fee);
        emit RampExited(name, msg.sender, r.fee);
    }

    function getRampPair(
        bytes32 rampPairId
    ) external view returns (RampPair memory) {
        return _rampPairs[rampPairId];
    }

    function getRampPairId(
        string calldata onRampName,
        string calldata offRampName
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(onRampName, offRampName));
    }

    function _getExistingRampPairId(
        string storage onRampName,
        string calldata offRampName
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(onRampName, offRampName));
    }
}
