#!/usr/bin/python3
import sys, os, configparser

DEFAULT_TARGET_CFG = "target.ini"

SECTION_REQUIRED = True
SECTION_OPTIONAL = False
ATTRIBUTE_REQUIRED = True
ATTRIBUTE_OPTIONAL = False
ATTRIBUTE_MULTIVAR = True
ATTRIBUTE_SINGLE = False

deps = {
	"arch": [SECTION_REQUIRED, [], {
			"base": [ATTRIBUTE_REQUIRED, ATTRIBUTE_SINGLE, {
					"x86": [],
					"arm": [],
				},
			],
			"isa": [ATTRIBUTE_REQUIRED, ATTRIBUTE_SINGLE, {
					"i386": [
						["arch", "base", ["x86"]],
					],
					"x86_64": [
						["arch", "base", ["x86"]],
					],
					"armv7": [
						["arch", "base", ["arm"]],
					],
					"armv8": [
						["arch", "base", ["arm"]],
					],
				},
			],
		},
	],
	"board": [SECTION_OPTIONAL, [["arch", "base", ["arm"]]], {
			"model": [ATTRIBUTE_REQUIRED, ATTRIBUTE_SINGLE, {
					"bcm2835": [
						["arch", "isa", ["armv7"]]
					],
					"bcm2836": [
						["arch", "isa", ["armv7"]]
					],
					"bcm2837": [
						["arch", "isa", ["armv7", "armv8"]]
					],
				},
			],
		},
	],
	"drivers": [SECTION_REQUIRED, [], {
			"tty": [ATTRIBUTE_REQUIRED, ATTRIBUTE_SINGLE, {
					"com": [
						["drivers", "serial", ["com"]],
					],
					"vgaconsole": [
						["drivers", "video", ["vga"]],
					],
					"uart": [
						["drivers", "serial", ["uart"]],
					],
					"bcm283xconsole": [
						["drivers", "video", ["bcm283x"]],
					],
				},
			],
			"video": [ATTRIBUTE_OPTIONAL, ATTRIBUTE_MULTIVAR, {
					"vga": [
						["arch", "base", ["x86"]],
					],
					"bcm283x": [
						["arch", "base", ["arm"]],
					],
				},
			],
			"serial": [ATTRIBUTE_OPTIONAL, ATTRIBUTE_MULTIVAR, {
					"uart": [
						["arch", "base", ["arm"]],
					],
					"com": [
						["arch", "base", ["x86"]],
					],
				},
			],
		},
	],
}

# MATCH_TYPE_NONE = 0
# MATCH_TYPE_ALL = 1
# MATCH_TYPE_SOME = 2

# def match(*pargs):
#     return (MATCH_TYPE_SOME, pargs)

# def match_all():
#     return (MATCH_TYPE_ALL)

# def match_none():
#     return (MATCH_TYPE_NONE)

# class Req:
#     def __init__(self, sect, attr, items):
#         self.sect = sect
#         self.attr = attr
#         self.items = items

# class ConfigReq:
#     def __init__(self, **kwargs):
#         self.may_contain = kwargs["may_contain"] if "may_contain" in kwargs else []
#         self.reqs = kwargs["requirements"] if "requirements" in kwargs else []

# class SectReq:
#     def __init__(self, name, **kwargs):
#         self.name = name
#         self.required = kwargs["required"] if "required" in kwargs else False
#         self.may_contain = kwargs["may_contain"] if "may_contain" in kwargs else []
#         self.reqs = kwargs["requirements"] if "requirements" in kwargs else []

# class AttrReq:
#     def __init__(self, name, **kwargs):
#         self.name = name
#         self.required = kwargs["required"] if "required" in kwargs else False
#         self.singular = kwargs["singular"] if "singular" in kwargs else []
#         self.may_contain = kwargs["may_contain"] if "may_contain" in kwargs else []
#         self.reqs = kwargs["requirements"] if "requirements" in kwargs else []

# class ItemReq:
#     def __init__(self, name, **kwargs):
#         self.name = name
#         self.required = kwargs["required"] if "required" in kwargs else False
#         self.reqs = kwargs["requirements"] if "requirements" in kwargs else []

