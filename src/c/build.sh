#!/bin/bash
DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

LIBRARY_NAME="helloworld"
OUTPUT_DIRECTORY="$DIRECTORY/../../lib"

CMAKE_PROJECT_DIRECTORY_PATH="$DIRECTORY/production/$LIBRARY_NAME"
CMAKE_PROJECT_BIN_DIRECTORY="$DIRECTORY/../../bin/CMake/Release/$LIBRARY_NAME"
CMAKE_PROJECT_BUILD_DIRECTORY_PATH="$DIRECTORY/../../obj/CMake/Release/$LIBRARY_NAME"
CMAKE_ARGS=""

if [[ ! -d "$OUTPUT_DIRECTORY" ]]; then
    mkdir -p "$OUTPUT_DIRECTORY"
fi

if [[ ! -d "$CMAKE_PROJECT_BIN_DIRECTORY" ]]; then
    mkdir -p "$CMAKE_PROJECT_BIN_DIRECTORY"
fi

if [[ ! -d "$CMAKE_PROJECT_BUILD_DIRECTORY_PATH" ]]; then
    mkdir -p "$CMAKE_PROJECT_BUILD_DIRECTORY_PATH"
fi

function get_host_operating_system() {
    local UNAME_STRING="$(uname -a)"
    case "${UNAME_STRING}" in
        *Microsoft*)    local HOST_OS="windows";;
        *microsoft*)    local HOST_OS="windows";;
        Linux*)         local HOST_OS="linux";;
        Darwin*)        local HOST_OS="macos";;
        CYGWIN*)        local HOST_OS="linux";;
        MINGW*)         local HOST_OS="windows";;
        *Msys)          local HOST_OS="windows";;
        *)              local HOST_OS="UNKNOWN:${UNAME_STRING}"
    esac
    echo "$HOST_OS"
    return 0
}
OS="$(get_host_operating_system)"

function get_full_path() {
    if [[ ! -d "$1" && ! -f "$1" ]]; then
        echo ""
        return 1
    fi

    if [[ -x "$(command -v realpath)" ]]; then
        echo "$(realpath $1)"
        return 0
    fi

    local _OS="$(get_host_operating_system)"
    if [[ "$_OS" == "linux" ]]; then
        echo "$(readlink -f $1)"
        return 0
    elif [[ "$_OS" == "macos" ]]; then
        echo "$(perl -MCwd -e 'print Cwd::abs_path shift' $1)"
        return 0
    elif [[ "$_OS" == "windows" ]]; then
        echo "$1"
        return 0
    else
        echo ""
        return 1
    fi
}

FULL_OUTPUT_DIRECTORY=`get_full_path $OUTPUT_DIRECTORY`
FULL_CMAKE_PROJECT_BIN_DIRECTORY=`get_full_path $CMAKE_PROJECT_BIN_DIRECTORY`
FULL_CMAKE_PROJECT_BUILD_DIRECTORY_PATH=`get_full_path $CMAKE_PROJECT_BUILD_DIRECTORY_PATH`

function create_build_files() {
    rm -rf $FULL_CMAKE_PROJECT_BUILD_DIRECTORY_PATH # Clear any previous build files
    echo "Creating build files using CMake..."

    if [[ "$OS" == "macos" ]]; then
        local CMAKE_ARCH_ARGS="-DCMAKE_OSX_ARCHITECTURES=x86_64;arm64"
    fi

    local PREVIOUS_DIRECTORY=`pwd`
    cd $CMAKE_PROJECT_DIRECTORY_PATH
    cmake -S "./" -B $FULL_CMAKE_PROJECT_BUILD_DIRECTORY_PATH $CMAKE_ARCH_ARGS \
        `# change output directories` \
        -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY="$FULL_CMAKE_PROJECT_BIN_DIRECTORY" -DCMAKE_LIBRARY_OUTPUT_DIRECTORY="$FULL_CMAKE_PROJECT_BIN_DIRECTORY" -DCMAKE_RUNTIME_OUTPUT_DIRECTORY="$FULL_CMAKE_PROJECT_BIN_DIRECTORY" \
        `# project specific` \
        $CMAKE_ARGS
    if [[ $? -ne 0 ]]; then exit $?; fi
    cd $PREVIOUS_DIRECTORY

    echo "Creating build files using CMake... Done."
}

