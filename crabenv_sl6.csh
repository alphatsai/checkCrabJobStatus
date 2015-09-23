#!/bin/tcsh
#setenv SCRAM_ARCH slc5_amd64_gcc462                            ##CMSSW_5_3_X
voms-proxy-init -voms cms -valid 192:0                         ##certificate
cmsenv
source /cvmfs/cms.cern.ch/crab/crab.csh
