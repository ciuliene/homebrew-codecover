# CodeCover

![GitHub Release](https://img.shields.io/github/v/release/ciuliene/homebrew-codecover)

This is a shell script that allows users to run tests and automatically generate reports of the code coverage of projects.

## Prerequisites

Supported operating systems:
- macOS using `Homebrew`

Supported languages and test frameworks:
- C# (.NET)
  - `XUnit`
- Python
  - `unittest`


## Installation

### macOS:

You can install the package using Homebrew:

```sh
# Tap the repository
brew tap ciuliene/codecover

# Install the package
brew install codecover
```

## Usage

### Usage with Arguments

The script requires the following arguments:

- Language: the programming language of the project. It can be:
    - `--csharp`
    - `--python`
- Tests directory: the directory where the tests are located (multiple directories are not supported):
    - `--tests-dir <path>`

Here is an example of how to run the script in a Python project with tests located in the `tests` directory:

```sh
codecover --python --tests-dir tests
```

### Usage without Arguments

When the script is executed for the first time, it will generate a file named `.codecover` in the active directory. This file contains the configuration provided at first run. You can modify the configuration file to change the behavior of the script or pass different arguments. Every time arguments are passed to the script, the configuration file is updated with the new values.
When the script is executed without arguments, it will use the configuration file (if exists) to run the tests:

```sh
codecover
```

### Other Arguments

For the complete list of arguments, run:

```sh
codecover --help
```

## How it works

At first the script checks whether the project matches the requirements, based on the selected programming language:

- C# (.NET): the script checks if the project has a .NET solution file (`.sln`) in the directory.
- Python: the script checks if the project has a virtual environment in the directory where to install the dependencies. The default name of the virtual environment is `venv`.

After that, if not installed, the script installs the necessary dependencies that will be removed after the script finishes. Otherwise, if already installed, they are left as they are:

- C# (.NET):
  - `coverlet.msbuild`
  - `coverlet.collector`
- Python:
  - `coverage`

After that it runs the tests of the project and, if they are successful, generates a report of the code coverage in `lcov` format.

## Report

The script generates a report in root of the project. The report is a file in `lcov` format. There are many tools that can be used to visualize the report, I suggest two ways:

- Upload the `lcov.info` file to [lcov-viewer](https://lcov-viewer.netlify.app/). There you can see the percentage of code coverage of each file of the project.
- If you use Visual Studio Code, you can install the [Coverage Gutters](https://marketplace.visualstudio.com/items?itemName=ryanluker.vscode-coverage-gutters) extension. This extension help users to detect which lines of code are covered by tests. See the documentation of the extension to know how to use it.