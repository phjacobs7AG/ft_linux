#!/bin/bash

pkg_source="procps-ng-3.3.12.tar.xz"

pkg_name="$(basename $(tar -tf $1/$pkg_source | head -n 1 | cut -d'/' -f 1))"

base_dir=$1
log_file=$2"/"$(echo $pkg_name)".log"

status=0

setup(){
	cd $base_dir																|| return
	tar -xf $pkg_source															|| return
	cd $pkg_name																|| return
}

build(){
	./configure --prefix=/usr						\
		--exec-prefix=								\
		--libdir=/usr/lib							\
		--docdir=/usr/share/doc/procps-ng-3.3.12	\
		--disable-static							\
		--disable-kill									|| return
	make																		|| return
	
	sed -i -r 's|(pmap_initname)\\\$|\1|' testsuite/pmap.test/pmap.exp
	sed -i '/set tty/d' testsuite/pkill.test/pkill.exp
	rm testsuite/pgrep.test/pgrep.exp



	make install																|| return
	mv -v /usr/lib/libprocps.so.* /lib											|| return
	ln -sfv ../../lib/$(readlink /usr/lib/libprocps.so) /usr/lib/libprocps.so	|| return
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
