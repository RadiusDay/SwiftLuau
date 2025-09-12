#!/bin/bash

# Fail on any error
set -e

# MacOS only
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "This script is intended to run on macOS only."
    exit 1
fi

# We will change directories, so storing the original one is essential.
ORIGINAL_DIR=$(pwd)
LUAU_DIR="lib/Luau"
BUILD_DIR=".build/luau_build"

# Ensure the Luau directory exists.
if [ ! -d "$ORIGINAL_DIR/$LUAU_DIR" ]; then
    echo "Error: Luau directory not found at $LUAU_DIR. Please ensure the path is correct."
    exit 1
fi

# If the build directory doesn't exist, create it.
mkdir -p "$ORIGINAL_DIR/$BUILD_DIR"
cd "$ORIGINAL_DIR/$BUILD_DIR"

# Check if ninja is installed
NINJA_INSTALLED=false
if command -v ninja &> /dev/null; then
    NINJA_INSTALLED=true
    echo "Ninja is installed. Using Ninja as the build system."
fi

# Configure the build with CMake.
CMAKE_FLAGS=(
    -DLUAU_BUILD_WEB=0
    -DLUAU_EXTERN_C=1
    -DCMAKE_BUILD_TYPE=RelWithDebInfo
    -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0
    -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64"
    $($NINJA_INSTALLED && echo "-G Ninja")
)
cmake "$ORIGINAL_DIR/$LUAU_DIR" "${CMAKE_FLAGS[@]}"
cmake --build . --config RelWithDebInfo --target Luau.VM
cmake --build . --config RelWithDebInfo --target Luau.Compiler

# Extract the debug information into separate .dSYM files.
LIB_LUAU_AST="libLuau.Ast.a"
LIB_LUAU_COMPILER="libLuau.Compiler.a"
LIB_LUAU_VM="libLuau.VM.a"

# Ensure the libraries were built
if [ ! -f "$LIB_LUAU_AST" ]; then
    echo "Error: $LIB_LUAU_AST not found. Build may have failed."
    cd "$ORIGINAL_DIR"
    exit 1
fi
if [ ! -f "$LIB_LUAU_COMPILER" ]; then
    echo "Error: $LIB_LUAU_COMPILER not found. Build may have failed."
    cd "$ORIGINAL_DIR"
    exit 1
fi
if [ ! -f "$LIB_LUAU_VM" ]; then
    echo "Error: $LIB_LUAU_VM not found. Build may have failed."
    cd "$ORIGINAL_DIR"
    exit 1
fi

# Create the XCFrameworks
xcodebuild -create-xcframework \
    -library "$LIB_LUAU_AST" \
    -output "$ORIGINAL_DIR/$BUILD_DIR/LuauAst.xcframework"
xcodebuild -create-xcframework \
    -library "$LIB_LUAU_COMPILER" \
    -output "$ORIGINAL_DIR/$BUILD_DIR/LuauCompiler.xcframework"
xcodebuild -create-xcframework \
    -library "$LIB_LUAU_VM" \
    -output "$ORIGINAL_DIR/$BUILD_DIR/LuauVM.xcframework"

# Return to the original directory
cd "$ORIGINAL_DIR"

echo "Build completed successfully."
exit 0
