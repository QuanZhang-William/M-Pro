from Custom_API.CustomCheck import CustomCheck
from Custom_API.utils import Action
from Custom_API.utils import Condition
import sys
sys.path.insert(0, '/Users/apple/git/slither/slither')
sys.path.insert(0, '/Users/apple/git/slither')


file_name = "example_contracts/immutableExample.sol"
contract_name = "UnristrictedWrite"
call_depth = 1
custom_check = CustomCheck(file_name, contract_name, call_depth)
custom_check.immutable_check("b")
custom_check.generate_report()
