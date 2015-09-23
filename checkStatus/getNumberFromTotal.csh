#!/bin/tcsh
alias getNumberFromRange "source $PWD/getNumberFromRange.csh"
alias getSplitedJobRange "source $PWD/getSplitedJobRange.csh"

rm -f num_tmp3_log
rm -f num_tmp2_log
rm -f num_tmp1_log
set outsec=""
set totalNum=0
set count=0
set secs=`echo $1 | sed 's/,/ /g'`
set i=1
foreach sec($secs)
	set num=`getNumberFromRange $sec | awk '{print $1}'`
	@ totalNum += $num
	if ( $totalNum <= 500 ) then
		if ( $outsec != "" ) then
			set outsec=$outsec'_'
		endif
		set outsec=$outsec$sec
		echo $totalNum':'$outsec >! num_tmp1_log
		echo $totalNum':'$outsec >> num_tmp2_log
	else
		set allsecs=`getSplitedJobRange $sec`
		set secNums=`echo $allsecs | wc -w`

		if ( $secNums > 1 ) then
			if (`tail -n1 num_tmp2_log` != `tail -n1 num_tmp1_log`) then
			#if ( $count <= 500 && $count != 0 ) then
				tail -n1 num_tmp2_log >> num_tmp1_log
			endif

			rm -f num_tmp3_log
			foreach subsec($allsecs)
				echo $subsec >> num_tmp3_log
			end
			set saveline=`echo $secNums"-1" | bc`
			head -n$saveline num_tmp3_log >> num_tmp1_log
			tail -n1 num_tmp3_log >> num_tmp2_log
		else
			set subnum=`echo $allsecs | awk -F ":" '{print $1}'`
			set subsec=`echo $allsecs | awk -F ":" '{print $2}'`
			set npart=`cat num_tmp2_log | wc -l`
			set allsec=`cat num_tmp2_log`
			set last=`echo $allsec[$npart]`
			set lastNum=`echo $last | awk -F ":" '{print $1}'`
			set lastSec=`echo $last | awk -F ":" '{print $2}'`
			set count=`echo $lastNum'+'$subnum | bc`
			if ( $count <= 500 ) then
				echo $count':'$lastSec'_'$subsec >> num_tmp2_log
			else
				if (`tail -n1 num_tmp2_log` != `tail -n1 num_tmp1_log`) then
					tail -n1 num_tmp2_log >> num_tmp1_log
				endif
				echo $num':'$subsec >> num_tmp2_log
			endif 
		endif
	endif
	@ i++
end
if (`tail -n1 num_tmp2_log` != `tail -n1 num_tmp1_log`) then
	tail -n1 num_tmp2_log >> num_tmp1_log
endif

set out=`cat num_tmp1_log`
echo $out | sed 's/_/,/g'
rm -f num_tmp3_log
rm -f num_tmp2_log
rm -f num_tmp1_log
