#!/bin/sh

MAJREL=$1
NUM=$2

# the debian distribution we are working on
DISTRI='stretch'
# the source package we are working on
DPACKAGE='venv-panko' 

# debian epoch to use
DEPOCH=90

if [ "$MAJREL" = '' ] ; then 
	echo 'please enter major Release name'
 	exit 1
fi

if [ "$NUM" = '' ] ; then 
	echo 'please enter first number of the release version (integer)'
 	exit 1
fi

if [ 0 -gt $NUM   ] ; then 
	echo 'please enter first number of the release version (integer)'
 	exit 1
fi

if [ ! -d 'debian' ] ; then 
	echo 'debian directory not available (are you in repo root ?)'
 	exit 1
fi

if [ -e 'debian/.release' ] ; then
	echo 'release file exists ...'
 	exit 1
fi

# check to add git remote |egrep '^upstreame$'; echo $?

# start working

# create and checkout the new branch
git checkout stable/$MAJREL -b stable/$MAJREL

git checkout master -b debian/$DISTRI-$MAJREL

git checkout debian/$DISTRI-$MAJREL


# merge from upstream
git merge $NUM.0.0 --allow-unrelated-histories --no-edit -m "merge tag $NUM.0.0 as initial $MAJREL version"

# create a release file
echo $MAJREL > debian/.release
echo $NUM    >> debian/.release
git add debian/.release

# create some files:
sed "s/__MAJREL__/$MAJREL/g" debian/gbp.conf.in | sed "s/__DISTRI__/$DISTRI/g"   > debian/gbp.conf
git add debian/gbp.conf
sed "s/__MAJREL__/$MAJREL/g" debian/watch.in    | sed "s/__NUM__/$NUM/g"   > debian/watch
git add debian/watch
sed "s/__MAJREL__/$MAJREL/"  debian/control.in                                  > debian/control 
git add debian/control

# create debian changelog
dch --distribution unstable --create --package $DPACKAGE --newversion $DEPOCH:$NUM.0.0-1 "initial for openstack $MAJREL"
git add debian/changelog

# commit and make tag
git commit -m "Add initial debian files for $MAJREL"
git tag debian/$DEPOCH%$NUM.0.0-1 -m "initial $MAJREL release"

echo "to push use:"
echo "git checkout stable/$MAJREL"
echo "git push origin stable/$MAJREL"

echo "git checkout debian/$DISTRI-$MAJREL"
echo "git push origin debian/$DISTRI-$MAJREL"

echo "git push --tags"
