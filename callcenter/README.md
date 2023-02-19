Call Center Lang
================
A strongly-typed functional language that mimics calling a call center service from an old brick phone.

Build
-----
1. Install packages: `yarn install`
2. Build the CLI: `yarn build`
3. Run the CLI: to run file `examples/math.call`, you can use:
    - `yarn callcenter -f examples/math.call`
    - `cat examples/math.call | yarn callcenter`

    You can also pass `-q` or `--quiet` in the CLI argument to only show evaluation results.
4. Run the CLI as REPL: `yarn callcenter`

Online Demo
----
TBA
