"""This module contains functions setting up and executing transactions with
symbolic values."""
import logging

from mythril.laser.smt import symbol_factory
from copy import copy, deepcopy

from mythril.disassembler.disassembly import Disassembly
from mythril.laser.ethereum.cfg import Node, Edge, JumpType
from mythril.laser.ethereum.state.calldata import BaseCalldata, SymbolicCalldata
from mythril.laser.ethereum.state.account import Account
from mythril.laser.ethereum.transaction.transaction_models import (
    MessageCallTransaction,
    ContractCreationTransaction,
    get_next_transaction_id,
)

log = logging.getLogger(__name__)

CREATOR_ADDRESS = 0xAFFEAFFEAFFEAFFEAFFEAFFEAFFEAFFEAFFEAFFE
ATTACKER_ADDRESS = 0xDEADBEEFDEADBEEFDEADBEEFDEADBEEFDEADBEEF
FUNCTION_DEPENDENCY_RAW = {}
FUNCTION_DEPENDENCY_WAW = {}


def heuristic_message_call(laser_evm, callee_address: str, heuristic, transaction_count, disassembly):
    if len(laser_evm.open_states) > 0 and len(laser_evm.open_states[0].transaction_sequence) >= 2:
        heuristic_message_call_helper(laser_evm, callee_address, transaction_count, heuristic, disassembly)
    else:
        execute_message_call(laser_evm, callee_address, disassembly)


def heuristic_message_call_helper(laser_evm, callee_address: str, transaction_count, priority, disassembly):
    open_states = laser_evm.open_states[:]
    del laser_evm.open_states[:]


    for open_state in open_states:
        if open_state[callee_address].deleted:
            log.debug("Can not execute dead contract, skipping.")
            continue

        last_func_called = open_state.node.function_name
        base_explore = set(priority['dependency'][last_func_called].keys())\
                    if last_func_called in priority['dependency'].keys() else set()

        if len(open_state.transaction_sequence) == transaction_count:
            if transaction_count == 2:
                if base_explore is None or len(base_explore) == 0:
                    continue
                open_state.next_explores = base_explore
            else:
                open_state.next_explores = open_state.last_func

        elif len(open_state.transaction_sequence) == 2:
            next_explores = priority['permutation'][disassembly.function_name_to_address[last_func_called]] \
                if disassembly.function_name_to_address[last_func_called] in priority['permutation'].keys() else None

            last_explore = priority['dependency'][last_func_called].keys() \
                if last_func_called in priority['dependency'].keys() else None

            next_explores = set(next_explores).union(base_explore)
            if next_explores is None or len(next_explores) == 0 or last_explore is None or len(last_explore) == 0:
                continue

            open_state.root_func = last_func_called
            open_state.last_func = set(last_explore)

            open_state.next_explores = next_explores
        else:
            next_explores = priority['permutation'][open_state.root_func] \
                if open_state.root_func in priority['permutation'].keys() else None

            next_explores = set(next_explores).union(base_explore)
            if next_explores is None or len(next_explores) == 0:
                continue

            open_state.next_explores = next_explores

        next_transaction_id = get_next_transaction_id()
        transaction = MessageCallTransaction(
            world_state=open_state,
            identifier=next_transaction_id,
            gas_price=symbol_factory.BitVecSym(
                "gas_price{}".format(next_transaction_id), 256
            ),
            gas_limit=8000000,  # block gas limit
            origin=symbol_factory.BitVecSym(
                "origin{}".format(next_transaction_id), 256
            ),
            caller=symbol_factory.BitVecVal(ATTACKER_ADDRESS, 256),
            callee_account=open_state[callee_address],
            call_data=SymbolicCalldata(next_transaction_id),
            call_value=symbol_factory.BitVecSym(
                "call_value{}".format(next_transaction_id), 256
            ),
        )

        # the open states from last iterations are appended to work list here
        _setup_global_state_for_execution(laser_evm, transaction, open_state.node.function_name)

    laser_evm.exec(disassembly, priotity=priority)


