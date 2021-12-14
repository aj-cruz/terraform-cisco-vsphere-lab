import argparse

parser = argparse.ArgumentParser()
parser.add_argument(
    '-t',
    '--template',
    action='store',
    dest='scrt_session_template',
    default='',
    help='Path to SecureCRT Session template File',
    required=True
    )
parser.add_argument(
    '-s',
    '--sessionfile',
    action='store',
    dest='scrt_session_file',
    default='',
    help='Path to SecureCRT Session INI File',
    required=True
    )
parser.add_argument(
    '-i',
    '--host',
    action='store',
    dest='telnet_host',
    default='',
    help='IP Address or hostname of the session host',
    required=True
    )
parser.add_argument(
    '-p',
    '--port',
    action='store',
    dest='telnet_port',
    default='',
    help='Decimal telnet port of the VM',
    required=True
    )
args = parser.parse_args()

if __name__ == "__main__":
    # Convert binary port number to 8-digit hexadecimal
    hex_telnet_port = str(hex(int(args.telnet_port))).lstrip("0x")
    for i in range(len(hex_telnet_port), 8):
        hex_telnet_port = "0" + hex_telnet_port

    with open(args.scrt_session_template) as f:
        filedata = f.readlines()
    with open(args.scrt_session_file, 'w') as f:
        for line in filedata:
            if "\"Hostname\"=" in line:
                line_list = line.split("=")
                line_list[-1] = f"{args.telnet_host}\n"
                f.write("=".join(line_list))
            elif "\"Port\"=" in line:
                line_list = line.split("=")
                line_list[-1] = f"{hex_telnet_port}\n"
                f.write("=".join(line_list))
            else:
                f.write(line)
    