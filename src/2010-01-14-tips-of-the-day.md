# Tips of the Day #

* deleting remote git tags

## Deleting remote git tags ##

Find the tags you want to delete

    git remote update
    git tag -l

Removing a single tag

    git push origin :refs/tags/my_tag_name

Removing a bunch of tags (2009 and 2010)

    git tag -l | grep -e '^20' | perl -ne '`git push origin :refs/tags/$_`'

