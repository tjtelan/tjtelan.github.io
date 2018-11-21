# Don't actually run this script right now.
#!/usr/bin/env/ sh

if [[ $# -eq 0 ]] ; then
    echo 'Please provide a quoted commit message'
    exit 0
fi

docker-compose run zola zola build
pipenv run ghp-import -n -c tjtelan.com -b master -m "${1}" -p public
