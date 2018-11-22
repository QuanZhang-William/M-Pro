from Custom_API.modules import SanityCheck
import pkgutil
from mythril.analysis import solver
from mythril.exceptions import UnsatError
from mythril.analysis.report import Issue
from mythril.analysis.report import Report
from mythril.laser.ethereum.transaction.transaction_models import ContractCreationTransaction
from Custom_API.utils import Condition
from Custom_API.utils import Action

import re
from z3 import *
import logging


class CustomCheck:
    contract = None
    state_spaces = None
    conditions = []
    actions = []
    offset_mapping = {}
    issues = []

    def __init__(self, contract, state_spaces, conditions = None, actions = None, offset_mapping={}):
        self.state_spaces = state_spaces
        self.contract = contract

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

    '''
    When performing a storage write (updating balance) or state variable write, check if
        1) the caller is the owner, or creator
        2) if the write is unrestricted by the caller, it is a quick violation
    '''
    def check_unrestricted_write(self, target_state_variable):
        # analyze
        offset, _ = self._get_storage_offset(target_state_variable)

        for account in self.state_spaces.sstors.values():
            for index in account.values():
                for sstore in index:

                    #skip the constructor
                    if isinstance(sstore.state.current_transaction, ContractCreationTransaction):
                        continue

                    if sstore.state.mstate.stack[-1] == offset:
                        issue = self._check_unrestricted_write_helper(sstore)
                        if len(issue) > 0:
                            self.issues.append(issue)

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

                    proposition = state.state.mstate.constraints
                    proposition.append(writing_to == offset)

                    try:
                        model = solver.get_model(proposition)

                        # if it is first time modify the value
                        if constructor_flag[name]:
                            constructor_flag[name] = False
                            continue

                        print("Violation found!")
                        debug = solver.get_transaction_sequence(state.state, proposition)

                        issue = Issue(
                            contract=state.state.node.contract_name,
                            function_name=state.state.node.function_name,
                            address=state.state.instruction["address"],
                            swc_id="Tainted State Variable",
                            bytecode=state.state.environment.code.bytecode,
                            title="Tainted State Variable",
                            _type="Warning",
                            #description=description,
                            debug=debug,
                        )

                        self.issues.append(issue)
                        issue.add_code_info(self.contract)


                    except UnsatError:
                        print('writting to offeset is unsat, skipping \n')


        print('immutable check complete\n')

    def suicide_check(self):
        pass

    @staticmethod
    def _check_against_creator(self, state):
        additional_constraints = []

        if len(state.world_state.transaction_sequence) > 1:
            creator = state.world_state.transaction_sequence[0].caller

            # if custom_target is not provided, check against the creator by default
            for transaction in state.world_state.transaction_sequence[1:]:
                # check against the original owner
                additional_constraints.append(
                    Not(Extract(159, 0, transaction.caller) == Extract(159, 0, creator)))

    def _check_against_state_variable(self, call, offset):
        proposition = call.state.mstate.constraints
        storage_value = None
        accountss = call.state.accounts
        for key, value in accountss.items():
            if key != '0x0000000000000000000000000000000000000000':
                try:
                    storage_value = value.storage._storage[offset]

                except:
                    print ('offset not found, skipping')
                    return
        storage_value_str = str(storage_value)
        #TODO: Require more parsing debugging
        if 'Concat(0' in storage_value_str:
            storage_value_str = storage_value_str[9:-1]

        if not storage_value_str in str(proposition):
            print('check against_state_variable issue found')
            debug = solver.get_transaction_sequence(call.state, proposition)

            issue = Issue(
                contract=call.state.node.contract_name,
                function_name=call.state.node.function_name,
                address=call.state.instruction["address"],
                swc_id="Unrestricted call to State Variable",
                bytecode=call.state.environment.code.bytecode,
                title="Unrestricted call to State Variable",
                _type="Warning",
                # description=description,
                debug=debug)

            print("unrestricted call found")
            return issue


    def _check_state_variable_value(self):
        pass

    def _check_unrestricted_caller(self, call, offset=None):
        proposition = call.state.mstate.constraints
        issue = []
        try:
            model = solver.get_model(proposition)
            # if the CALL is unrestricted by the caller, it is a violation
            if not re.search(r"caller", str(proposition)) and re.search(r"caller", str(call.to)):
                print("the caller is constrained to the write")

            else:
                debug = solver.get_transaction_sequence(call.state, proposition)

                issue = Issue(
                    contract=call.state.node.contract_name,
                    function_name=call.state.node.function_name,
                    address=call.state.instruction["address"],
                    swc_id="Unrestricted call to State Variable",
                    bytecode=call.state.environment.code.bytecode,
                    title="Unrestricted call to State Variable",
                    _type="Warning",
                    # description=description,
                    debug=debug)

                print("unrestricted call found")
            return issue

        except:
            print('unsat condition, skipping')

    def _allowed_state_change_after_external_call(self):
        pass

    @staticmethod
    def _check_unrestricted_condition(self, state, custom_target):
        offset = None
        name = ''
        if custom_target in self.offset_mapping:
            offset = self.offset_mapping[custom_target]
            name = custom_target
        else:
            raise Exception("State Variable Offset Mapping not found")

        # if the write to is not target
        write_to = state.state.mstate.stack[-1]
        if write_to != offset:
            return

        for transaction in state.world_state.transaction_sequence[1:]:
            # check against current field (owner)
            additional_constraints.append(
                Not(Extract(159, 0, transaction.caller) == Extract(159, 0, owner)))

            additional_constraints.append()
            additional_constraints.append(
                Not(Extract(159, 0, transaction.caller) == 0)
            )

    @staticmethod
    def _check_unrestricted_write_helper(state):

        proposition = state.state.mstate.constraints
        issue = []
        try:
            model = solver.get_model(proposition)
            # if the write is unrestricted by the caller, it is a violation
            if re.search(r"caller", str(proposition)):# and re.search(r"[0-9]{20}", str(proposition)):
                print("the caller is constrained to the write")
            else:
                debug = solver.get_transaction_sequence(state.state, proposition)

                issue = Issue(
                    contract=state.state.node.contract_name,
                    function_name=state.state.node.function_name,
                    address=state.state.instruction["address"],
                    swc_id="Unrestricted write to State Variable",
                    bytecode=state.state.environment.code.bytecode,
                    title="Unrestricted write to State Variable",
                    _type="Warning",
                    # description=description,
                    debug=debug)

                print("unrestricted write found")
            return issue

        except:
            print('unsat condition, skipping')

    def generate_report(self):
        report = Report(True)

        if len(self.issues) > 0:
            for issue in self.issues:
                report.append_issue(issue)

        outputs = {
            "json": report.as_json(),
            "text": report.as_text(),
            "markdown": report.as_markdown(),
        }

        print(outputs['text'])

    def _get_storage_offset(self, target_state_variable):
        offset = None
        name = ''
        if target_state_variable in self.offset_mapping:
            offset = self.offset_mapping[target_state_variable]
            name = target_state_variable

            return offset, name
        else:
            raise Exception("State Variable Offset Mapping not found")

    '''
    Custom Checks
    '''
    def custom_check(self, conditions, actions, offset = None):
        # parse actions
        func_dict = {Action.CHECK_CALLER_AGAINST_STATE_VARIABLE: self._check_against_state_variable,
                     Action.CHECK_STATE_VARIABLE_VALUE: self._check_state_variable_value,
                     Action.CHECK_UNRESTRICTED_CALL: self._check_unrestricted_caller}

        instructions = []
        # parse conditions
        if Condition.EXTERNAL_CALL or Condition.ETHER_SEND in conditions:
            instructions.append('CALL')
            if self.state_spaces.calls is not None and len(self.state_spaces.calls) != 0:
                for call in self.state_spaces.calls:
                    for action in actions:
                        self.issues.append(func_dict[action](call, offset))


        if Condition.SUICIDE in conditions:
            instructions.append('SUICIDE')


