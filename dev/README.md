Development of blink-infra brings some unique challenges:
* The whole pipelines runs over an hour. Very large feedback cycles
* If something breaks in the middle, it's sometimes difficult to recover from it. This is true in two ways: resstarting that job which just failed and also cleaning up so that the whole pipeline is ready for a next proper run.

So in order to get to a new run, this is the recommended procedure:
```
# clean the project
./dev/scrub_project.sh infra-testflight

# clean the tfstate
./dev/scrub_tfstate.sh

# bump the version
./dev/bump_version.sh

# clean the locks
./dev/scrub_locks.sh

```
