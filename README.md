#Scriptlib: A bash scripts utility library

Scriptlib is a modular framework for bash scripts. It provides a variety of
functions which may be useful for writing bash scripts. Functions are grouped by
categories in modules such as to limit the amount of required work by the parser.

To use scriptlib, just source the scriptlib.sh file in your bash script.
```shell
. ../../path/to/scriptlib.sh
```

Then, you may use the scl_load_module to include additional functions.
```shell
scl_load_module "name_of_the_module"
```

For example, in order to include the net, parsing and ui modules:
```shell
scl_load_module net
scl_load_module parsing
scl_load_module ui
```
