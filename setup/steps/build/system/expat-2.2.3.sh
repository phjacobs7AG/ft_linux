#!/bin/bash

pkg_source="expat-2.2.3.tar.bz2"

pkg_name="$(basename $(tar -tf $1/$pkg_source | head -n 1 | cut -d'/' -f 1))"

base_dir=$1
log_file=$2"/"$(echo $pkg_name)".log"

status=0

setup(){
	cd $base_dir												|| return
	tar -xf $pkg_source											|| return
	cd $pkg_name												|| return
}

build(){
	sed -i 's|usr/bin/env |bin/|' run.sh.in						|| return


	./configure --prefix=/usr --disable-static					|| return
	make														|| return
	make install												|| return
	install -v -dm755 /usr/share/doc/expat-2.2.3				|| return
	install -v -m644 doc/*.{html,png,css} /usr/share/doc/expat-2.2.3	|| return
}

teardown(){
	cd $base_dir
	rm -rfv $pkg_name
}

# Internal process

if [ $status -eq 0 ]; then
	setup >> $log_file 2>&1
	status=$?
fi

if [ $status -eq 0 ]; then
	build >> $log_file 2>&1
	status=$?
fi

if [ $status -eq 0 ]; then
	teardown >> $log_file 2>&1
	status=$?
fi

exit $status
