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

# License

This project is under the __MIT license__. See the included __LICENSE__ file.
