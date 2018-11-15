from mythril.analysis import solver
from mythril.exceptions import UnsatError
from mythril.mythril import Mythril
from z3 import *
import re


'''
When performing a storage write (updating balance) or state variable write, check if
    1) the caller is the owner, or creator
    2) if the write is unrestricted by the caller, it is a quick violation
'''
class CheckRetrictedWrite:
    def __init__(self, target_state_variable, authorizer):
        self.target_state_variable = target_state_variable
        self.authorizer = authorizer

    def execute(self):
        self.static_check()
        self.quick_check()
        self.symbolic_check()


    def static_check(self):
        pass

    def quick_check(self):
        pass

    def symbolic_check(self):
        # load Mythril
        mythril = Mythril()
        mythril.load_from_solidity(self.contract_name)

        # get statespaces
        statespaces = mythril.get_raw_statespaces()



        # analyze
        for state in statespaces.sstors:

            # if the write is unrestricted by the caller, it is a violation
            if re.search(r"caller", str(state.constraints)) and re.search(r"[0-9]{20}", str(state.constraints)):
                print("unrestricted write found")
                break


            additional_constraints = []

            if len(state.world_state.transaction_sequence) > 1:
                creator = state.world_state.transaction_sequence[0].caller
                # TODO: DEBUG REQUIRED
                owner = state.mstate.storage[0]
                for transaction in state.world_state.transaction_sequence[1:]:

                    # check against the original owner
                    additional_constraints.append(
                        Not(Extract(159, 0, transaction.caller) == Extract(159, 0, creator)))

                    # check against current field (owner)
                    additional_constraints.append(
                        Not(Extract(159, 0, transaction.caller) == Extract(159, 0, owner)))

                    additional_constraints.append()
                    additional_constraints.append(
                        Not(Extract(159, 0, transaction.caller) == 0)
                    )


            try:
                model = solver.get_model(state.constraints + additional_constraints)
                print("Violation found!")

                for d in model.decls():
                    print("%s = 0x%x\n" % (d.name(), model[d].as_long()))

                codeinfo = self.contract_name.get_source_info(state.get_current_instruction()['address'])
                print("%s\n%s\n" % (codeinfo.lineno, codeinfo.code))

            except UnsatError:
                pass

