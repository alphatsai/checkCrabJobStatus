#!/bin/bash
if [ "$1" == '' ]; then
	echo ">> [INFO] Usage ./cptoCERNEOS [datcrad]"
	echo ">>        datacrad : [local path];[target path]"
	echo ">>                   /eos/.../mydir;/eos/store/cms/.../newdir"
	exit
fi

datas=`cat $1 | grep -v "^#"`
ndatas=`echo $datas | wc -w`
if [ "$ndatas" != 0 ]; then
	grid-proxy-init -valid 30:00
	export PATH=/usr/java/jdk1.5.0_10/bin/:$PATH
fi

for data in $datas
do
	loc=`echo $data | awk -F ";" '{print $1}'`
	tar=`echo $data | awk -F ";" '{print $2}'`
	if [ ! -e "$loc" ]; then
		echo ">> [ERROR] $loc not found!"
		exit
	fi
	roots=`ls -l $loc | grep root | awk '{print $9}'` 
	nroots=`echo $roots | wc -w`
	echo ">> [INFO] Transfer $nroots files"
	echo ">>        From: $loc"
	echo ">>        To: $tar"
	echo ">>        ( Please make sure the target directory exist in remote site )"
	echo ">>        Copying (0/$nroots)... "
	if [ "$nroots" != 0 ]; then
		num=1
		for root in $roots
		do
			#echo srmcp file:///$loc/$root "srm://srm-eoscms.cern.ch:8443/srm/v2/server?SFN=$tar/$root"
			sleep 5
			srmcp "file:///$loc/$root" "srm://srm-eoscms.cern.ch:8443/srm/v2/server?SFN=$tar/$root"
			if [ `echo $num%100 | bc` == 0 ]; then
				echo ">>        Copying $num/$nroots..."
			fi
			num=`echo $num+1 | bc`
		done
	fi
	echo ">>        Done!"
done
echo ">> [INFO] Done with $1"

#srmcp -debug=true -2  file:////eos/uscms/store/user/jtsai/bprimeKit/CMSSW_5_3_11_data_8TeV_22Jan2013ReReco_AOD/SingleMu_Run2012A-22Jan2013-v1_190645-193621/results_37_1_6OM.root "srm://srm-eoscms.cern.ch:8443/srm/v2/server?SFN=/eos/cms/store/group/phys_b2g/BprimeKit_Ntuples_Data/Run2012ReReco/test/test.root"
#srmcp -h
