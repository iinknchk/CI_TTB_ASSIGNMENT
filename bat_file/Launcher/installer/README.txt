Put the Python installer for Windows here, for machines with no internet:

    python-3.12.10-amd64.exe        (from https://www.python.org/downloads/windows/)

Setup.bat looks for installer\python-3*.exe and installs it silently for the
current user (no admin rights needed) when no Python 3.10+ is found.

The pip packages come from bat_file\Launcher\wheelhouse (made with
Make_Wheelhouse.bat on a machine that has internet), so the whole install can be
done offline.

This folder is in .gitignore: the .exe is not committed.
