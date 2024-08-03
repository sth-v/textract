# textract

## Overview

**textract** is a command line tool for recognising text in images using macOS's built-in Vision framework

I think many macOS users will appreciate the current text recognition system. I think many people would also like to see it as a command line application.

This application consists of a single `main.swift` file. It only requires swiftc, which is available in xcode-select (Xcode CommandLine Tools) to compile the executable. You do not need Xcode, .xcodeproject, or anything else.

## System Requirements

Text recognition on macOS, iOS, and other Apple systems is done with [Vision Framework](https://developer.apple.com/documentation/vision/), which requires macOS 10.13+.


## Installation

To build on your own machine, do the following:

1. Clone this repository:

    ```zsh
    git clone https://github.com/sth-v/textract.git
    ```

2. Go to the root of the cloned repository

    ```zsh
    cd textract
    ```

3. Compile the executable

    ```zsh
    swiftc -O main.swift -o textract 
    ```

    See ``swiftc --help`` for other options for compilation.

    After this operation, an executable file named `textract` will appear in the root folder of the repository. This is the application.


4. Run

    ```zsh
    ./textract --help
    ```

    Output:

    ```plaintext
    textract: A Swift command line tool for recognising text in images using macOS's built-in Vision framework.

    Usage:
    textract <path> [options]
    textract --base64-input <base64 image> [options]

    Arguments:
    <path> The path to an image file or a directory containing image files.
    <base64 image> A base64-encoded string representing an image.

    Options:
    --file-output Save recognised text to .txt files with the same base names as the images.
    --print-report Print lists of processed and skipped files at the end.
    -h, --help, ? Display this help section.

    Examples:
    1. Process a directory and output recognised text to stdout:
        ./textract /path/to/your/images

    2. Process a single image file and output recognised text to stdout:
        ./textract /path/to/your/image/file

    3. Process a directory and save recognised text to .txt files:
        ./textract /path/to/your/images --file-output

    4. Process a directory, save recognised text to .txt files, and print a report:
        ./textract /path/to/your/images --file-output --print-report

    5. Process a single image file, output recognised text to stdout, and print a report:
        ./textract /path/to/your/image/file --print-report

    6. Process a base64-encoded image string:
        ./textract --base64-input <base64 image>
    ```

## Examples

1. Process a directory and output recognised text to stdout:

    ```zsh
    ./textract /path/to/your/images
    ```

2. Process a single image file and output recognised text to stdout:

    ````zsh
    ./textract /path/to/your/image/file
    ```

3. Process a directory and save recognised text to .txt files:

    ````zsh
    ./textract /path/to/your/images --file-output
    ```

4. Process a directory, save recognised text to .txt files, and print a report:

    ````zsh
    ./textract /path/to/your/images --file-output --print-report
    ```

5. Process a single image file, output recognised text to stdout, and print a report:

    ````zsh
    ./textract /path/to/your/image/file --print-report
    ```

6. If you are using a macOS device as a server, a macOS virtual machine, or a [docker container](https://hub.docker.com/r/sickcodes/docker-osx) you may want to call `textract` over a network, for example via the REST API. For this purpose we have implemented the ability to read an image not from a file but from a base64 string, which is passed directly to stdin in the following form:

    ```zsh
    ./textract --base64-input <base64 string>
    ```
