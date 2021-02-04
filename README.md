![build](https://github.com/dotmodules/dm-test/workflows/build/badge.svg)

# POSIX compliant shell test runner

Minimalistic test runner for shell scripts. It could be used with any POSIX
based shell implementations.

# Test suite execution

## Simlified internal working

```
for test_file in test_cases_root:
  for test_case in test_file:
    execute(test_case)
```
## Subshell structure

During the test suite execution multiple subshell levels will be used for environment separation and to be able to interrupt the
execution if necessary.

```
runner script/test suite execution level
> test file level
> setup file hook level
>> setup hook level
>>> test case level
>> teardown hook level
> teardown file hook level
```

Generally a change in the current environment will be available for the same
subshell level and below, but won't be accesibble to its parent shells.

There are a few points to note here:

1. Each test file will be executed in a separate environment that will be
   destroyed after execution.
    1. That means you can only communicate between test files via the test
       suite level test directory or via the key-value buffer system as
       variables and environment variables will be destroyed after the test
       file execution.
    1. Setting a variable in the setup file hook will be available for every
       executed test case in that test file as well as for the all inner setup
       and teardown hooks and for the teardown file hook.

1. Test file level hooks and test case level hooks are not in the same subshell
   level.
    1. Setting a variable in a test file level hook will be available to the
       test case level hooks.
    1. But setting a variable in a test case level hook won't be available in
       the test file level hooks.

1. Each test case also has a separate environment that will be destroyed after
   that test case has been executed and it is below of the setup and teardown
   hook sushell level.
    1. That means setting a variable in a test casse would be unaccessible to
       the optional teardown and teardown file hooks. To communicate between a
       test case and a corresponding teardown hook, you have to use the test
       directory system or the key-value buffer system.

# License

This project is under the __MIT license__. See the included __LICENSE__ file.
