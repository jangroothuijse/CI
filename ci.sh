#!/bin/bash
#
# simple script to watch a git repos, test a new revision and deploy to some location
# Copyright (c) 2014 Jan Groothuijse
#
# @arg1 path to local git repos
# @arg2 path to deployment target
# @arg3 command to test this revision, the revision id will be added as argument to this command
#
USAGE="/path/to/repos /path/to/deployment test-command"
LONG_USAGE="Checks for a new revision, tests it if it exists and deploys it if the tests pass"

# sanitize and help
if [ $1 = '--help' ] || [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]
then echo $LONG_USAGE; echo "Usage: $0 $USAGE"; exit 1; 
fi

# *** PULL GIT ***
# cd to target directory
cd $1
# get the output of a git pull in that directory
pulloutput=$(git pull 2>&1)

if [[ $pulloutput == *pull\ without* ]] 
then
	echo $pulloutput
	exit 1
fi

# check the output to see if there is a new revision
if [[ $pulloutput == *up-to-date* ]]
then
	# apparently there is no new revision so this script will stop
	# in order not to flood cron-log files we will opt to handle this silently
	exit 0
fi

# get the short version of the revision hash, short in order to aid human readability
revisionId=$(git log --pretty=format:'%h' -n 1 2>&1)
echo "Pulled $revisionId"

# *** RUN TEST ***
# test revision, argument 3 is expected to be a command, revisionId is passed as (last) arg
if $3 $revisionId &> /dev/null
then
	# *** DEPLOY ***
	# revision passed the test, deploying
	if [ -d $2/$revisionId ]; then echo "$2/$revisionId already exists, aborting deployment"; exit 0; fi
	# copy to its very own target directory
	mkdir $2/$revisionId
	git archive master | tar -x -C $2/$revisionId

	# set symlink
	ln -sfn $2/$revisionId $2/current
	echo "Deployed $revisionId in $2/current"
else
	# revision did not pass the test, output some log information
	echo "[$0] revision $revisionId of $1 failed to pass $3 $revisionId, build failed, not deploying."
fi
