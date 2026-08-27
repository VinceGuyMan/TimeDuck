#!/bin/bash
# TimeDuck · Clean build & test script for macOS
set -e
cd "$(dirname "$0")"

BUILD_DIR="build"
APP_BUNDLE="$BUILD_DIR/TimeDuck.app"
BINARY="$BUILD_DIR/TimeDuck"
TEST_RUNNER="$BUILD_DIR/TestRunner"
MACOS_DEPLOYMENT_TARGET="12.0"
TARGET_ARCH="${TIMEDUCK_ARCH:-$(uname -m)}"
TARGET_TRIPLE="${TARGET_ARCH}-apple-macosx${MACOS_DEPLOYMENT_TARGET}"

function usage() {
    echo "Usage: ./build.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --app      Build executable and package into macOS .app bundle (default)"
    echo "  --bin      Build binary only (build/TimeDuck)"
    echo "  --test     Build and run automated test suite"
    echo "  --release  Build optimized release .app bundle"
    echo "  --clean    Remove all build artifacts"
    echo "  --help     Show this help message"
    echo ""
}

function clean() {
    echo "▸ Cleaning build artifacts…"
    rm -rf "$BUILD_DIR" .build
    echo "✓ Clean complete."
}

function compile_binary() {
    local opt_flag="${1:---O}"
    echo "▸ Compiling TimeDuck sources ($opt_flag)…"
    mkdir -p "$BUILD_DIR"
    
    # Collect all Swift source files excluding App/main.swift for core if needed, or all sources
    SWIFT_SOURCES=$(find src -name "*.swift")
    
    swiftc $opt_flag -target "$TARGET_TRIPLE" -o "$BINARY" $SWIFT_SOURCES
    echo "✓ Binary generated at $BINARY"
}

function assemble_app() {
    echo "▸ Assembling $APP_BUNDLE…"
    rm -rf "$APP_BUNDLE"
    mkdir -p "$APP_BUNDLE/Contents/MacOS" "$APP_BUNDLE/Contents/Resources"
    
    cp "$BINARY" "$APP_BUNDLE/Contents/MacOS/TimeDuck"
    cp Info.plist "$APP_BUNDLE/Contents/Info.plist"
    
    if [ -d "Resources" ]; then
        cp -R Resources/* "$APP_BUNDLE/Contents/Resources/"
    fi

    if [ -f "assets/AppIcon.icns" ]; then
        cp assets/AppIcon.icns "$APP_BUNDLE/Contents/Resources/AppIcon.icns"
        /usr/libexec/PlistBuddy -c "Add :CFBundleIconName string AppIcon" "$APP_BUNDLE/Contents/Info.plist" 2>/dev/null || true
        /usr/libexec/PlistBuddy -c "Add :CFBundleIconFile string AppIcon" "$APP_BUNDLE/Contents/Info.plist" 2>/dev/null || true
    fi
    
    touch "$APP_BUNDLE"
    codesign --force --deep --sign - "$APP_BUNDLE"
    echo "✓ App bundle created at $APP_BUNDLE"
}

function run_tests() {
    echo "▸ Compiling TimeDuck test runner…"
    mkdir -p "$BUILD_DIR"
    
    TEST_SOURCES="src/Engine/TimerEngine.swift src/Engine/StatsTracker.swift src/Engine/Formatting.swift src/Engine/DuckBrain.swift src/Graphics/Sprites.swift src/Graphics/StatusDuck.swift src/Graphics/ViewportTransform.swift src/Graphics/CompactLayout.swift src/Graphics/PixelCanvas.swift src/Graphics/Theme.swift src/App/AppVersion.swift src/App/Persistence.swift Tests/TestHarness.swift Tests/TestRunner.swift $(find Tests/TimeDuckTests -name "*.swift")"
    
    swiftc -O -target "$TARGET_TRIPLE" -o "$TEST_RUNNER" $TEST_SOURCES
    echo "✓ Test runner compiled at $TEST_RUNNER"
    echo ""
    "$TEST_RUNNER"
}

# Parse command line argument
MODE="${1:---app}"

case "$MODE" in
    --clean)
        clean
        ;;
    --test)
        run_tests
        ;;
    --bin)
        compile_binary "-O"
        ;;
    --release)
        compile_binary "-Osize"
        assemble_app
        ;;
    --app|"")
        compile_binary "-O"
        assemble_app
        ;;
    --help|-h)
        usage
        ;;
    *)
        echo "Unknown option: $MODE"
        usage
        exit 1
        ;;
esac