function build() {
    echo "Building native library..."

    cmake --build $FULL_CMAKE_PROJECT_BUILD_DIRECTORY_PATH --config Release
    if [[ $? -ne 0 ]]; then return $?; fi

    if [[ "$OS" == "linux" ]]; then
        local TARGET_BUILD_LIBRARY_FILENAME_SEARCH="*$LIBRARY_NAME.so"
        local TARGET_BUILD_LIBRARY_FILENAME="lib$LIBRARY_NAME.so"
    elif [[ "$OS" == "macos" ]]; then
        local TARGET_BUILD_LIBRARY_FILENAME_SEARCH="*$LIBRARY_NAME.dylib"
        local TARGET_BUILD_LIBRARY_FILENAME="lib$LIBRARY_NAME.dylib"
    elif [[ "$OS" == "windows" ]]; then
        local TARGET_BUILD_LIBRARY_FILENAME_SEARCH="**/*$LIBRARY_NAME.dll"
        local TARGET_BUILD_LIBRARY_FILENAME="$LIBRARY_NAME.dll"
        local TARGET_BUILD_LIBRARY_FILENAME_LIB_SEARCH="**/*$LIBRARY_NAME.lib"
        local TARGET_BUILD_LIBRARY_FILENAME_LIB="$LIBRARY_NAME.lib"
    else
        echo "Unknown target build OS: '$OS'"
        return 1
    fi

    local LIBRARY_FILE_PATH_BUILD=`get_full_path $FULL_CMAKE_PROJECT_BIN_DIRECTORY/$TARGET_BUILD_LIBRARY_FILENAME_SEARCH`
    if [[ -z "$LIBRARY_FILE_PATH_BUILD" ]]; then
        echo "The built native shared library file '$LIBRARY_FILE_PATH_BUILD' does not exist!"
        return 1
    fi

    if [[ "$OS" == "windows" ]]; then
        local LIBRARY_FILE_PATH_BUILD_LIB=`get_full_path $FULL_CMAKE_PROJECT_BIN_DIRECTORY/$TARGET_BUILD_LIBRARY_FILENAME_LIB_SEARCH`
        if [[ -z "$LIBRARY_FILE_PATH_BUILD_LIB" ]]; then
            echo "The built native static library file '$LIBRARY_FILE_PATH_BUILD_LIB' does not exist!"
            return 1
        fi
    fi

    local LIBRARY_FILE_PATH="$FULL_OUTPUT_DIRECTORY/$TARGET_BUILD_LIBRARY_FILENAME"
    cp "$LIBRARY_FILE_PATH_BUILD" "$LIBRARY_FILE_PATH"
    if [[ $? -ne 0 ]]; then return $?; fi
    echo "Copied '$LIBRARY_FILE_PATH_BUILD' to '$LIBRARY_FILE_PATH'"

    if [[ "$TARGET_BUILD_OS" == "windows" ]]; then
        LIBRARY_FILE_PATH_LIB="$FULL_OUTPUT_DIRECTORY/$TARGET_BUILD_LIBRARY_FILENAME_LIB"
        cp "$LIBRARY_FILE_PATH_BUILD_LIB" "$LIBRARY_FILE_PATH_LIB"
        if [[ $? -ne 0 ]]; then return $?; fi
        echo "Copied '$LIBRARY_FILE_PATH_BUILD_LIB' to '$LIBRARY_FILE_PATH_LIB'"
    fi

    echo "Building native library... Done."
}

create_build_files
build