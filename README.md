CI
==

Script to make a continuous integration server using a test server and a GIT repository
usage: ./ci.sh /path/to/repos /path/to/deployment test-command
Checks for a new revision, tests it if it exists and deploys it if the tests pass. Since this script cannot type your password, you have to make sure GIT will not ask for one.


## How to make GIT not ask for a password?
1. Use SSH keys
2. Use git-credential-cache
3. Use the format https://username:password@somehost.com/your/repo.git


## How to set up your repo?
- git init
- git remote add origin git@somehost.com/your/repo.git
- git branch.master.merge refs/heads/master
- git branch.master.remote origin


## Do not want to execute this script yourself?
This script is meant to be scheduled using a cronjob.


## Do not want to test?
Pass echo as test-command, it will get the revision id as argument and its output will be discarted. But it will succeed (return 0).


# Do not want to deploy?
Deployment is only done if the test-command returns 0, so just make a test that returns 1...
This could be usefull if you are working with an application server, the test-command should then run tests, do the actual deployment and return 1 to disable the deployment behavior of this script.
