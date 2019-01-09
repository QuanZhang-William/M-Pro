from Custom_API.CustomCheck import CustomCheck
from Custom_API.utils import Action
from Custom_API.utils import Condition
import sys
sys.path.insert(0, '/Users/apple/git/slither/slither')
sys.path.insert(0, '/Users/apple/git/slither')

file_name = "example_contracts/calls.sol"
contract_name = "Caller"
call_depth = 1
custom_check = CustomCheck(file_name, contract_name, call_depth)

custom_check.custom_check(Condition.SUICIDE, [Action.CHECK_UNRESTRICTED_CALL])
custom_check.custom_check(Condition.EXTERNAL_CALL, [Action.CHECK_STATE_VARIABLE_VALUE], target_variable="manager")
custom_check.generate_report()
