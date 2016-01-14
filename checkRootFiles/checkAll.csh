#!/bin/tcsh
if ( $2 == "" ) then
	echo ">> [INFO] Please input the data forder list."
	echo ">>        Ex: ./checkAll.csh [data_card] [server]"
        echo ">>        [data_card]:"
	echo '>>        ................................................................'	
	echo '>>        :    In data_card you should input like as following           :'
	echo '>>        :    Ex: FUll_Path;Jobs_numbers                                :'
	echo '>>        :        /dpm/grid.sinica.edu.tw/.../...;1004                  :'
	echo '>>        ................................................................'
        echo ">>        [server]: cmslpc or lxplus"
	exit	
endif
if ( ! ( -e $1 ) ) then
	echo ">> [WARING] $1 not found, please check."
	exit
endif

if ( $2 != 'cmslpc' && $2 != 'lxplus' ) then
	echo ">> [ERROR] $2 not found server options: cmslpc or lxplus."
        exit
endif

rm -f check_log/status.txt 
touch check_log/status.txt 
#rm -f tmpStatus check_log/status.txt check_log/status.html
#touch check_log/status.txt check_log/status.html
set datasets=`cat "$1" | grep -v "^#"`
foreach data($datasets)
	set name=`echo $data | awk -F ";" '{print $1}'`
	set size=`echo $data | awk -F ";" '{print $2}'`
        source check.csh $name $size $2 | tee -a check_log/status.txt
	#source check.csh $name $size | tee -a tmpStatus
	#set Status=`cat tmpStatus | grep 'Status' | awk '{print $3}'`
	#cat tmpStatus | grep 'Check'  | awk '{print $4}'                                 >> check_log/status.txt 
	#cat tmpStatus | grep 'Status' | awk '{print $4}' | sed 's/(\(.*\)\/\(.*\))/\2/g' >> check_log/status.txt 
	#cat tmpStatus | grep 'DONE'                                                      >> check_log/status.txt 
	#echo 'Status: '$Status                                                           >> check_log/status.txt 
	#echo ""                                                                          >> check_log/status.txt

	#echo '<tr>' >> check_log/status.html
	#if ( $Status == "" ) then
	#	cat tmpStatus | grep 'Start check' | awk '{print $6}' | sed 's/_Summer12_/\/Summer12_/g'| sed 's/\(.*\)/<td><span class="WYSIWYG_COLOR" style="color: red;">\/\1\/AODSIM<\/span><\/td>/g' >> check_log/status.html
	#	echo '<td><span class="WYSIWYG_COLOR" style="color: red;">0</span></td>' >> check_log/status.html
	#else if ( $Status == '100.0%' ) then 
	#	cat tmpStatus | grep 'Start check' | awk '{print $6}' | sed 's/_Summer12_/\/Summer12_/g'| sed 's/\(.*\)/<td>\/\1\/AODSIM<\/td>/g' >> check_log/status.html
	#	echo '<td>'$Status'</td>' >> check_log/status.html
	#else
	#	cat tmpStatus | grep 'Start check' | awk '{print $6}' | sed 's/_Summer12_/\/Summer12_/g'| sed 's/\(.*\)/<td><span class="WYSIWYG_COLOR" style="color: #228b22;">\/\1\/AODSIM<\/span><\/td>/g' >> check_log/status.html
	#	echo '<td><span class="WYSIWYG_COLOR" style="color: #228b22;">'$Status'</span></td>' >> check_log/status.html
	#endif
	#echo '</tr>' >> check_log/status.html
	#rm -f tmpStatus
end
set finish=`cat check_log/status.txt | grep '100.0%'    | wc -l`
set done=`  cat check_log/status.txt | grep 'DONE'      | wc -l`
set dup=`   cat check_log/status.txt | grep 'Duplicate' | wc -l`
set all=`cat $1 | grep -v "^#" | wc -l `
set effall=`echo "scale=1; $finish*100/$all" | bc`
echo "" | tee -a check_log/status.txt
echo ">@ ============================================================== @<" | tee -a check_log/status.txt
echo ">> [INFO] All Jobs: $all"                                             | tee -a check_log/status.txt
echo ">> [INFO] Finished: $finish (Done:$done / Duplicate:$dup)"            | tee -a check_log/status.txt
echo '>> [INFO] Total Status: '$effall'%'                                   | tee -a check_log/status.txt
echo ">@ ============================================================== @<" | tee -a check_log/status.txt
echo ">> [INFO] The error massage will store in the check_log"

