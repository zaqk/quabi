// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.15;

import {Vm} from "forge-std/Vm.sol";

library Quabi {
    Vm constant vm = Vm(address(bytes20(uint160(uint256(keccak256("hevm cheat code"))))));

    function jq(string memory query, string memory path)
        internal
        returns (bytes[] memory response)
    {
        string[] memory inputs = new string[](3);
        inputs[0] = "sh";
        inputs[1] = "-c";
        inputs[2] = string(bytes.concat("./lib/quabi/src/jq.sh ", bytes(query), " ", bytes(path), ""));
        bytes memory res = vm.ffi(inputs);

        response = abi.decode(res, (bytes[]));
    }

    function getPath(string memory contractName) internal returns (string memory path) {
        string[] memory inputs = new string[](3);
        inputs[0] = "sh";
        inputs[1] = "-c";
        inputs[2] = string(bytes.concat("./lib/quabi/src/path.sh ", bytes(contractName), ".json", ""));
        bytes memory res = vm.ffi(inputs);

        path = abi.decode(res, (string));
    }

    function getSelectors(string memory query, string memory path) internal returns (bytes4[] memory) {
        bytes[] memory response = jq(query, path);
        uint256 len = response.length;
        bytes4[] memory selectors = new bytes4[](len);
        for (uint256 i; i < len;) {
            selectors[i] = bytes4(response[i]);
            unchecked {
                ++i;
            }
        }

        return selectors;
    }

    function getFunctions(string memory contractName) internal returns (bytes4[] memory) {
        string memory query = "'[.ast.nodes[-1].nodes[] | if .nodeType == \"FunctionDefinition\" and .kind == \"function\" then .functionSelector else empty end ]'";
        string memory path = getPath(contractName);

        return getSelectors(query, path); 
    }

    function getFunctionsWithModifier(string memory contractName, string memory modifierName) internal returns (bytes4[] memory) {
        string memory query = string(bytes.concat("'[.ast.nodes[-1].nodes[] | if .nodeType == \"FunctionDefinition\" and .kind == \"function\" and ([.modifiers[] | .modifierName.name == \"", bytes(modifierName), "\" ] | any ) then .functionSelector else empty end ]'"));
        string memory path = getPath(contractName);

        return getSelectors(query, path);
    }



    /// TODO need to be able to return an array of objects from the query, requires update to the jq bash script to encode them in the bytes objects and then some way to decode them (likely provided as the first part of the encoding)
    // function getFunctionParams(string memory contractName, bytes4 functionSelector) public returns (bytes4[] memory) {
    //     string memory query = string(bytes.concat("'[.ast.nodes[-1].nodes[] | if .nodeType == \"FunctionDefinition\" and .kind == \"function\" and .functionSelector == \"", bytes(functionSelector), "\" then .parameters[].name else empty end ]'"));
    //     string memory path = getPath(contractName);

        
        
    // }

    /// TODO get events, errors, state variables, etc. 

    


}
