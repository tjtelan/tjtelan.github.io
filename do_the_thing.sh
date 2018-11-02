# Don't actually run this script right now.
#!/usr/bin/env/ sh
gutenberg build
pipenv shell run ghp-import -n -c tjtelan.com -b master -m "${1}" -p public
