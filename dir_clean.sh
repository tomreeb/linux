#!/bin/sh
# Empty directory Cleanup
#
# By: Tom Reeb

TARGET_DIR="/data/Complete"

# Remove dot files and directories
rm -rf $TARGET_DIR/*/.*

# Remove empty directories
rmdir $TARGET_DIR/*