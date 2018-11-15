from mythril.analysis import solver
from mythril.exceptions import UnsatError
from mythril.mythril import Mythril
from z3 import *
from abc import ABCMeta, abstractmethod
import sys
sys.path.insert(0, '/Users/apple/git/slither/slither')
sys.path.insert(0, '/Users/apple/git/slither')

from slither.core.solidity_types import ArrayType
from slither.core.solidity_types import UserDefinedType
from slither.core.solidity_types import MappingType
from slither.solc_parsing.declarations.structure import StructureSolc
from slither.core.declarations.enum import Enum
from slither.core.expressions import  *

import binascii
import sha3

class Condition:
    ETHER_SEND = "ether_send"
    EXTERNAL_CALL = "external_call"
    SUICIDE = "suicide"


class Action:
    CHECK_FROM_ORIGINAL_VALUE = "check_from_original_value"
    CHECK_UNRESTRICTED_CALL = "check_unrestricted_call"
    CHECK_AGAINST_STATE_VARIABLE = "check_against_state_variable"
    ALLOWED_STATE_CHANGE_AFTER_EXTERNAL_CALL = "allowed_state_change_after_external_call"


class StateVariableParser:
    state_variables = []

    def __init__(self, state_variables=[]):
        self.state_variables = state_variables

    def parse(self):
        mapping = {}
        offset = 0
        for state_variable in self.state_variables:
            if isinstance(state_variable.type, ArrayType):

                value = []
                # set up the array object first
                value.append(offset)
                offset += 1

                # Dynamic array type
                if state_variable.type.length is None:
                    sha256_offset = self._calculate_storage_offset(offset)
                    count = 0
                    for _ in state_variable.expression.expressions:
                        value.append(sha256_offset + str(count))
                        count += 1

                    mapping[state_variable.name] = value

                else:
                    for _ in state_variable.expression.expressions:
                        value.append(offset)
                        offset += 1

                    mapping[state_variable.name] = value

            # User Defined structue
            elif isinstance(state_variable.type, UserDefinedType):

                # Structure
                if isinstance(state_variable.type.type, StructureSolc):

                    values = []
                    for _ in state_variable.type.type.elems:
                        values.append(offset)
                        offset += 1

                    mapping[state_variable.name] = values

                # Enum
                elif isinstance(state_variable.type.type, Enum):
                    # TODO: Implement it
                    raise Exception("Enum Not Implemented")

            # Mapping type
            elif isinstance(state_variable.type, MappingType):
                print('Cannot parse mapping type, skipping');

            # For simple variables, offset is simply the sequence
            else:
                mapping[state_variable.name] = offset
                offset += 1

        return mapping

    def _calculate_storage_offset(self, key, position = None):
        if position is None:
            return self._keccak256(self._bytes32(key))

        return self._keccak256(self._bytes32(key) + self._bytes32(position))

    # Convert a number to 32 bytes array.
    def _bytes32(self, i):
        return binascii.unhexlify('%064x' % i)

    # Calculate the keccak256 hash of a 32 bytes array.
    def _keccak256(self, x):
        return sha3.keccak_256(x).hexdigest()
