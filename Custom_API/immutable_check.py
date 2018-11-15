from mythril.analysis import solver
from mythril.exceptions import UnsatError
from mythril.mythril import Mythril
from z3 import *


class ImmutableFields:
    def __init__(self, state_variables, contract_name):
        self.contract_name = contract_name

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
        statespaces = mythril.get_raw_statespaces()


    '''
    Return the offset of a state variable given its name
    '''
    def _state_variable_mapping(self, variables):
        pass

