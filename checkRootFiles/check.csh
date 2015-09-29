#!/bin/tcsh
#########################################################################
################### check for the parameter or not#######################
#########################################################################
if ( $3 == "" ) then
	echo ">> [INFO] Usage for checking files for eos"
	echo ">>        ./check_lxplus.csh [Path] [Job Number] [server]"
        echo ">>        [server] cmslpc or lxplus"
	echo ">>        Ex: ./check.csh /dpm/phys.ntu.edu.tw/.../... 100 cmslpc"
	exit	
endif

if ( $3 != 'cmslpc' && $3 != 'lxplus' ) then
    echo ">> [ERROR] $3 wrong server options: cmslpc or lxplus"
    exit
endif

#########################################################################
################### check the number of the root ########################
#########################################################################
set fileName='results'

set path_1=$1
set dir=` echo $path_1 | sed 's/\/$//g' | sed 's/^\/.*\/\(.*\)$/\1/g'`
set dir2=`echo $path_1 | sed 's/\/$//g' | sed "s/^\/.*\/\(.*\)\/$dir/\1/g"`
set totalnum=$2 
set endnum=0  
@ endnum=$totalnum + 1
rm -f "tmp1$dir" "tmp2$dir" "tmp3$dir" "check_log/NotDone_ll_"$dir2"_ll_"$dir"" "check_log/Done_ll_"$dir2"_ll_"$dir"" "check_log/Duplicate_ll_"$dir2"_ll_"$dir""

echo ">------------------------------------------------------------------<"
echo ">> [INFO] Check $dir "
######################### record dataests  ##############################
echo ">>        Catching EOS..."
if ( $3 == 'lxplus' ) then
    eos ls -l $path_1 | grep '.root' | awk '{print $9"/"$5"/"$6"/"$7"/"$8}' > "tmp1$dir" #reall name/size/mounth/day/hour:min

else if ( $3 == 'cmslpc' ) then
    ls -l $path_1 | grep '.root' | awk '{print $9"/"$5"/"$6"/"$7"/"$8}' > "tmp1$dir" #reall name/size/mounth/day/hour:min

endif

if ( `cat "tmp1$dir"` == "" ) then
	echo ">> [WARING] Nothing here: "
        echo ">>          $path_1"
	rm -f "tmp1$dir"
	exit
endif
set list=`cat "tmp1$dir"`

##################### record and count the file ##########################
echo ">>        Recording num of each $fileName.root..."
set i=1
touch "tmp2$dir"
while ( $i != $endnum )
	set rootnum=`grep $fileName'_'$i'_' "tmp1$dir"| wc -l` # Plaese change the name of the file (EX: myRoot_1_1_sjoe.root, results->myRoot )
	echo $rootnum >> "tmp2$dir"
	@ i++			
end
set size=`cat "tmp2$dir"`

#################### check the appear times ##############################
mkdir check_log >& "tmp3$dir"
rm -f "check_log/cklog1_$dir" "check_log/cklog2_$dir"
touch "check_log/cklog1_$dir" "check_log/cklog2_$dir"

set no_count=0
set many_count=0
set i=1
echo ">>        Making log file in ./check_log..."
foreach n($size)
	if      ( $n == 0 ) then
                echo "Num $i .root is not exit  " >> "check_log/cklog1_$dir" 
		@ no_count++
        else if ( $n == 1 ) then
		#echo "Num $i ok !  "
	else  
		echo "--------------------------------------------------------" >> "check_log/cklog2_$dir"
		echo "Num $i have $n root " >> "check_log/cklog2_$dir"
		echo "--------------------------------------------------------" >> "check_log/cklog2_$dir"
		cat -A "tmp1$dir" | grep $fileName'_'$i'_' | awk -F "/" '{print $1"    "$2"    "$3" "$4" "$5}' | sed 's/\^\[\[00m//g' >> "check_log/cklog2_$dir" # Plaese change the name of the file (EX: myRoot_1_1_sjoe.root, results->myRoot )
		echo "--------------------------------------------------------" >> "check_log/cklog2_$dir"
		echo "" >> "check_log/cklog2_$dir"
		@ many_count++
	endif
	@ i++
end
if ( $no_count != 0 || $many_count != 0 ) then
	echo "###########################################################" 	>! check_log/NotDone_ll_"$dir2"_ll_"$dir"
	echo "################ No Datasets Exist $no_count ##################" 	>> check_log/NotDone_ll_"$dir2"_ll_"$dir"
	echo "###########################################################" 	>> check_log/NotDone_ll_"$dir2"_ll_"$dir"
	cat "check_log/cklog1_$dir" 						>> check_log/NotDone_ll_"$dir2"_ll_"$dir"
	echo "" 								>> check_log/NotDone_ll_"$dir2"_ll_"$dir"
	echo "###########################################################" 	>> check_log/NotDone_ll_"$dir2"_ll_"$dir"
	echo "######### Mutiples Datasets: Name Size $many_count #############" >> check_log/NotDone_ll_"$dir2"_ll_"$dir"
	echo "###########################################################" 	>> check_log/NotDone_ll_"$dir2"_ll_"$dir"
	cat "check_log/cklog2_$dir" 						>> check_log/NotDone_ll_"$dir2"_ll_"$dir"
endif
if ( `head check_log/cklog1_$dir` == "" && `head check_log/cklog2_$dir` == "" ) then
	echo ">>        [DONE] All are correct!"
	rm -f check_log/NotDone_ll_"$dir2"_ll_"$dir"
	echo "All Done" > check_log/Done_ll_"$dir2"_ll_"$dir"
else if ( `head check_log/cklog1_$dir` == "" && `head check_log/cklog2_$dir` != "" ) then
	echo ">>        [Duplicate] Duplicates exsist"
	mv check_log/NotDone_ll_"$dir2"_ll_"$dir" check_log/Duplicate_ll_"$dir2"_ll_"$dir"	
endif
set susNum=0.
@ susNum=$totalnum - $no_count
set statusEff=`echo "scale=1 ; $susNum*100/$totalnum"| bc`
echo ">>        Status: "$statusEff'% ('$susNum'/'$totalnum')' 

rm -f  "tmp1$dir" "tmp2$dir" "tmp3$dir" "check_log/cklog1_$dir" "check_log/cklog2_$dir"
#rm -f  "tmp3$dir" "check_log/cklog1_$dir" "check_log/cklog2_$dir"
#########################################################################
#########################################################################
#########################################################################


