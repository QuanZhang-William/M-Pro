import sys
sys.path.insert(0, '/Users/apple/git/slither/slither')
sys.path.insert(0, '/Users/apple/git/slither')
print(sys.path)
from slither import slither
import itertools

file_name = 'dependency.sol'
contract = 'Caller'

slither1 = slither.Slither(file_name)
contract = slither1.get_contract_from_name(contract)


# Get the variable
var_a = contract.get_state_variable_from_name('a')

# Get the functions writing the variable
functions_writing_a = contract.get_functions_writing_to_variable(var_a)
functions_reading_a = contract.get_functions_reading_from_variable(var_a)

class MappingObj:
    function_name = ''
    function_hash= ''
    entry_point = ''

    def __init__(self, name, hash, entry):
        self.function_name = name
        self.function_hash = hash
        self.entry_point = entry





writing_list = []
reading_list = []

for write in functions_writing_a:
    if write.visibility == 'public':
        writing_list.append(write)

for read in functions_reading_a:
    if read.visibility == 'public':
        reading_list.append(read)


RAW = []
WAR = []
WAW = []
RAR = []

for write in writing_list:
    for read in reading_list:
        RAW.append([write, read])

for read in reading_list:
    for write in writing_list:
        WAR.append([read, write])

for read1 in reading_list:
    for read2 in reading_list:
        RAR.append([read1, read2])

for write1 in writing_list:
    for write2 in writing_list:
        WAW.append([write1, write])





# Print the result
print('The function writing "a" are {}'.format([f.name for f in functions_writing_a]))
# Print the result
print('The function reading "a" are {}'.format([f.name for f in functions_reading_a]))

# Get the variable
entry_point = contract.get_function_from_signature('readA()')
print(entry_point.visibility)

all_calls = entry_point.all_internal_calls()

all_calls_formated = [f.contract.name + '.' + f.name for f in all_calls]

# Print the result
print('From entry_point the functions reached are {}'.format(all_calls_formated))
