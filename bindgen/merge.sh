#!/bin/bash
SOURCE_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

if ! [[ -x "$(command -v castffi)" ]]; then
  echo "Error: 'castffi' is not installed. Please visit https://github.com/bottlenoselabs/CAstFfi for instructions to install the CAstFfi tool." >&2
  exit 1
fi

castffi merge --inputDirectoryPath "$SOURCE_DIRECTORY/ast" --outputFilePath "$SOURCE_DIRECTORY/x-ast/ast-cross-platform.json"