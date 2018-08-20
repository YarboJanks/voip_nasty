#!/bin/bash
#check for depoz
t=12
f=0

#pretty colors
cyan='\e[0;36m'
green='\e[0;34m'
okegreen='\033[92m'
lightgreen='\e[1;32m'
white='\e[1;37m'
red='\e[1;31m'
yellow='\e[0;33m'
BlueF='\e[1;34m'
RESET="\033[00m"
orange='\e[38;5;166m'

echo -e "$cyan Checking dependancies now, please wait..."

### validation that dependancies exist ###
python_exists=$(rpm -qa | grep python27) #not null

#**NOTE**: To fix the makefiles for wav2rtp, edit the 'CFLAGS' in ALL Makefiles to include '-lm -ldl'
wav2rtp_exists=$(ls -alh /opt/wav2rtp/bin/wav2rtp | grep wav2rtp) #looking for not null

spectrology_pil=$(python2 -c "import PIL") #pip install pillow
spectrology_wave=$(python2 -c "import wave")
spectrology_math=$(python2 -c "import math")
spectrology_array=$(python2 -c "import array")
spectrology_argparse=$(python2 -c "import argparse")
spectrology_sys=$(python2 -c "import sys")
spectrology_timeit=$(python2 -c "import timeit")

ourscript_termcolor=$(python2 -c "import termcolor")

sipp_exists=$(rpm -qa | grep sipp) #looking for not null

sippyCup_exists=$(sippy_cup --version|grep version)

### beautification functions
pretties_good() {
  echo -e "$white [$okegreen $1 is installed! \u2713 $white]"
}
pretties_bad() {
  echo -e "$white [$red $1 is missing! \u2718 $white]"
}
pretties_fixit() {
  echo -e "$yellow \u2605 $cyan Please run $1 $yellow\u2605"
}
pretties_totals() {
  c=`expr $t - $f`
  echo -e "$orange +----------------------------------------+"
  echo -e "$orange |$white Passed Checks:$okegreen $c \u2713$white Failed Checks:$red $f \u2718$orange |"
  echo -e "$orange +----------------------------------------+$RESET"
}

## check logic
if [[ ! -z "$python_exists" ]]; then
  pretties_good Python2.7
else
  pretties_bad Python2.7
  pretties_fixit "'yum install python27'"
  ((f++))
fi

if [[ ! -z "$wav2rtp_exists" ]]; then
  pretties_good wav2rtp
else
  pretties_bad wav2rtp
  pretties_fixit "'git clone https://github.com/imankulov/wav2rtp.git' and follow the instructions in the README file."
  ((f++))
fi

if [[ ! -z "$sipp_exists" ]]; then
  pretties_good SIPp
else
  pretties_bad SIPp
  pretties_fixit "'git clone https://github.com/SIPp/sipp.git' and follow the instructions in the README file."
  ((f++))
fi

if [[ ! -z "$sippyCup_exists" ]]; then
  pretties_good SippyCup
else
  pretties_bad SippyCup
  pretties_fixit "'git clone https://github.com/wcmac/sippycup.git' and follow the instructions in the README file."
  ((f++))
fi

if [[ -z "$spectrology_pil" ]]; then
  pretties_good PIL
else
  pretties_bad PIL
  pretties_fixit "'sudo pip install pillow'"
  ((f++))
fi

if [[ -z "$spectrology_wave" ]]; then
  pretties_good wave
else
  pretties_bad wave
pretties_fixit "'sudo pip install wave'"
  ((f++))
fi

if [[ -z "$spectrology_math" ]]; then
  pretties_good math
else
  pretties_bad math
pretties_fixit "'sudo pip install math'"
  ((f++))
fi

if [[ -z "$spectrology_array" ]]; then
  pretties_good array
else
  pretties_bad array
pretties_fixit "'sudo pip install array'"
  ((f++))
fi

if [[ -z "$spectrology_argparse" ]]; then
  pretties_good argparse
else
  pretties_bad argparse
  pretties_fixit "'sudo pip install argparse'"
  ((f++))
fi

if [[ -z "$spectrology_sys" ]]; then
  pretties_good sys
else
  pretties_bad sys
  pretties_fixit "'sudo pip install sys'"
  ((f++))
fi

if [[ -z "$spectrology_timeit" ]]; then
  pretties_good timeit
else
  pretties_bad timeit
  pretties_fixit "'sudo pip install timeit'"
  ((f++))
fi

if [[ -z "$ourscript_termcolor" ]]; then
  pretties_good termcolor
else
  pretties_bad termcolor
  pretties_fixit "'sudo pip install termcolor'"
  ((f++))
fi

pretties_totals
