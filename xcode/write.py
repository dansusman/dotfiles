from __future__ import print_function
import lldb
import argparse
import os
import subprocess

def parse_breakpoints(output):
    """Parse breakpoint output and format as Filename:LineNumber"""
    import re
    lines = output.strip().split('\n')
    formatted_lines = []
    
    for line in lines:
        # Match lines with file and line number
        match = re.search(r"file = '([^']+)', line = (\d+)", line)
        if match:
            filepath = match.group(1)
            line_number = match.group(2)
            filename = os.path.basename(filepath)
            formatted_lines.append(f"{filename}:{line_number}")
    
    return '\n'.join(formatted_lines)

def write_to_file(output):
    """Write the output to the given file, headed by the command"""
    # Check if this looks like breakpoint output
    if "file = '" in output and "line = " in output:
        output = parse_breakpoints(output)
    
    subprocess.run("pbcopy", text=True, input=output)
    print("Copied output to clipboard!")

def handle_call(debugger, raw_args, result, internal_dict):
    """Receives and handles the call to write from lldb"""
    command = raw_args

    # Run the command and store the result
    res = lldb.SBCommandReturnObject()
    interpreter = lldb.debugger.GetCommandInterpreter()
    interpreter.HandleCommand(command, res)

    output = res.GetOutput() or res.GetError()
    write_to_file(output)


def __lldb_init_module(debugger, internal_dict):
    """Initialise the write command within lldb"""
    # Tell lldb to import this script and alias it as 'write'.
    # > Note: 'write' (from 'write.handle_call') is taken from the
    #   name of this file
    debugger.HandleCommand('command script add -f write.handle_call write')

    print('The "write" command has been loaded and is ready for use.')
