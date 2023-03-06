# Actual Installer extractor for Linux

[Actual Installer](https://www.actualinstaller.com/) is a free installer for Windows platforms.
It provides a self-extracting executable.

When you are on Linux, you might want to extract the files contained in the installer.
For this you can use this 'extractActualInstaller.sh' shell script.

`./extractActualInstaller.sh -d ./my_extracted_files ./Install.exe`

Note that you should have the 'binwalk' executable on your path.
If the shell script complains that it can not find it, please install it using your distribution specific method.
