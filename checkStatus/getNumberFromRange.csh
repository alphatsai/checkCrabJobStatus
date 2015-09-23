#/bin/tcsh
set num=0
set first=`echo $1 | awk -F "-" '{print $1}'`
set last=` echo $1 | awk -F "-" '{print $2}'`
if ( $last == "" ) then
	@ num++
else
	set all=`echo $last-$first+1 | bc`
	@ num += $all	
endif
echo $num" "$first" "$last
