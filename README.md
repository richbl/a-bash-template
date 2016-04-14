# A-Bash-Template
**A-Bash-Template** (`bash_template.sh`) is a [bash](https://en.wikipedia.org/wiki/Bash_%28Unix_shell%29) script that really does nothing at all. **It's a template.** But it does make scripting much easier...

## What's a Bash Template (BaT)?

**A-Bash-Template** is designed to make script development and command line argument management more robust, easier to implement, and easier to maintain and update/upgrade. This BaT includes the following features:

- **Dependencies Checker**: a routine that checks all external file and program dependencies (*e.g.*, [jq](https://stedolan.github.io/jq/))
- **Configuration Details in JSON**: Arguments and script details--such as script description and syntax--are stored in the [JSON](http://www.json.org/) file format (*i.e.*, `config.json`)
- **JSON Wrapper Functions**: JSON queries (using [jq](https://stedolan.github.io/jq/)) handled through template wrapper functions
- **Automated Script Banner**: A script banner function automates banner generation, reading directly from `config.json`
- **Automated Arguments Management**: Command line arguments are automatically parsed and tested for completeness using both short and long-format argument syntax (*e.g.*, `-u|--username`)
- **Support for Optional Arguments**: Optional command line arguments are permissible and managed through the JSON configuration file
- **Structured Modular Library**: Template functions organized into libraries to minimize code footprint in the main script, and permits easier maintenance and extensions/add-ons support

### Dependencies Checker
The dependencies checker is a routine that checks that all external file and program dependencies are met. For example, `bash_template.sh` itself relies on one external program for proper execution: [jq](https://stedolan.github.io/jq/), used for parsing its own JSON configuration file (`config.json`).

In this instance, to configure dependency checking in `bash_template.sh`, the array variable `REQ_PROGRAMS` is set to `('jq')`. The script then calls into the `check_dependencies` function in the `args` library (found in the `./lib` folder).

### Script Configuration in JSON
Script details, such as the script description, version and script syntax, and all command line argument options--both required and optional--are stored in a single JSON file called `config.json` located in the `./data` folder.

The JSON file used in **A-Bash-Template** is displayed below:

    {
      "details":
        {
          "title": "A bash template (BaT) to ease argument parsing and management",
          "syntax": "bash_template.sh -a alpha -b bravo [-c charlie] -d delta",
          "version": "0.2.0"
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


### Automated Script Banner
The informational banner that displays details about how to use the script is generated using configuration details held in the JSON file. A call to `display_banner` in the `./lib/general` library displays the following:


    |
    | A bash template (BaT) to ease argument parsing and management
    |   0.2.0
    |
    | Usage:
    |   bash_template.sh -a alpha -b bravo [-c charlie] -d delta
    |
    |   -a, --alpha 	alpha (something descriptive)
    |   -b, --bravo 	bravo (something descriptive)
    |   -c, --charlie 	charlie (this is optional)
    |   -d, --delta 	delta (something descriptive)
    |

By default,  `display_banner` is called when the script is first run.

### Command Line Parsing and Completeness Testing
When **A-Bash-Template** is first run, it parses the command line to identify command line argument values (*e.g.*, `--password = pass123`), and also check to see whether all required arguments have been set. If command line arguments are missing, the script will report it:

    $ ./bash_template.sh -a one

     |
     | A bash template (BaT) to ease argument parsing and management
     |   0.2.0
     |
     | Usage:
     |   bash_template.sh -a alpha -b bravo [-c charlie] -d delta
     |
     |   -a, --alpha 	alpha (something descriptive)
     |   -b, --bravo 	bravo (something descriptive)
     |   -c, --charlie 	charlie (this is optional)
     |   -d, --delta 	delta (something descriptive)
     |

    Error: bravo argument (-b|--bravo) missing.
    Error: delta argument (-d|--delta) missing.

> **Note**:  The optional argument (-c|--charlie) did not get flagged as an omission, since it's an optional argument, and not a required argument.


## Requirements

 - An operational [bash](https://en.wikipedia.org/wiki/Bash_%28Unix_shell%29) environment (bash 4.3.2 used during development)
 -  One additional external program:
    + [jq](https://stedolan.github.io/jq/), used for parsing the `config.json` file

While this package was written and tested under Linux (Ubuntu 15.10), there should be no reason why this won't work under other Unix-like operating systems.


## Basic Usage
**A-Bash-Template** is run through a command line interface, so all of the command options are made available there.

Here's the default response when running `bash_template.sh` with no arguments:

    $ ./bash_template.sh

     |
     | A bash template (BaT) to ease argument parsing and management
     |   0.2.0
     |
     | Usage:
     |   bash_template.sh -a alpha -b bravo [-c charlie] -d delta
     |
     |   -a, --alpha 	alpha (something descriptive)
     |   -b, --bravo 	bravo (something descriptive)
     |   -c, --charlie 	charlie (this is optional)
     |   -d, --delta 	delta (something descriptive)
     |

    Error: bravo argument (-a|--alpha) missing.
    Error: bravo argument (-b|--bravo) missing.
    Error: delta argument (-d|--delta) missing.


In this example, the program responds by indicating that the required script arguments must be set before proper operation. 

> **Note**:  The optional argument (-c|--charlie) did not get flagged as an omission, since it's an optional argument, and not a required argument.

When arguments are correctly passed, the script provides feedback on the success (or failure) of the script:

    $ ./bash_template.sh -a one -b two -c three -d four

     |
     | A bash template (BaT) to ease argument parsing and management
     |   0.2.0
     |
     | Usage:
     |   bash_template.sh -a alpha -b bravo [-c charlie] -d delta
     |
     |   -a, --alpha 	alpha (something descriptive)
     |   -b, --bravo 	bravo (something descriptive)
     |   -c, --charlie 	charlie (this is optional)
     |   -d, --delta 	delta (something descriptive)
     |

    Doing something.

    alpha is one
    bravo is two
    charlie is three
    delta is four

    Success.

## Custom Configuration: Look for `[user-config]` 
Since **A-Bash-Template** is a BaT, the real value is to permit custom code to become well-integrated to complete whatever is the required intent of the script run. The design and structure of the template accounts for this, and only  localized changed are necessary.

To make custom configuration changes, search for the comment string `[user-config]` throughout the script sources (there are only a few). These comments provide guidance on what should be changed and why.

##Yes, We Are [Dogfooding](https://en.wikipedia.org/wiki/Eating_your_own_dog_food) A-Bash-Template
Of course we are! Otherwise, what value does a BaT offer if it doesn't get used often enough to warrant the time to develop a BaT?

Here's our own first *useful* script that uses **A-Bash-Template**: **[remote-folder-copy](https://github.com/richbl/remote-folder-copy)**. Many more to follow...
