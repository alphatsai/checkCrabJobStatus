#!/bin/tcsh
if ( $1 == "" ) then
	echo ">> [INFO] Please put crab directory"
	echo "          ./checkstatus.csh [crabDir]"
	echo ">> [INFO] Exit!" 
	exit
endif
if ( ! ( -e $1 ) ) then
	echo ">> [ERROR] There is no $1 here, please check!"
	echo ">> [INFO] Exit!" 
	exit
endif

set here=$PWD
set PWD=$here  # fixed the enviroment path
alias getNumberFromTotal "source $PWD/getNumberFromTotal.csh"

set crabdir=$1
echo ">> [INFO] $crabdir"
cd $crabdir

	rm -f newstatus_log
	#crab -status -c $crabdir | tee newstatus_log
	echo ">> [INFO] Checking status..."
	crab -status -c $crabdir >! newstatus_log
	cat newstatus_log

	if ( `grep '\-getoutput' newstatus_log` != "" || `grep 'Terminated' newstatus_log | wc -l` != 0 ) then
		crab -get -c $crabdir
		crab -status -c $crabdir >! newstatus_log
		cat newstatus_log
	endif

	cat newstatus_log | grep Created | grep -v '>>' | awk '{a=a","$1; print a}' >! "$crabdir"_created_log 
	set resubJobs_ex=`cat newstatus_log | grep -v 'Wrapper Exit Code : 0' | grep -A 1 'Wrapper Exit Code' | grep List | awk '{print $4}'`
	set resubJobs_ab=`cat newstatus_log | grep -A 2 'Jobs Aborted' | grep -v 'resubmit' | grep List | awk '{print $4}'`
	set resubJobs_ca=`cat newstatus_log | grep -A 1 'Jobs Cancelled' | grep List | awk '{print $5}'`
	set existCode=`   cat newstatus_log | grep -v 'Wrapper Exit Code : 0' | grep 'Wrapper Exit Code' | awk '{print $9}'`
	
	set lines=`cat "$crabdir"_created_log | wc -l`
	if ( $lines > 0 ) then
		echo ">> [INFO] $lines jobs created but not submitted:"
		echo ">> [INFO] Do you went to submit created jobs (Y/N)?"
		set yn=$<
	       	while ( $yn != "N" && $yn != "n")
	               	if ( $yn == "Y" || $yn == "y") then
				if ( $lines > 2000 ) then
					echo ">> [WARNING] Too many jobs, spliting 3..."
					set first=` head -n1000 "$crabdir"_created_log | tail -n1 | sed 's/^,//g'`
					set second=`head -n1800 "$crabdir"_created_log | tail -n1 | sed "s/^,$first,//g"`
					set third=` tail -n1 "$crabdir"_created_log | sed "s/^,$first,//g" | sed "s/$second,//g"`
					set firstsec=`getNumberFromTotal $first`
					echo ">>           Done 1/3"
					set secondsec=`getNumberFromTotal $second`
					echo ">>           Done 2/3"
					set thirdsec=`getNumberFromTotal $third`
					echo ">>           Done 3/3"
					foreach resub($firstsec)
						set jobs=`echo $resub | awk -F ":" '{print $2}'`
						crab -submit $jobs -c $crabdir
					end
					foreach resub($secondsec)
						set jobs=`echo $resub | awk -F ":" '{print $2}'`
						crab -submit $jobs -c $crabdir
					end
					foreach resub($thirdsec)
						set jobs=`echo $resub | awk -F ":" '{print $2}'`
						crab -submit $jobs -c $crabdir
					end
				else if ( $lines > 500 ) then
					echo ">> [WARNING] Too many jobs, spliting 2..."
					set first=` head -n500 "$crabdir"_created_log | tail -n1 | sed 's/^,//g'`
					set second=` tail -n1 "$crabdir"_created_log | tail -n1 | sed "s/^,$first,//g"`
					set firstsec=`getNumberFromTotal $first`
					echo ">>           Done 1/2"
					set secondsec=`getNumberFromTotal $second`
					echo ">>           Done 2/2"
					foreach resub($firstsec)
						set jobs=`echo $resub | awk -F ":" '{print $2}'`
						crab -submit $jobs -c $crabdir
					end
					foreach resub($secondsec)
						set jobs=`echo $resub | awk -F ":" '{print $2}'`
						crab -submit $jobs -c $crabdir
					end
				else
					set first=`tail -n1 "$crabdir"_created_log | sed 's/^,//g'`
					set firstsec=`getNumberFromTotal $first`
					foreach resub($firstsec)
						set jobs=`echo $resub | awk -F ":" '{print $2}'`
						crab -submit $jobs -c $crabdir
					end
				endif
	       			crab -status -c $crabdir >! newstatus_log
				cat newstatus_log
	       			echo ">> [INFO] crab -submit done !\n"
	       			break
			else
				echo ">> [INFO] Do you went to submit created jobs (Y/N)?"
	       			set yn=$<
			endif
		end
	endif

	if ( "$resubJobs_ex" == "" && "$resubJobs_ab" == "" && "$resubJobs_ca" == ""  ) then
		echo ">> [INFO] There are no any job can resubmit"
	else
		set resubJobsex=`echo $resubJobs_ex | sed 's/\ /,/g'`
		set resubJobsab=`echo $resubJobs_ab`
		set resubJobsca=`echo $resubJobs_ca`
		echo ">> [INFO] Some jobs failed"
		if ( "$resubJobsex" != "" ) then
			echo "		Exist codes   : $existCode"
			echo "		Fialed jobs   : $resubJobsex"
		endif
		if ( $resubJobs_ab != "" ) then
			echo "		Aborted jobs  : $resubJobs_ab"
		endif
		if ( $resubJobs_ca != "" ) then
			echo "		Cancelled jobs: $resubJobs_ca"
		endif
		echo ">> [INFO] Do you went use crab -resubmit (Y/N)?"
		set yn=$<
        	while ( $yn != "N" && $yn != "n")
                	if ( $yn == "Y" || $yn == "y") then
				if ( $resubJobsex != "" ) then
					set resubsec=`getNumberFromTotal $resubJobsex`
					foreach resub($resubsec)
						set jobs=`echo $resub | awk -F ":" '{print $2}'`
						crab -resubmit $jobs -c $crabdir
					end
				endif
				if ( $resubJobsab != "" ) then
					set resubsec=`getNumberFromTotal $resubJobsab`
					foreach resub($resubsec)
						set jobs=`echo $resub | awk -F ":" '{print $2}'`
						crab -resubmit $jobs -c $crabdir
					end
				endif
				if ( $resubJobsca != "" ) then
					set resubsec=`getNumberFromTotal $resubJobsca`
					foreach resub($resubsec)
						set jobs=`echo $resub | awk -F ":" '{print $2}'`
						crab -kill $jobs -c $crabdir
						crab -resubmit $jobs -c $crabdir
					end
				endif
        			crab -status -c $crabdir >! newstatus_log
				cat newstatus_log
       				echo ">> [INFO] crab -resubmit done !\n"
        			break
			else
        			echo ">> [INFO] Do you went use crab -resubmit (Y/N)?"
        			set yn=$<
			endif
		end
	endif
cd -
ls -l
echo "$crabdir" >> done_log
echo ">> [INFO] $crabdir DONE!"