# rcfg = ConfigReq(
#     may_contain = [
#         SectReq("test", required = True,
#             may_contain = [
#                 AttrReq("foo", required = True),
#             ],
#         ),
#         SectReq("arch", required = True,
#             may_contain = [
#                 AttrReq("base", required = True, singular = True,
#                     may_contain = [
#                         ItemReq("x86"),
#                         ItemReq("arm"),
#                     ]
#                 ),
#                 AttrReq("isa", required = True, singular = True,
#                     may_contain = [
#                         ItemReq("i386",
#                             reqs = [
#                                 Req(match("arch"), match("base"), match("x86")),
#                             ],
#                         ),
#                         ItemReq("x86_64",
#                             reqs = [
#                                 Req(match("arch"), match("base"), match("x86")),
#                             ],
#                         ),
#                         ItemReq("armv7",
#                             reqs = [
#                                 Req(match("arch"), match("base"), match("arm")),
#                             ],
#                         ),
#                     ]
#                 ),
#             ],
#         ),
#     ],
# )

# class Attr:
#     def __init__(self, name, items = []):
#         self.name = name
#         self.items = items

#     def str(self):
#         return "ATTR " + self.name + ": " + "[\n      " + ",\n      ".join(self.items) + "\n    ]"

#     def contains(self, name):
#         for item in self.items:
#             if item.name == name:
#                 return True
#         return False

# class Sect:
#     def __init__(self, name, attrs = []):
#         self.name = name
#         self.attrs = attrs

#     def str(self):
#         return "SECT " + self.name + ": " + "[\n    " + ",\n    ".join([attr.str() for attr in self.attrs]) + "\n  ]"

#     def contains(self, name):
#         for attr in self.attrs:
#             if attr.name == name:
#                 return True
#         return False

# class Config:
#     def __init__(self, cfg):
#         self.parse_from(cfg)

#     def parse_from(self, cfg):
#         self.sects = {}
#         for sect in cfg.sections():
#             nsect = Sect(sect)
#             for attr in cfg.options(sect):
#                 items = [item.strip() for item in cfg.get(sect, attr, fallback = "").split(",")]
#                 nattr = Attr(attr, items)
#                 nsect.attrs.append(nattr)
#             self.sects[sect] = nsect

#     def str(self):
#         return "CFG [\n  " + ",\n  ".join([sect.str() for sect in self.sects]) + "\n]"

#     def contains(self, name):
#         for sect in self.sects:
#             if sect.name == name:
#                 return True
#         return False

#     def check_required(self, rcfg):
#         for rsect in rcfg.may_contain:
#             if (rsect.name not in self.sects) and rsect.required:
#                 error("Section '{}' is required".format(rsect.name))
#             for rattr in rsect.may_contain:
#                 if (rattr.name not in self.sects[rsect.name].attrs) and rattr.required:
#                     error("Section '{}' is required".format(rsect.name))

#     def check_with(self, rcfg):
#         print("Checking...")
#         # Check that required things exist
#         self.check_required(rcfg)
#         print("Check passed!")

def error(msg):
	print("Error: " + msg)
	sys.exit(1)

def parse_args(args):
	if len(args) == 0:
		error("Target configuration not specified")

	make_args = args[1:]
	ini_filename = args[0]

	return {"ini_filename": ini_filename, "make_args": make_args}

def read_cfg(filename):
	try:
		return open(filename).read()
	except:
		error("Could not read configuration '" + filename + "'")

def parse_cfg(data):
	cfg = configparser.ConfigParser()
	try:
		cfg.read_string(data)
	except:
		error("Failed to parse configuration data")
	return cfg