def execute_message_call(laser_evm, callee_address: str, disassembly) -> None:

    """ Executes a message call transaction from all open states """
    # TODO: Resolve circular import between .transaction and ..svm to import LaserEVM here
    # TODO: if the function of openstate.node.funcname is not in priority list, dont add it
    # TODO: This is for deleting repeated variables read
    # copy the open states from last iteration to this iteration
    # The working list is always empty when an iteration is done
    open_states = laser_evm.open_states[:]
    del laser_evm.open_states[:]

    for open_world_state in open_states:
        if open_world_state[callee_address].deleted:
            log.debug("Can not execute dead contract, skipping.")
            continue

        next_transaction_id = get_next_transaction_id()
        transaction = MessageCallTransaction(
            world_state=open_world_state,
            identifier=next_transaction_id,
            gas_price=symbol_factory.BitVecSym(
                "gas_price{}".format(next_transaction_id), 256
            ),
            gas_limit=8000000,  # block gas limit
            origin=symbol_factory.BitVecSym(
                "origin{}".format(next_transaction_id), 256
            ),
            caller=symbol_factory.BitVecVal(ATTACKER_ADDRESS, 256),
            callee_account=open_world_state[callee_address],
            call_data=SymbolicCalldata(next_transaction_id),
            call_value=symbol_factory.BitVecSym(
                "call_value{}".format(next_transaction_id), 256
            ),
        )

        # the open states from last iterations are appended to work list here
        _setup_global_state_for_execution(laser_evm, transaction, open_world_state.node.function_name)

    laser_evm.exec(disassembly)


def execute_contract_creation(
    laser_evm, contract_initialization_code, contract_name=None
) -> Account:
    """Executes a contract creation transaction from all open states.

    :param laser_evm:
    :param contract_initialization_code:
    :param contract_name:
    :return:
    """
    # TODO: Resolve circular import between .transaction and ..svm to import LaserEVM here
    open_states = laser_evm.open_states[:]
    del laser_evm.open_states[:]

    new_account = laser_evm.world_state.create_account(
        0, concrete_storage=True, dynamic_loader=None
    )
    if contract_name:
        new_account.contract_name = contract_name

    for open_world_state in open_states:
        next_transaction_id = get_next_transaction_id()
        transaction = ContractCreationTransaction(
            world_state=open_world_state,
            identifier=next_transaction_id,
            gas_price=symbol_factory.BitVecSym(
                "gas_price{}".format(next_transaction_id), 256
            ),
            gas_limit=8000000,  # block gas limit
            origin=symbol_factory.BitVecSym(
                "origin{}".format(next_transaction_id), 256
            ),
            code=Disassembly(contract_initialization_code),
            caller=symbol_factory.BitVecVal(CREATOR_ADDRESS, 256),
            callee_account=new_account,
            call_data=[],
            call_value=symbol_factory.BitVecSym(
                "call_value{}".format(next_transaction_id), 256
            ),
        )
        _setup_global_state_for_execution(laser_evm, transaction)
    laser_evm.exec(True)

    return new_account

def _setup_global_state_for_execution(laser_evm, transaction, last_func_called=None) -> None:
    """Sets up global state and cfg for a transactions execution.

    :param laser_evm:
    :param transaction:
    :param last_func_called:
    """

    # TODO: Resolve circular import between .transaction and ..svm to import LaserEVM here
    global_state = transaction.initial_global_state(last_func_called=last_func_called)
    global_state.transaction_stack.append((transaction, None))

    new_node = Node(
        global_state.environment.active_account.contract_name,
        function_name=global_state.environment.active_function_name,
    )
    if laser_evm.requires_statespace:
        laser_evm.nodes[new_node.uid] = new_node

    if transaction.world_state.node:
        if laser_evm.requires_statespace:
            laser_evm.edges.append(
                Edge(
                    transaction.world_state.node.uid,
                    new_node.uid,
                    edge_type=JumpType.Transaction,
                    condition=None,
                )
            )

        global_state.mstate.constraints += transaction.world_state.node.constraints
        new_node.constraints = global_state.mstate.constraints

    global_state.world_state.transaction_sequence.append(transaction)
    global_state.node = new_node
    new_node.states.append(global_state)
    laser_evm.work_list.append(global_state)
