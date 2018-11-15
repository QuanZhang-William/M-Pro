from Custom_API.values import *
from mythril.mythril import Mythril
from Custom_API.CustomCheck import CustomCheck
from mythril.analysis import symbolic
from Custom_API.utils import StateVariableParser


import sys

import sys
sys.path.insert(0, '/Users/apple/git/slither/slither')
sys.path.insert(0, '/Users/apple/git/slither')
print(sys.path)
from slither import slither


print(sys.path)

slither1 = slither.Slither('calls.sol')
contract = slither1.get_contract_from_name('Caller22')
var_a = contract.get_all_state_variables()

sp = StateVariableParser(var_a)
mapping = sp.parse()


# load Mythril
contract_name = ['calls.sol']
mythril = Mythril()
mythril.load_from_solidity(contract_name)

for contract in mythril.contracts:
    sym = symbolic.SymExecWrapper(
                    contract,
                    address,
                    strategy,
                    dynloader=None,
                    max_depth=max_depth,
                    execution_timeout=execution_timeout,
                    create_timeout=create_timeout,
                    max_transaction_count=max_transaction_count,
                )

nodes = sym.nodes
edges = sym.edges
calls = sym.calls
sstores = sym.sstors

custom_check = CustomCheck(sym, offset_mapping=mapping)
custom_check.immutable_check("a")
