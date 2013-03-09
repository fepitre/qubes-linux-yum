#!/bin/sh


# $1 -- path to rpm dir
check_repo()
{
    if rpm --checksig $1/*.rpm | grep -v pgp > /dev/null ; then
        echo "ERROR: There are unsigned RPM packages in $1 repo:"
        echo "---------------------------------------"
        rpm --checksig $1/*.rpm | grep -v pgp 
        echo "---------------------------------------"
        echo "Sign them before proceeding."
        exit 1
    fi
}


update_repo()
{
    createrepo --update $1 > /dev/null
}

is_repo_empty() {
    ls $1/rpm/*.rpm > /dev/null 2>&1 || return 0
    return 1
}

REPOS_TO_UPDATE="current-release/unstable/dom0 current-release/unstable/vm/*"

for repo in $REPOS_TO_UPDATE ; do
    echo "--> Processing repo: $repo..."
    if ! is_repo_empty $repo ; then
        check_repo $repo/rpm -o $repo/repodata || exit 1
    fi
    update_repo $repo -o $repo/repodata || exit 1
done
echo Done.

#yum clean metadata
