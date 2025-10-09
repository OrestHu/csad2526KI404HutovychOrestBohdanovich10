Simple "Hello, World!" C++ program.

## Sources

- `main.cpp`
- `math_operations.h`

## Build

```
cmake -S . -B build
cmake --build build
```

## Run

```
.\build\Debug\csad2526KI404HutovychOrestBohdanovich10.exe
```

## Test

```
cmake --build build --target unit_tests
ctest --test-dir build -C Debug
cmake --build build --target run_tests  # optional shortcut
```