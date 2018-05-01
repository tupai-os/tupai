#!/usr/bin/python3

import os, sys, inspect

ISSUES_URL = "https://github.com/tupai-os/tupai/issues"

VALID_ACTIONS = [
	"build",
	"test",
	"check",
	"clean",
]

DEFAULT_FLAGS = {
	"help": False,
	"target": "",
	"targets": False,
	"emu": "qemu",
	"emus": False
}

VALID_TARGETS = [
	"x64",
	"i386",
	"rpi2",
]

VALID_EMUS = [
	"qemu",
	"bochs",
	"vbox",
]

TARGET_MAKE_ARGS = {
	"x64":  ["DEPS=", "TARGET=x64", "DEPS="],
	"i386": ["DEPS=", "TARGET=i386", "DEPS="],
	"rpi2": ["DEPS=", "TARGET=rpi2", "DEPS="],
}

TARGET_QEMU_ARGS = {
	"x64":  {"exec": "qemu-system-x86_64", "flags": ["-cdrom"]},
	"i386": {"exec": "qemu-system-i386", "flags": ["-cdrom"]},
	"rpi2": {"exec": "qemu-system-arm", "flags": []},
}

TARGET_BOCHS_ARGS = {
	"x64":  [],
	"i386": [],
}

def error(msg):
	print("Error: " + msg)
	sys.exit(1)

def parse_args(args):
	flags = DEFAULT_FLAGS
	actions = []
	for arg in args:
		if arg[:2] == "--":
			parts = arg[2:].split("=")
			if len(parts) not in range(1, 4):
				error("Flags must take the form '--flag=value' or '--flag'.")

			if parts[0] in flags:
				flags[parts[0]] = True if len(parts) == 1 else parts[1]
			else:
				error("Unknown flag '{}'.".format(parts[0]))
		else:
			if arg in VALID_ACTIONS:
				actions += [arg]
			else:
				error("Unknown action '{}'.".format(arg))
	return flags, actions

def show_help():
	print("Usage: build.py [flags] actions...")
	print("Flags:")
	print("  --help         Show this help screen")
	print("  --target=<tgt> Specify a system to target when building")
	print("  --targets      Show available targets")
	print("  --emu=<emu>    Specify the emulator to use when testing (defaults to 'qemu')")
	print("  --emus         Show available emulators")
	print("Actions:")
	print("  build          Build Tupai")
	print("  test           Test Tupai using an emulator")
	print("  check          Perform codebase checks without fully building")
	print("  clean          Clean all build files")

def show_targets():
	print("Available targets:")
	for target in VALID_TARGETS:
		build = target in TARGET_MAKE_ARGS
		qemu = target in TARGET_QEMU_ARGS
		bochs = target in TARGET_BOCHS_ARGS
		print("{:12} (supports: build = {}, qemu = {}, bochs = {})".format(target, build, qemu, bochs))

def show_emus():
	print("Available emulators:")
	for emu in VALID_EMUS:
		print("{:12}".format(emu))

def build(flags):
	print("Performing build...")
	if flags["target"] == "":
		error("No target specified. Use '--target=<tgt>'.")
	elif flags["target"] not in VALID_TARGETS:
		error("Unknown target '{}'".format(flags["target"]))
	elif flags["target"] not in TARGET_MAKE_ARGS:
		error("Cannot build target '{}'".format(flags["target"]))

	make_args = TARGET_MAKE_ARGS[flags["target"]]
	result = os.system("make iso {}".format(" ".join(make_args)))

	if result != 0:
		error("Build failed. See above for error.")

def test_qemu(flags):
	if flags["target"] not in TARGET_QEMU_ARGS:
		error("QEMU does not support target '{}'.".format(flags["target"]))

	print("Using QEMU.")

	QEMU_STD_FLAGS = "--no-reboot --no-shutdown -m 256M"

	qemu_args = TARGET_QEMU_ARGS[flags["target"]]
	result = os.system("{} {} {} {}".format(
		qemu_args["exec"],
		QEMU_STD_FLAGS,
		" ".join(qemu_args["flags"]),
		"build/tupai.iso"
	))

def test_bochs(flags):
	print("Using Bochs.")

	result = os.system("{}".format(
		"bochs"
	))

def test(flags):
	print("Performing test...")
	if flags["emu"] == "qemu":
		test_qemu(flags)
	if flags["emu"] == "bochs":
		test_bochs(flags)
	else:
		if flags["emu"] in VALID_EMUS:
			error("Emulator '{}' is currently unimplemented.".format(flags["emu"]))
		else:
			error("Unknown emulator '{}'.", flags["emu"])

def check(flags):
	error("Checking is currently unimplemented.")

def clean(flags):
	print("Performing clean...")
	if flags["target"] == "":
		error("No target specified. Use '--target=<tgt>'.")
	elif flags["target"] not in VALID_TARGETS:
		error("Unknown target '{}'".format(flags["target"]))
	elif flags["target"] not in TARGET_MAKE_ARGS:
		error("Cannot clean target '{}'".format(flags["target"]))

	make_args = TARGET_MAKE_ARGS[flags["target"]]
	result = os.system("make clean {}".format(" ".join(make_args)))

	if result != 0:
		error("Clean failed. See above for error.")

if __name__ == "__main__":
	flags, actions = parse_args(sys.argv[1:])
	if flags["help"] == True:
		show_help()
	elif flags["targets"] == True:
		show_targets()
	elif flags["emus"] == True:
		show_emus()
	elif len(actions) == 0:
		error("No actions specified. Add 'show-help' to find out more.")
	else:
		for action in actions:
			if action == "build":
				build(flags)
			elif action == "test":
				test(flags)
			elif action == "check":
				check(flags)
			elif action == "clean":
				clean(flags)
			else:
				fname = inspect.getframeinfo(inspect.currentframe()).filename
				lnum = inspect.getframeinfo(inspect.currentframe()).lineno
				error("[{}, {}]. This isn't supposed to happen. Report this error at {}".format(fname, lnum, ISSUES_URL))
