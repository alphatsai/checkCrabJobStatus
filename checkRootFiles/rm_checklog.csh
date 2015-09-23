#!/bin/tcsh
###############################################################################
#################### Check here is check_log or not ###########################
###############################################################################
if ( !( -e check_log ) ) then
	echo ">> [WARNING]: Here is no check_log directory !"
	echo ">>            Please do the ./check.csh or ./checkAll.csh first"
	echo ">>            Both will output the directory and log files"
	exit
endif
###############################################################################
#################### Go to check each log file ################################
###############################################################################
rm -f error_
mkdir rmscript >& error_
rm -f rmscript/*
touch rmscript/command
echo ">> [INFO] Cleaned directory rmscript!"

set eospath='/eos/uscms/store/user/jtsai/bprimeKit'
set rootName='results'

cd check_log
	ls -l | grep Duplicate | awk '{print $9}' | grep -v ^$ >! tmp_1
	set log_list = `cat -A tmp_1 | grep -v tmp_1 | sed 's/\^\[\[00m//g' | sed 's/\$//g' | grep -v ^$`
	foreach log($log_list)
		set folder1=`echo $log | awk -F "_ll_" '{print $2}'`
		set folder2=`echo $log | awk -F "_ll_" '{print $3}'`
		set multijobs  = `cat $log | egrep -v 'Datasets|#' | grep Num | awk '{print $2"/"$4}'` #save jobnum/filenum
		set nmultijobs = `echo $multijobs | wc -w` #save jobnum/filenum

		set script="../rmscript/"$folder1"_"$folder2".csh"
		#echo '#!/bin/tcsh'				>! $script
		echo "set dir=$eospath/$folder1/$folder2"		     >! $script
		echo 'if ( ! ( -e $dir ) ) then'			     >> $script
		echo '	echo ">> [WARING] No $dir exsist!"'		     >> $script
		echo '	exit'						     >> $script
		echo 'endif'						     >> $script
		echo 'echo ">> [INFO] Accessing $dir..."'		     >> $script
		echo 'cd $dir'						     >> $script
		echo '	if ( ! ( -e  duplicate ) ) then'		     >> $script
		echo '		mkdir -p duplicate'			     >> $script
		echo '	endif'						     >> $script
		echo ''							     >> $script
		echo '	echo ">>         '$nmultijobs' duplicate jobs"'	     >> $script
		echo '	echo ">>         Moving duplicates to duplicate..."' >> $script
		#echo 'cd -'
		###############################################################################
		############# Find the jobs hase muti-root files ##############################
		###############################################################################
		echo ">> [INFO] Macking script for remove duplicates for $folder1/$folder2..."
		set ncanbemoved=0
		set ncantbemoved=0
		foreach job($multijobs)
			set jobnum  = `echo $job | awk -F "/" '{print $1}'`
			set filenum = `echo $job | awk -F "/" '{print $2}'`
			set file_name = `cat -A $log | grep "$rootName"_"$jobnum"_ | awk '{print $1}' | sed 's/\^\[\[00m//g'`
			set file_size = `cat -A $log | grep "$rootName"_"$jobnum"_ | awk '{print $2}'`
			set i=2
			set count=1
			set end1 = $filenum  
			###############################################################################
			################ Check each muti-root files size the same or not ##############
			###############################################################################
			while ( $i <= $end1 )
				if ( $file_size[1] == $file_size[$i] ) then
					@ count++
				endif	
				@ i++ 
			end
			###############################################################################
			############## Pick the same size muti-root and bulit a rm file ###############
			###############################################################################
			if ( $count == $filenum ) then
				set k=1
				set end2 = $filenum 
				while ( $k < $end2 )
					echo '	mv '$file_name[$k]' duplicate' >> $script
					@ k++ 
				end
				@ ncanbemoved++
			else
				@ ncantbemoved++	
				echo ">>        ** WARING ** No. $jobnum has different size of duplicate roots"
			endif
		end
		echo 'cd -' >> $script
		if ( $ncantbemoved != 0 ) then
			echo ">>        ** WARING ** Total $ncantbemoved jobs with different size of duplicate roots"
		endif

		if ( $ncanbemoved != 0 ) then
			echo "source "$folder1"_"$folder2".csh" >> ../rmscript/command
		else
			rm -f $script	
		endif
	end
	rm -f tmp_1
cd -
rm -f error_
