from Custom_API.modules import SanityCheck
import pkgutil
from mythril.analysis import solver
from mythril.exceptions import UnsatError
from mythril.laser.ethereum.util import get_concrete_int
import logging


class CustomCheck:
    state_spaces = None
    conditions = []
    actions = []
    offset_mapping = {}

    def __init__(self, state_spaces, conditions = None, actions = None, offset_mapping={}):
        self.state_spaces = state_spaces

        if conditions is not None:
            for condition in conditions:
                self.conditions.append(condition)

        if actions is not None:
            for action in actions:
                self.actions.append(action)

        self.offset_mapping = offset_mapping


    '''
    Invoke original Mythril analysis module of:
        dependence on predictable vars
        deprecated ops
        integer
        transaction order dependency
        unchecked return value
    '''
    def sanity_check(self):
        _modules = []
        issues = []
        for loader, name, is_pkg in pkgutil.walk_packages(SanityCheck.__path__):
            _modules.append(loader.find_module(name).load_module(name))

        for module in _modules:
            temp = module.execute(self.state_spaces)
            issues += temp

    def check_unrestricted_write(self, target_state_variable):
        pass

    def immutable_check(self, target_state_variable):
        constructor_flag = {}
        for name in self.offset_mapping:
            constructor_flag[name] = True

        # analyze
        for account in self.state_spaces.sstors.values():
            for group in account.values():
                for state in group:

                    # if the write is in constructor, it is not a violation
                    # TODO: there should be some testing here regarding the first write

                    offset = None
                    name = ''
                    if target_state_variable in self.offset_mapping:
                        offset = self.offset_mapping[target_state_variable]
                        name = target_state_variable
                    else:
                        raise Exception("State Variable Offset Mapping not found")

                    # check the offset
                    writing_to = state.state.mstate.stack[-1]

                    if get_concrete_int(writing_to) != offset:
                        continue

                    # if it is first time modify the value
                    if constructor_flag[name]:
                        constructor_flag[name] = False
                        continue

                    proposition = state.state.mstate.constraints
                    #proposition.append(state.state.mstate.stack[-1] == offset)

                    try:
                        model = solver.get_model(proposition)
                        print("Violation found!")
                        pretty_model = solver.pretty_print_model(model)
                        #print(pretty_model)
                        for d in model.decls():
                            name = d.name()
                            value = model[d]

                            print(name)
                            print('is')
                            print(value)
                            print('\n')

                            print("%s = 0x%s\n" % (d.name(), model[d].as_long()))

                        codeinfo = self.contract_name.get_source_info(state.state.get_current_instruction()['address'])
                        print("%s\n%s\n" % (codeinfo.lineno, codeinfo.code))

                    except UnsatError:
                        pass

    def suicide_check(self):
        pass

    '''
    Custom Checks
    '''
    def custom_check(self, conditions, actions):
        conditions = []
        actions = []
        state_space = None

        for condition in self.conditions:
            if condition == "external_call":
                for state in self.state_space.calls:
                    pass

    def _check_from_original_value(self):
        pass

    def _check_unrestricted_call(self):
        pass

    def _check_against_state_variable(self):
        pass

    def _allowed_state_change_after_external_call(self):
        pass



