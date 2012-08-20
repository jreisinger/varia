Various stuff
=============

moin2md.pl
-----------
Convert MoinMoin wiki markup to Markdown markup.

parse_jakubs_log.pl
-------------------
Go through log file and get total values of parameters of certain section.

proxyfyme.pl
------------
Script that gets your command through proxy that requires authentication.

Installation
 * Place `proxyfyme.pl` in `~/bin/scripts`.
 * Change mode: `chmod 755 ~/scripts/proxyfyme.pl`
 * Add this to `~/.bashrc`: alias proxyfyme="~/scripts/proxyfyme.pl"

Sample usage:
 * `proxyfyme cpanm Nmap::Parser`

tidy_mp3.pl
-----------
Create folder hierarchy based on MP3 tags. Based on: http://www.perlmonks.org/?node_id=985820.

To get mp3 files from directories:

    find /path/to/mp3_dirs/ -iname '*.mp3' -exec cp "{}" . \;
