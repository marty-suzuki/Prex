#!/usr/bin/env sh

# Configuration
XCODE_TEMPLATE_DIR=$HOME'/Library/Developer/Xcode/Templates/File Templates/Prex'
PREX_TEMPLATE_DIR="$XCODE_TEMPLATE_DIR"/Prex.xctemplate
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Copy Prex file templates into the local Prex template directory
xcodeTemplate () {
  echo "==> Copying up Prex Xcode file templates..."

  if [ -d "$XCODE_TEMPLATE_DIR" ]; then
    rm -R "$XCODE_TEMPLATE_DIR"
  fi
  mkdir -p "$XCODE_TEMPLATE_DIR"

  cp -R $SCRIPT_DIR/Prex.xctemplate "$XCODE_TEMPLATE_DIR"
  cp -R "$PREX_TEMPLATE_DIR"/Common/* "$PREX_TEMPLATE_DIR"/Default
  cp -R "$PREX_TEMPLATE_DIR"/Common/* "$PREX_TEMPLATE_DIR"/PresenterSubclass
  rm -R "$PREX_TEMPLATE_DIR"/Common
  mkdir -p "$PREX_TEMPLATE_DIR"/PresenterSubclassWithXIB
  mkdir -p "$PREX_TEMPLATE_DIR"/PresenterSubclassWithStoryboard
  cp -R "$PREX_TEMPLATE_DIR"/WithXIB/* "$PREX_TEMPLATE_DIR"/PresenterSubclassWithXIB/
  cp -R "$PREX_TEMPLATE_DIR"/WithStoryboard/* "$PREX_TEMPLATE_DIR"/PresenterSubclassWithStoryboard/
  cp -R "$PREX_TEMPLATE_DIR"/PresenterSubclass/* "$PREX_TEMPLATE_DIR"/PresenterSubclassWithXIB/
  cp -R "$PREX_TEMPLATE_DIR"/PresenterSubclass/* "$PREX_TEMPLATE_DIR"/PresenterSubclassWithStoryboard/
  cp -R "$PREX_TEMPLATE_DIR"/Default/* "$PREX_TEMPLATE_DIR"/WithXIB/
  cp -R "$PREX_TEMPLATE_DIR"/Default/* "$PREX_TEMPLATE_DIR"/WithStoryboard/
}

xcodeTemplate

echo "==> ... success!"
echo "==> Prex have been set up. In Xcode, select 'New File...' to use Prex templates."
