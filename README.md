[![linux](https://github.com/dotmodules/dm-test/actions/workflows/linux.yml/badge.svg)](https://github.com/dotmodules/dm-test/actions/workflows/linux.yml)
[![macos](https://github.com/dotmodules/dm-test/actions/workflows/macos.yml/badge.svg)](https://github.com/dotmodules/dm-test/actions/workflows/macos.yml)

# POSIX compliant shell test runner

Minimalistic test runner for shell scripts. It could be used with any POSIX
based shell implementations.

# Test suite execution

## Simplified internal workings

```
for test_file in test_cases_root:
  for test_case in test_file:
    execute(test_case)
```

## Detailed internal workings

![Detailed internal workings](./docs/dm-test-internals-dark.png#gh-dark-mode-only)
![Detailed internal workings](./docs/dm-test-internals-light.png#gh-light-mode-only)

## Subshell structure

During the test suite execution __multiple subshell__ levels will be used for
__environment separation__ and to be able to __interrupt__ the execution if
necessary.

```
runner script/test suite execution level
> test file level
> setup file hook level
>> setup hook level
>>> test case level
>> teardown hook level
> teardown file hook level
```

Generally a __change in__ the current __environment__ will be __available__ for
the __same subshell level and below__, but won't be accesibble to its parent
shells.

There are a few points to note here:

1. Each __test file__ will be executed in a __separate environment__ that will
   be destroyed after execution.
    1. That means you can only __communicate__ between test files via the test
       suite level __test directory__ or via the __key-value buffer system__ as
       variables and environment variables will be destroyed after the test
       file execution.
    1. Setting a __variable__ in the setup file hook will be __available__ for
       __every__ executed __test case in__ that __test file__ as well as for
       the all inner setup and teardown hooks and for the teardown file hook.

1. Test file level hooks and test case level hooks are not in the same subshell
   level.
    1. Setting a __variable in__ a __test file__ level __hook__ will be
       __available__ to the __test case__ level __hooks__.
    1. But setting a __variable in__ a __test case__ level __hook won't be available__
       in the __test file__ level __hooks__.

1. __Each test case__ also has a __separate environment__ that will be destroyed after
   that test case has been executed and it is below of the setup and teardown
   hook sushell level.
    1. That means setting a __variable in__ a __test case__ would be
       __unaccessible to__ the optional teardown and teardown file __hooks__.
       To communicate between a test case and a corresponding teardown hook,
       you have to use the test directory system or the key-value buffer
       system.

# License

This project is under the __MIT license__. See the included __LICENSE__ file.
