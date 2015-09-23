#/bin/tcsh
alias getNumberFromRange "source $PWD/getNumberFromRange.csh"

set info=`getNumberFromRange $1`
set totalNum=`echo $info | awk '{print $1}'`
set first=`echo $info | awk '{print $2}'`
set last=` echo $info | awk '{print $3}'`

if ( $totalNum > 500 ) then
	set count_=`echo "scale=5; $totalNum/500" | bc`
	set count=` echo "scale=0; $totalNum/500" | bc`
	if ( `echo $count_'%1' | bc` != 0 ) then
		@ count++
	endif

	set i=1
	set out=""
	set newfirst=0
	set newlast=0
	while ( $i <= $count )
		if ( $i == 1 ) then
			set newfirst=$first
		else
			set newfirst=`echo $newlast+1 | bc`
		endif

		set newlast=`echo $newfirst+499 | bc`
		if ( $newlast > $last ) then
			set newlast=$last
		endif

		set num=`echo $newlast-$newfirst+1 | bc`
		if ( $i == 1 ) then
			set out=`echo $num":"$newfirst"-"$newlast`
		else if ( $newlast > $newfirst ) then
			set out=`echo $out $num":"$newfirst"-"$newlast`
		else
			set out=`echo $out $num":"$newfirst`
		endif
		@ i++
	end
	echo $out
else
	echo $totalNum":"$1
endif

