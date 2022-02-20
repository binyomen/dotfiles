@echo off

if [%1]==[] (
    echo Exactly one argument must be provided.
    exit 1
)
if not [%2]==[] (
    echo Exactly one argument must be provided.
    exit 1
)

set filename="%1"
blender --background %filename% --python "%~dp0\catblend.py"
