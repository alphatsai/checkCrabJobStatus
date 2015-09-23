#!/bin/tcsh
if ( $1 == "" ) then
	echo ">> [INFO] Please put data card"
	echo ">> 	./runAll.csh [card]"
	exit
endif
voms-proxy-init -voms cms -valid 192:0                         ##certificate
cmsenv
source /cvmfs/cms.cern.ch/crab/crab.csh

set files=`cat $1`
foreach file($files)
	source checkstatus.csh $file
end
