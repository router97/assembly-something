string = """:
        dd {%0+%3}, {%1+%3}, {%2-%3}, 0.0
        dd {%0+%3}, {%1-%3}, {%2-%3}, 0.0
        dd {%0-%3}, {%1+%3}, {%2-%3}, 0.0
        dd {%0-%3}, {%1-%3}, {%2-%3}, 0.0

        dd {%0+%3}, {%1+%3}, {%2+%3}, 0.0
        dd {%0+%3}, {%1-%3}, {%2+%3}, 0.0
        dd {%0-%3}, {%1+%3}, {%2+%3}, 0.0
        dd {%0-%3}, {%1-%3}, {%2+%3}, 0.0
"""

# cubes = [

#     [1, 0, 3.5, 0.25],
#     [0, -1, 3.5, 0.25],
#     [-1, 0, 3.5, 0.25],
#     [0, 1, 3.5, 0.25],

# ]
z = 3.5
size = 0.25

import math
cubes = []
cubes_amount = 24
step = 360 / cubes_amount
current_degree = step
pi180 = math.pi / 180
for i in range(cubes_amount):
    current_radian = current_degree * pi180
    cubes.append(
        [math.cos(current_degree), math.sin(current_degree), z, size]
    )
    current_degree += step



name = 'cube'

def replace_percent_with_values(string: str, values: list) -> str:
    for i, value in enumerate(values):
        latest_found = 0
        search = f"%{i}"
        while True:
            latest_found = string.find(search, latest_found)
            if latest_found == -1:
                break
            string = string[0:latest_found] + str(value) + string[latest_found+len(search):]
    return string

def evaluate_expressions(string: str) -> str:
    latest_found = 0
    search = "{"
    end = "}"
    while True:
        latest_found = string.find(search, latest_found)
        if latest_found == -1:
            break
        end_pos = string.find(end, latest_found)

        expression = string[latest_found+1:end_pos]
        result = str(round(eval(expression), 3))

        string = string[:latest_found] + result + string[end_pos+1:]
    return string



with open('3d_1.txt', 'w') as fl:
    for i, cube in enumerate(cubes):
        result = string
        result = replace_percent_with_values(result, cube)
        result = f"cube{i}{result}"
        result = evaluate_expressions(result)
        fl.write(result)
