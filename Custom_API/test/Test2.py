from laser.ethereum import svm
from mythril.ether.soliditycontract import SolidityContract
from mythril.analysis import solver
from mythril.exceptions import UnsatError
from z3 import *

address = "0x0000000000000000000000000000000000000000"
contract = SolidityContract("calls.sol")
account = svm.Account(address, contract.disassembly)
accounts = {address: account}
laser = svm.LaserEVM(accounts)
laser.sym_exec(address)

for k in laser.nodes:
    node = laser.nodes[k]
    for state in node.states:
        if (state.get_current_instruction()['opcode'] == 'SSTORE'):
            proposition = node.constraints
            proposition.append(state.mstate.stack[-1] == 4)
            try:
                model = solver.get_model(proposition)
                print("Violation found!")
                for d in model.decls():
                    print("%s = 0x%x\n" % (d.name(), model[d].as_long()))
                    codeinfo = contract.get_source_info(state.get_current_instruction()['address'])

                    print("%s\n%s\n" % (codeinfo.lineno, codeinfo.code))
            except UnsatError:
                pass
print("Analysis completed.")
