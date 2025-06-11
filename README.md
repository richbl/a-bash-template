# A-Bash-Template

![GitHub Release](https://img.shields.io/github/v/release/richbl/a-bash-template)  ![GitHub License](https://img.shields.io/github/license/richbl/a-bash-template?color=blue)  [![Codacy Badge](https://app.codacy.com/project/badge/Grade/37545fb055c3499686b1354e3f733603)](https://app.codacy.com/gh/richbl/a-bash-template/dashboard?utm_source=gh&utm_medium=referral&utm_content=&utm_campaign=Badge_grade)

**A-Bash-Template** (`bash_template.sh`) is a [bash](https://en.wikipedia.org/wiki/Bash_%28Unix_shell%29) script that really does nothing at all: **it's a template.** But it does make scripting--particularly parameter passing--much easier, more organized, and more consistent.

<p align="center">
<picture><source media="(prefers-color-scheme: dark)" srcset="https://github.com/user-attachments/assets/4dc1e16e-3fd3-481c-9a43-b027c029dd27" width="400"><source media="(prefers-color-scheme: light)" srcset="https://github.com/user-attachments/assets/4dc1e16e-3fd3-481c-9a43-b027c029dd27" width="400"><img src="https://github.com/user-attachments/assets/4dc1e16e-3fd3-481c-9a43-b027c029dd27" width="400"></picture>
</p>

## What's a Bash Template (BaT)?

**A-Bash-Template** is designed to make script development and command line argument management more robust, easier to implement, and easier to maintain and update/upgrade. This BaT includes the following features:

- **Dependencies Checker**: a routine that checks all external file and program dependencies (*e.g.* this script relies on [jq](https://stedolan.github.io/jq/) for JSON parsing, so its availability is checked immediately upon script execution)
- **Configuration Details in JSON**: arguments and script details--such as script description and syntax--are stored in the [JSON](http://www.json.org/) file format (*i.e.*, `config.json`)
- **JSON Wrapper Functions**: JSON queries (using [jq](https://stedolan.github.io/jq/)) handled through template wrapper functions
- **Automated Script Banner**: a script banner function automates banner generation, reading directly from `config.json`
- **Automated Arguments Management**: command line arguments are automatically parsed and tested for completeness using both short and long-format argument syntax (*e.g.* `-u|--username`)
- **Support for [Optional] Arguments**: optional command line arguments are permissible and managed through the JSON configuration file
- **Structured Modular Library**: template functions organized into libraries (see the [bash-lib](https://github.com/richbl/bash-lib) project for specific library details) to minimize code footprint in the main script and permit easier maintenance and extensions/add-ons support

### Dependencies Checker

The dependencies checker is a routine that checks that all external file and program dependencies are met. For example, `bash_template.sh` itself relies on one external program for proper execution: [jq](https://stedolan.github.io/jq/), used for parsing its own JSON configuration file (`config.json`).

In this instance, to configure dependency checking in `bash_template.sh`, the array variable `REQ_PROGRAMS` is set to `('jq')`. The script then calls into the `check_dependencies` function in the `args` library (found in the `./lib` folder).

### Script Configuration in JSON

Script details, such as the script description, version and script syntax, and all command line argument options--both required and optional--are stored in a single JSON file called `config.json` located in the `./data` folder.

The JSON file used in **A-Bash-Template** is displayed below:

```json
{
  "details":
    {
      "title": "A bash template (BaT) to ease argument parsing and management",
      "syntax": "bash_template.sh -a alpha -b bravo [-c charlie] -d delta",
      "version": "1.2.0"
    },
  "arguments":
    [
      {
        "short_form": "-a",
        "long_form": "--alpha",
        "text_string": "alpha",
        "description": "alpha (something descriptive)",
        "required": true
      },
      {
        "short_form": "-b",
        "long_form": "--bravo",
        "text_string": "bravo",
        "description": "bravo (something descriptive)",
        "required": true
      },
      {
        "short_form": "-c",
        "long_form": "--charlie",
        "text_string": "charlie",
        "description": "charlie (this is optional)",
        "required": false
      },
      {
        "short_form": "-d",
        "long_form": "--delta",
        "text_string": "delta",
        "description": "delta (something descriptive)",
        "required": true
      }
    ]
}
```

### Automated Script Banner

The informational banner that displays details about how to use the script is generated using configuration details held in the JSON file. A call to `display_banner` in the `./lib/general` library displays the following:  

``` terminal
|
| A bash template (BaT) to ease argument parsing and management
|   1.2.0
|
| Usage:
|   bash_template.sh -a alpha -b bravo [-c charlie] -d delta
|
|   -a, --alpha     alpha (something descriptive)
|   -b, --bravo     bravo (something descriptive)
|   -c, --charlie   charlie (this is optional)
|   -d, --delta     delta (something descriptive)
|
```

By default, `display_banner` is called when the script is run.

### Command Line Parsing and Completeness Testing

When **A-Bash-Template** is run, it parses the command line to identify command line argument values (*e.g.* `--password = pass123`), and also checks to see whether all required arguments have been set. If command line arguments are missing, the script will report it:  

``` terminal
$ ./bash_template.sh -a one

  |
  | A bash template (BaT) to ease argument parsing and management
  |   1.2.0
  |
  | Usage:
  |   bash_template.sh -a alpha -b bravo [-c charlie] -d delta
  |
  |   -a, --alpha     alpha (something descriptive)
  |   -b, --bravo     bravo (something descriptive)
  |   -c, --charlie   charlie (this is optional)
  |   -d, --delta     delta (something descriptive)
  |

Error: bravo argument (-b|--bravo) missing.
Error: delta argument (-d|--delta) missing.
```

> **Note**: The optional argument (-c|--charlie) did not get flagged as an omission since it's an optional argument and not a required argument.

## Requirements

- An operational [bash](https://en.wikipedia.org/wiki/Bash_%28Unix_shell%29) environment (bash 4.3.2 used during initial development)
- One additional external program:
    - [jq](https://stedolan.github.io/jq/), used for parsing the `config.json` file

While this package was originally written and tested under Linux (Ubuntu 15.10 and bash 4.3.2), there should be no reason why this won't work with other shells or other Unix-like operating systems.

## <picture><source media="(prefers-color-scheme: dark)" srcset="https://github.com/user-attachments/assets/2356369f-c752-4e55-8443-49f4174df4b5" width="30"><source media="(prefers-color-scheme: light)" srcset="https://github.com/user-attachments/assets/2356369f-c752-4e55-8443-49f4174df4b5" width="30"><img src="https://github.com/user-attachments/assets/2356369f-c752-4e55-8443-49f4174df4b5" width="30"></picture>  This Project Uses Git Submodules <picture><source media="(prefers-color-scheme: dark)" srcset="https://github.com/user-attachments/assets/2356369f-c752-4e55-8443-49f4174df4b5" width="30"><source media="(prefers-color-scheme: light)" srcset="https://github.com/user-attachments/assets/2356369f-c752-4e55-8443-49f4174df4b5" width="30"><img src="https://github.com/user-attachments/assets/2356369f-c752-4e55-8443-49f4174df4b5" width="30"></picture>

This project uses [Git submodule project(s)](https://git-scm.com/book/en/v2/Git-Tools-Submodules) (found in the `bash-lib` folder) to keep this project stable while the [`bash-lib` project](https://github.com/richbl/bash-lib) is periodically updated.

**Be sure to clone this project with the `--recursive` switch**:

``` terminal
git clone --recursive https://github.com/richbl/this_project
```

so any submodule project(s) will be automatically cloned as well. If you clone into this project without this switch, you'll likely see empty submodule project folders (depending on your version of Git).

## Basic Usage

**A-Bash-Template** is run through a command line interface, so all of the command options are made available there.

Here's the default response when running `bash_template.sh` with no arguments:

``` terminal
$ ./bash_template.sh

  |
  | A bash template (BaT) to ease argument parsing and management
  |   1.2.0
  |
  | Usage:
  |   bash_template.sh -a alpha -b bravo [-c charlie] -d delta
  |
  |   -a, --alpha     alpha (something descriptive)
  |   -b, --bravo     bravo (something descriptive)
  |   -c, --charlie   charlie (this is optional)
  |   -d, --delta     delta (something descriptive)
  |

Error: bravo argument (-a|--alpha) missing.
Error: bravo argument (-b|--bravo) missing.
Error: delta argument (-d|--delta) missing.
```

In this example, the program responds by indicating that the required script arguments must be set before proper operation.

> **Note**: The optional argument (-c|--charlie) did not get flagged as an omission, since it's an optional argument, and not a required argument.

When arguments are correctly passed, the script provides feedback on the success (or failure) of the script:

``` terminal
$ ./bash_template.sh -a one -b two -c three -d four

  |
  | A bash template (BaT) to ease argument parsing and management
  |   1.2.0
  |
  | Usage:
  |   bash_template.sh -a alpha -b bravo [-c charlie] -d delta
  |
  |   -a, --alpha     alpha (something descriptive)
  |   -b, --bravo     bravo (something descriptive)
  |   -c, --charlie   charlie (this is optional)
  |   -d, --delta     delta (something descriptive)
  |

alpha is one
bravo is two
charlie is three
delta is four
```

## Custom Configuration: Look for `[user-config]`

Since **A-Bash-Template** is a BaT, the real value is to permit custom code to become well-integrated to complete whatever is the required intent of the script. The design and structure of the template accounts for this, and only localized changed are necessary.

To make custom configuration changes easier, search for the comment string `[user-config]` throughout the script sources (there are only a few). These comments provide additional guidance on what should be changed and why.

## Bonus: The `bash-lib` Test Runner

As part of this project, we've included a test runner for **bash-lib**. This test runner exercises the **bash-lib** library and provides feedback on the success or failure of each of (currently) 33 tests. It serves a useful template for future test runners you might use as a part of your own BaT project.

To run the `bash-lib` test runner:

``` terminal
./bash_lib_test_runner.sh
```

## Yes, We Are [Dogfooding](https://en.wikipedia.org/wiki/Eating_your_own_dog_food) the A-Bash-Template Project

Of course we are! Otherwise, what value does a BaT offer if it doesn't get used often enough to warrant the time to develop a BaT?

All of our bash scripts have been written to use this project. It's cut our development time, and made it easier to provide updates and added functionality without having to spend time reinventing the wheel every time. Check out all of our projects here on [Github](https://github.com/richbl).

## License

This project is distributed under the [MIT License](https://github.com/richbl/a-bash-template/blob/main/LICENSE)
