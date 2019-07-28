from mips_cli import MipsCli
from mips import Mips
import serial
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("dev")
args = parser.parse_args()

ser = serial.Serial(args.dev)
ser.reset_input_buffer()
ser.reset_output_buffer()

mips = Mips(ser)
cli = MipsCli(mips)
cli.cmdloop()
