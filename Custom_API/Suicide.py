from mythril.analysis import solver
from mythril.exceptions import UnsatError
from mythril.mythril import Mythril
from z3 import *

'''
Check the msg.sender against authorized killer of the contract
'''
class Suicide:
    def __init__(self, authorized_killer, contract_name):
        self.contract_name = contract_name
        self.authorized_killer = authorized_killer

    def execute(self):
        self.static_check()
        self.quick_check()
        self.symbolic_check()


    def static_check(self):
        pass

    def quick_check(self):
        pass

    def symbolic_check(self):

        #load Mythril
        mythril = Mythril()
        mythril.load_from_solidity(self.contract_name)

        # get statespaces
        state_spaces = mythril.get_raw_statespaces()

        # analyze
        for node in state_spaces.nodes:
            for state in node.states:
                instruction = state.get_current_instruction()
                if instruction["opcode"] != "SUICIDE":
                    continue

                not_creator_constraints = []
                if len(state.world_state.transaction_sequence) > 1:
                    creator = state.world_state.transaction_sequence[0].caller
                    for transaction in state.world_state.transaction_sequence[1:]:
                        not_creator_constraints.append(
                            Not(Extract(159, 0, transaction.caller) == Extract(159, 0, creator))
                        )
                        not_creator_constraints.append(
                            Not(Extract(159, 0, transaction.caller) == 0)
                        )

                # solve the model

    '''
    Return the offset of a state variable given its name
    '''
    def _state_variable_mapping(self, variables):
        pass