def check_deps(cfg):
	# Check existence
	for sec in deps:
		if deps[sec][0] == SECTION_OPTIONAL:
			continue
		if sec not in cfg.sections():
			error("Section '" + sec + "' is required")
		for opt in deps[sec][2]:
			if deps[sec][2][opt][0] == ATTRIBUTE_OPTIONAL:
				continue
			if opt not in cfg.options(sec):
				error("Attribute '" + sec + "." + opt + "' is required")

	# Check compatibility
	for section in cfg.sections():
		if section not in deps:
			continue

		for section_dep in deps[section][1]:
			if section_dep[0] not in cfg.sections():
					error("Section '" + section + "' requires section '" + attribute_dep[0] + "'")
			elif section_dep[1] not in cfg.options(section_dep[0]):
				error("Section '" + section + "' requires attribute '" + section_dep[0] + "." + section_dep[1] + "'")
			elif cfg.get(section_dep[0], attribute_dep[1], fallback = None) not in section_dep[2]:
				if len(section_dep[2]) > 1:
					error("Section '" + section + "' requires attribute '" + section_dep[0] + "." + section_dep[1] + "' to be equal to one of '" + ", ".join(section_dep[2]) + "'")
				else:
					error("Section '" + section + "' requires attribute '" + section_dep[0] + "." + section_dep[1] + "' to be equal to '" + section_dep[2][0] + "'")

		for attribute in cfg.options(section):
			if attribute not in deps[section][2]:
				continue

			val = cfg.get(section, attribute, fallback = None)
			if val == None or val == "" and (deps[section][2][attribute][1] == ATTRIBUTE_SINGLE):
				error("Attribute '" + section + "." + attribute + "' must have a value")
			else:
				if deps[section][2][attribute][1] == ATTRIBUTE_OPTIONAL:
					items = [item.strip() for item in val.split(",")]
					for item in items:
						if len(item) == 0:
							continue
						if not item in deps[section][2][attribute][2]:
							error("Attribute '" + section + "." + attribute + "' cannot contain value '" + item + "'")
				else:
					items = [val]
				for item in items:
					if len(item) == 0:
						continue
					if not item in deps[section][2][attribute][2]:
						error("Attribute '" + section + "." + attribute + "' cannot have value '" + item + "'")

					attribute_deps = deps[section][2][attribute][2][item]
					for attribute_dep in attribute_deps:
						if attribute_dep[0] not in cfg.sections():
							error("Attribute '" + section + "." + attribute + "' = '" + item + "' requires section '" + attribute_dep[0] + "'")
						elif attribute_dep[1] not in cfg.options(attribute_dep[0]):
							error("Attribute '" + section + "." + attribute + "' = '" + item + "' requires attribute '" + attribute_dep[0] + "." + attribute_dep[1] + "'")
						elif cfg.get(attribute_dep[0], attribute_dep[1], fallback = None) not in attribute_dep[2]:
							if len(attribute_dep[2]) > 1:
								error("Attribute '" + section + "." + attribute + "' = '" + item + "' requires attribute '" + attribute_dep[0] + "." + attribute_dep[1] + "' to be equal to one of '" + ", ".join(attribute_dep[2]) + "'")
							else:
								error("Attribute '" + section + "." + attribute + "' = '" + item + "' requires attribute '" + attribute_dep[0] + "." + attribute_dep[1] + "' to be equal to '" + attribute_dep[2][0] + "'")

def gen_build_args(cfg):
	#config = Config(cfg)
	#print(config.str())
	#config.check_with(rcfg)

	check_deps(cfg)

	build_args = []

	# Generate build arguments
	for section in cfg.sections():
		if section not in deps:
			continue

		for attribute in cfg.options(section):
			if attribute not in deps[section][2]:
				continue

			val = cfg.get(section, attribute, fallback = "")
			items = [item.strip() for item in val.split(",")]
			cfg_name = "CFG_" + section + "_" + attribute
			if deps[section][2][attribute][1] == False:
				build_args += [cfg_name + "=" + items[0]]
				os.environ[cfg_name] = items[0]
			else:
				build_args += ["\"" + cfg_name + "=" + ",".join(items) + "\""]
				os.environ[cfg_name] = " ".join(items)

	return build_args

def run_make(cfg, make_args):
	cmd = "make " + " ".join(make_args)
	print("Running command:\n" + cmd)
	os.system(cmd)

if __name__ == "__main__":
	info = parse_args(sys.argv[1:])
	cfg_data = read_cfg(info["ini_filename"])
	print("Read target configuration")
	cfg = parse_cfg(cfg_data)
	print("Parsed target configuration")
	build_args = gen_build_args(cfg)
	print("Generated build arguments")

	print("Running make...")
	run_make(cfg, info["make_args"] + build_args)
