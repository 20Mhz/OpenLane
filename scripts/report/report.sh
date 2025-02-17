#!/bin/bash
# Copyright 2020 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.



path=$1
designName=$2
scriptDir=$3

export SCRIPT_PATH=$3

# This assumes that all these files exist
tritonRoute_log=$(python3 $3/get_file_name.py -p ${path}/logs/routing/ -o tritonRoute.log 2>&1)

cts_log=$(python3 $3/get_file_name.py -p ${path}/logs/cts/ -o cts.log 2>&1)
routing_log=$(python3 $3/get_file_name.py -p ${path}/logs/routing/ -o fastroute.log 2>&1)
placement_log=$(python3 $3/get_file_name.py -p ${path}/logs/placement/ -o replace.log 2>&1)
sta_log=$(python3 $3/get_file_name.py -p ${path}/logs/synthesis/ -o opensta 2>&1)
sta_post_resizer_log=$(python3 $3/get_file_name.py -p ${path}/logs/synthesis/ -o opensta_post_resizer 2>&1)
sta_post_resizer_timing_log=$(python3 $3/get_file_name.py -p ${path}/logs/synthesis/ -o opensta_post_resizer_timing 2>&1)
sta_post_resizer_routing_timing_log=$(python3 $3/get_file_name.py -p ${path}/logs/synthesis/ -o opensta_post_resizer_routing_timing 2>&1)
sta_spef_log=$(python3 $3/get_file_name.py -p ${path}/logs/synthesis/ -o opensta_spef 2>&1)

tritonRoute_drc=$(python3 $3/get_file_name.py -p ${path}/reports/routing/ -o tritonRoute.drc 2>&1)
yosys_rprt=$(python3 $3/get_file_name.py -p ${path}/reports/synthesis/ -o .stat.rpt -io 2>&1)
routed_runtime_rpt=${path}/reports/routed_runtime.txt
total_runtime_rpt=${path}/reports/total_runtime.txt
wns_rpt=$(python3 $3/get_file_name.py -p ${path}/reports/synthesis/ -o opensta_wns.rpt 2>&1)
pl_wns_rpt=$(python3 $3/get_file_name.py -p ${path}/reports/placement/ -o replace.log 2>&1)
opt_wns_rpt=$(python3 $3/get_file_name.py -p ${path}/reports/synthesis/ -o opensta_post_resizer_timing_wns.rpt 2>&1)
fr_wns_rpt=$(python3 $3/get_file_name.py -p ${path}/logs/routing/ -o fastroute.log 2>&1)
spef_wns_rpt=$(python3 $3/get_file_name.py -p ${path}/reports/synthesis/ -o opensta_spef_wns.rpt 2>&1)
tns_rpt=$(python3 $3/get_file_name.py -p ${path}/reports/synthesis/ -o opensta_tns.rpt 2>&1)
pl_tns_rpt=$(python3 $3/get_file_name.py -p ${path}/reports/placement/ -o replace.log 2>&1)
opt_tns_rpt=$(python3 $3/get_file_name.py -p ${path}/reports/synthesis/ -o opensta_post_resizer_timing_tns.rpt 2>&1)
fr_tns_rpt=$(python3 $3/get_file_name.py -p  ${path}/reports/routing/ -o fastroute.log 2>&1)
spef_tns_rpt=$(python3 $3/get_file_name.py -p ${path}/reports/synthesis/ -o opensta_spef_tns.rpt 2>&1)
HPWL_rpt=$(python3 $3/get_file_name.py -p ${path}/logs/placement/ -o replace.log 2>&1)
yosys_log=$(python3 $3/get_file_name.py -p ${path}/logs/synthesis/ -o yosys.log 2>&1)
magic_drc=$(python3 $3/get_file_name.py -p ${path}/reports/magic/ -o magic.drc 2>&1)
klayout_drc=$(python3 $3/get_file_name.py -p ${path}/reports/klayout/ -o magic.lydrc -io 2>&1)
tapcell_log=$(python3 $3/get_file_name.py -p ${path}/logs/floorplan/ -o tapcell.log 2>&1)
diodes_log=$(python3 $3/get_file_name.py -p ${path}/logs/placement/ -o diodes.log 2>&1)
magic_antenna_report=$(python3 $3/get_file_name.py -p ${path}/reports/magic/ -o magic.antenna_violators.rpt 2>&1)
arc_antenna_report=$(python3 $3/get_file_name.py -p ${path}/reports/routing/ -o antenna.rpt 2>&1)
fr_log=${path}/logs/routing/fastroute.log
cvc_log=$(python3 $3/get_file_name.py -p ${path}/logs/cvc/ -o cvc_screen.log 2>&1)
tritonRoute_def=$(python3 $3/get_file_name.py -p ${path}/results/routing/ -o ${designName}.def 2>&1)
replace_log=$(python3 $3/get_file_name.py -p ${path}/logs/placement/ -o replace.log 2>&1)
lvs_report=${path}/results/lvs/${designName}.lvs_parsed.*.log

test_file() {
        # Tests if a log file exists and is greater than 10 bytes
        find $1 -type f -size +10c 2> /dev/null
}

parse_to_report() {
        export LOG=$1
        export REPORT_PATH=$2
        export REPORT=$3
        export FROM=$4
        export TO=$5
        python3 $SCRIPT_PATH/report_parser.py $LOG $(python3 $SCRIPT_PATH/get_file_name.py -p ${REPORT_PATH} -o ${REPORT} 2>&1) $FROM $TO
}

REPORT_PATH=${path}/reports/cts/
if [[ $(test_file $cts_log) ]]; then
        parse_to_report $cts_log $REPORT_PATH cts.timing.rpt timing_report timing_report_end
        parse_to_report $cts_log $REPORT_PATH cts.timing.rpt timing_report timing_report_end
        parse_to_report $cts_log $REPORT_PATH cts.min_max.rpt min_max_report min_max_report_end
        parse_to_report $cts_log $REPORT_PATH cts.rpt check_report check_report_end
        parse_to_report $cts_log $REPORT_PATH cts_wns.rpt wns_report wns_report_end
        parse_to_report $cts_log $REPORT_PATH cts_tns.rpt tns_report tns_report_end
        parse_to_report $cts_log $REPORT_PATH cts_clock_skew.rpt clock_skew_report clock_skew_report_end
else
        echo "CTS log not found or empty." > $REPORT_PATH/cts.rpt
fi

REPORT_PATH=${path}/reports/routing/
if [[ $(test_file $routing_log) ]]; then
        parse_to_report $routing_log $REPORT_PATH fastroute.timing.rpt timing_report timing_report_end
        parse_to_report $routing_log $REPORT_PATH fastroute.min_max.rpt min_max_report min_max_report_end
        parse_to_report $routing_log $REPORT_PATH fastroute.rpt check_report check_report_end
        parse_to_report $routing_log $REPORT_PATH fastroute_wns.rpt wns_report wns_report_end
        parse_to_report $routing_log $REPORT_PATH fastroute_tns.rpt tns_report tns_report_end
else
        echo "Routing log not found or empty." > $REPORT_PATH/fastroute.rpt
fi

REPORT_PATH=${path}/reports/placement/
if [[ $(test_file $placement_log) ]]; then
        parse_to_report $placement_log $REPORT_PATH replace.timing.rpt timing_report timing_report_end
        parse_to_report $placement_log $REPORT_PATH replace.min_max.rpt min_max_report min_max_report_end
        parse_to_report $placement_log $REPORT_PATH replace.rpt check_report check_report_end
        parse_to_report $placement_log $REPORT_PATH replace_wns.rpt wns_report wns_report_end
        parse_to_report $placement_log $REPORT_PATH replace_tns.rpt tns_report tns_report_end
else
        echo "Placement log not found or empty." > $REPORT_PATH/replace.rpt
fi

REPORT_PATH=${path}/reports/synthesis/
if [[ $(test_file $sta_log) ]]; then
        parse_to_report $sta_log $REPORT_PATH opensta.timing.rpt timing_report timing_report_end
        parse_to_report $sta_log $REPORT_PATH opensta.min_max.rpt min_max_report min_max_report_end
        parse_to_report $sta_log $REPORT_PATH opensta.rpt check_report check_report_end
        parse_to_report $sta_log $REPORT_PATH opensta_wns.rpt wns_report wns_report_end
        parse_to_report $sta_log $REPORT_PATH opensta_tns.rpt tns_report tns_report_end
        parse_to_report $sta_log $REPORT_PATH opensta.slew.rpt check_slew check_slew_end
else
        echo "Static Timing Analysis log not found or empty." > $REPORT_PATH/opensta.rpt
fi

if [[ $(test_file $sta_post_resizer_log) ]]; then
        parse_to_report $sta_post_resizer_log $REPORT_PATH opensta_post_resizer.timing.rpt timing_report timing_report_end
        parse_to_report $sta_post_resizer_log $REPORT_PATH opensta_post_resizer.min_max.rpt min_max_report min_max_report_end
        parse_to_report $sta_post_resizer_log $REPORT_PATH opensta_post_resizer.rpt check_report check_report_end
        parse_to_report $sta_post_resizer_log $REPORT_PATH opensta_post_resizer_wns.rpt wns_report wns_report_end
        parse_to_report $sta_post_resizer_log $REPORT_PATH opensta_post_resizer_tns.rpt tns_report tns_report_end
        parse_to_report $sta_post_resizer_log $REPORT_PATH opensta_post_resizer.slew.rpt check_slew check_slew_end
else
        echo "Static Timing Analysis Post Resizer log not found or empty." > $REPORT_PATH/opensta_post_resizer.rpt
fi

if [[ $(find $sta_post_resizer_timing_log -type f -size +10c 2> /dev/null) ]]; then
        parse_to_report $sta_post_resizer_timing_log $REPORT_PATH opensta_post_resizer_timing.timing.rpt timing_report timing_report_end
        parse_to_report $sta_post_resizer_timing_log $REPORT_PATH opensta_post_resizer_timing.min_max.rpt min_max_report min_max_report_end
        parse_to_report $sta_post_resizer_timing_log $REPORT_PATH opensta_post_resizer_timing.rpt check_report check_report_end
        parse_to_report $sta_post_resizer_timing_log $REPORT_PATH opensta_post_resizer_timing_wns.rpt wns_report wns_report_end
        parse_to_report $sta_post_resizer_timing_log $REPORT_PATH opensta_post_resizer_timing_tns.rpt tns_report tns_report_end
        parse_to_report $sta_post_resizer_timing_log $REPORT_PATH opensta_post_resizer_timing.slew.rpt check_slew check_slew_end
else
        echo "Static Timing Analysis Post Resizer Timing log not found or empty." > $REPORT_PATH/opensta_post_resizer_timing.rpt
fi

if [[ $(find $sta_post_resizer_routing_timing_log -type f -size +10c 2> /dev/null) ]]; then
	parse_to_report $sta_post_resizer_routing_timing_log $REPORT_PATH opensta_post_resizer_routing_timing.timing.rpt timing_report timing_report_end
	parse_to_report $sta_post_resizer_routing_timing_log $REPORT_PATH opensta_post_resizer_routing_timing.min_max.rpt min_max_report min_max_report_end
	parse_to_report $sta_post_resizer_routing_timing_log $REPORT_PATH opensta_post_resizer_routing_timing.rpt check_report check_report_end
	parse_to_report $sta_post_resizer_routing_timing_log $REPORT_PATH opensta_post_resizer_routing_timing_wns.rpt wns_report wns_report_end
	parse_to_report $sta_post_resizer_routing_timing_log $REPORT_PATH opensta_post_resizer_routing_timing_tns.rpt tns_report tns_report_end
	parse_to_report $sta_post_resizer_routing_timing_log $REPORT_PATH opensta_post_resizer_routing_timing.slew.rpt check_slew check_slew_end
else
	echo "Static Timing Analysis Post Routing Resizer Timing log not found or empty." > $REPORT_PATH/opensta_post_resizer_routing_timing.rpt
fi

if [[ $(test_file $sta_spef_log) ]]; then
        parse_to_report $sta_spef_log $REPORT_PATH opensta_spef.timing.rpt timing_report timing_report_end
        parse_to_report $sta_spef_log $REPORT_PATH opensta_spef.min_max.rpt min_max_report min_max_report_end
        parse_to_report $sta_spef_log $REPORT_PATH opensta_spef.rpt check_report check_report_end
        parse_to_report $sta_spef_log $REPORT_PATH opensta_spef_wns.rpt wns_report wns_report_end
        parse_to_report $sta_spef_log $REPORT_PATH opensta_spef_tns.rpt tns_report tns_report_end
        parse_to_report $sta_spef_log $REPORT_PATH opensta_spef.slew.rpt check_slew check_slew_end
else
        echo "Static Timing Analysis SPEF log not found or empty." > $REPORT_PATH/opensta_spef.rpt
fi

# Extracting info from Yosys
cell_count=$(grep "cells" $yosys_rprt -s | tail -1 | sed -r 's/.*[^0-9]//')
if ! [[ $cell_count ]]; then cell_count="E404"; fi

#Extracting routed_runtime info
if [ -f $routed_runtime_rpt ]; then
        routed_runtime=$(sed 's/.*in //' $routed_runtime_rpt)
        if ! [[ $routed_runtime ]]; then routed_runtime="E404"; fi
else
        routed_runtime="E404";
fi

#Extracting total_runtime info
if [ -f $total_runtime_rpt ]; then
        total_runtime=$(sed 's/.*in //' $total_runtime_rpt)
        if ! [[ $total_runtime ]]; then total_runtime="E404"; fi
        flow_status=$(sed 's/ for .*//' $total_runtime_rpt)
        if ! [[ $flow_status ]]; then
                flow_status="unknown_no_content_in_file";
        else
                flow_status="${flow_status// /_}"
        fi
else
        total_runtime="E404";
        flow_status="unknown_no_total_runtime_file";
fi

#Extracting Die Area info
if [ -f $tritonRoute_def ]; then
        tmpa=$(awk  '/DIEAREA/ {print $3, $4, $7, $8; exit}' $tritonRoute_def | cut -d' ' -f 1)
        tmpb=$(awk  '/DIEAREA/ {print $3, $4, $7, $8; exit}' $tritonRoute_def | cut -d' ' -f 2)
        tmpc=$(awk  '/DIEAREA/ {print $3, $4, $7, $8; exit}' $tritonRoute_def | cut -d' ' -f 3)
        tmpd=$(awk  '/DIEAREA/ {print $3, $4, $7, $8; exit}' $tritonRoute_def | cut -d' ' -f 4)
        diearea=$(( (($tmpc-$tmpa)/1000)*(($tmpd-$tmpb)/1000) ))
        if ! [[ $diearea ]]; then diearea="E404";fi
else
        diearea="E404";
fi

#Place Holder for cell per um
cellperum="E404"
#if ! [[ $cellperum ]]; then cellperum="E404";fi

#Extracting OpenDP Reported Utilization
opendpUtil=$(grep "Util(%):" $replace_log -s | head -1 | sed -E 's/.*Util\(%\): (\S+)/\1/')
if ! [[ $opendpUtil ]]; then opendpUtil="E404"; fi

#Extracting TritonRoute memory usage peak
tritonRoute_memoryPeak=$(grep ", peak = " $tritonRoute_log -s | tail -1 | sed -E 's/.*peak = (\S+).*/\1/')
if ! [[ $tritonRoute_memoryPeak ]]; then tritonRoute_memoryPeak="E404"; fi

#Extracting TritonRoute Violations Information
tritonRoute_violations=$(grep -si "Number of violations" $tritonRoute_log | tail -1 | python3 -c 'import re; print(re.match(r"\[.+?\].*?\=\s*(\d+)", input())[1])')
if ! [[ $tritonRoute_violations ]]; then tritonRoute_violations="E404"; fi
Other_violations=$tritonRoute_violations;

if [ -f $tritonRoute_drc ]; then
        Short_violations=$(grep "Short" $tritonRoute_drc -s | wc -l)
        if ! [[ $Short_violations ]]; then Short_violations="E404"; fi
        Other_violations=$((Other_violations-Short_violations));

        MetSpc_violations=$(grep "MetSpc" $tritonRoute_drc -s | wc -l)
        if ! [[ $MetSpc_violations ]]; then MetSpc_violations="E404"; fi
        Other_violations=$((Other_violations-MetSpc_violations));

        OffGrid_violations=$(grep "OffGrid" $tritonRoute_drc -s | wc -l)
        if ! [[ $OffGrid_violations ]]; then OffGrid_violations="E404"; fi
        Other_violations=$((Other_violations-OffGrid_violations));

        MinHole_violations=$(grep "MinHole" $tritonRoute_drc -s | wc -l)
        if ! [[ $MinHole_violations ]]; then MinHole_violations="E404"; fi
        Other_violations=$((Other_violations-MinHole_violations));
else
        Short_violations="E404";
        MetSpc_violations="E404";
        OffGrid_violations="E404";
        MinHole_violations="E404";
fi

#Extracting Magic Violations from Magic drc
if [ -f $magic_drc ]; then
        Magic_violations=$(grep "^ [0-9]" $magic_drc -s | wc -l)
        if ! [[ $Magic_violations ]]; then Magic_violations="E404"; fi
        if [ $Magic_violations -ne -1 ]; then Magic_violations=$(((Magic_violations+3)/4)); fi
else
        Magic_violations="E404";
fi


#Extracting Klayout DRC Violations from magic.lydrc
if [ -f "$klayout_drc" ]; then
        klayout_violations=$(grep "<item>" $klayout_drc -s | wc -l)
        if ! [[ $klayout_violations ]]; then klayout_violations=0; fi
else
        klayout_violations="E404";
fi

# Extracting Antenna Violations
if [ -f $arc_antenna_report ]; then
        #arc check
        antenna_violations=$(grep "Number of pins violated:" $arc_antenna_report -s | tail -1 | sed -r 's/.*[^0-9]//')
        if ! [[ $antenna_violations ]]; then antenna_violations="E404"; fi
else
        if [ -f $magic_antenna_report ]; then
                #old magic check
                antenna_violations=$(wc $magic_antenna_report -l | cut -d ' ' -f 1)
                if ! [[ $antenna_violations ]]; then antenna_violations="E404"; fi
        else

                antenna_violations="E404";
        fi
fi

#Extracting Other information from TritonRoute Logs
wire_length=$(grep "Total wire length =" $tritonRoute_log -s | tail -1 | sed -r 's/[^0-9]*//g')
if ! [[ $wire_length ]]; then wire_length="E404"; fi
vias=$(grep "Total number of vias =" $tritonRoute_log -s | tail -1 | sed -r 's/[^0-9]*//g')
if ! [[ $vias ]]; then vias="E404"; fi

#Extracting Info from OpenSTA
wns=$(grep "wns" $wns_rpt -s | sed -r 's/wns //')
if ! [[ $wns ]]; then wns="E404"; fi

#Extracting info from OpenSTA post global placement using estimate parasitics
pl_wns=$(grep "wns" $pl_wns_rpt -s | tail -1 |sed -r 's/wns //')
if ! [[ $pl_wns ]]; then pl_wns=$wns; fi

#Extracting Info from OpenSTA
opt_wns=$(grep "wns" $opt_wns_rpt -s | tail -1 |sed -r 's/wns //')
if ! [[ $opt_wns ]]; then opt_wns=$pl_wns; fi

#Extracting info from OpenSTA post global routing using estimate parasitics
fr_wns=$(grep "wns" $fr_wns_rpt -s | sed -r 's/wns //')
if ! [[ $fr_wns ]]; then fr_wns=$opt_wns; fi

#Extracting info from OpenSTA post SPEF extraction
spef_wns=$(grep "wns" $spef_wns_rpt -s | sed -r 's/wns //')
if ! [[ $spef_wns ]]; then spef_wns=$fr_wns; fi

#Extracting Info from OpenSTA
tns=$(grep "tns" $tns_rpt -s | sed -r 's/tns //')
if ! [[ $tns ]]; then tns="E404"; fi

#Extracting info from OpenSTA post global placement using estimate parasitics
pl_tns=$(grep "tns" $pl_tns_rpt -s | tail -1 |sed -r 's/tns //')
if ! [[ $pl_tns ]]; then pl_tns=$tns; fi

#Extracting Info from OpenSTA
opt_tns=$(grep "tns" $opt_tns_rpt -s | tail -1 |sed -r 's/tns //')
if ! [[ $opt_tns ]]; then opt_tns=$pl_tns; fi

#Extracting info from FR:estimate_parasitics
fr_tns=$(grep "tns" $fr_tns_rpt -s | sed -r 's/tns //')
if ! [[ $fr_tns ]]; then fr_tns=$opt_tns; fi

#Extracting info from OpenSTA post SPEF extraction
spef_tns=$(grep "tns" $spef_tns_rpt -s | sed -r 's/tns //')
if ! [[ $spef_tns ]]; then spef_tns=$opt_tns; fi


#Extracting Info from RePlace
#standalone replace extraction
#hpwl=$(cat $HPWL_rpt)

#openroad replace extraction
hpwl=$(grep " HPWL: " $HPWL_rpt -s | tail -1 | sed -E 's/.*HPWL: (\S+).*/\1/')
if ! [[ $hpwl ]]; then hpwl="E404"; fi

#Extracting Info from Yosys logs
declare -a metrics=(
        "Number of wires:"
        "Number of wire bits:"
        "Number of public wires:"
        "Number of public wire bits:"
        "Number of memories:"
        "Number of memory bits:"
        "Number of processes:"
        "Number of cells:"
        "\$_AND_"
        "\$_DFF_"
        "\$_NAND_"
        "\$_NOR_"
        "\$_OR"
        "\$_XOR"
        "\$_XNOR"
        "\$_MUX"
)

metrics_vals=()
for metric in "${metrics[@]}"; do
        val=$(grep " \+${metric}[^0-9]\+ \+[0-9]\+" $yosys_log -s | tail -1 | sed -r 's/.*[^0-9]([0-9]+)$/\1/')
        if ! [[ $val ]]; then val=0; fi
        metrics_vals+=("$val")
done

#Extracting info from yosys logs
input_output=$(grep -e "ABC: netlist" $yosys_log -s | tail -1 | sed -r 's/ABC: netlist[^0-9]*([0-9]+)\/ *([0-9]+).*/\1 \2/')
if ! [[ $input_output ]]; then input_output="-1 -1"; fi
level=$(grep -e "ABC: netlist" $yosys_log -s | tail -1 | sed -r 's/.*lev.*[^0-9]([0-9]+)$/\1/')
if ! [[ $level ]]; then level="E404"; fi

#Extracting layer usage percentage
usageLine=$(grep -n -E "Layer\s+Resource" $fr_log | tail -1 | sed -E 's/(\S+):.*/\1/')

layer1=$(sed -n "$(expr $usageLine + 2)p" $fr_log | sed -E 's/.*\s+(\S+)%.*/\1/')
if ! [[ $layer1 ]]; then layer1="E404"; fi
layer2=$(sed -n "$(expr $usageLine + 3)p" $fr_log | sed -E 's/.*\s+(\S+)%.*/\1/')
if ! [[ $layer2 ]]; then layer2="E404"; fi
layer3=$(sed -n "$(expr $usageLine + 4)p" $fr_log | sed -E 's/.*\s+(\S+)%.*/\1/')
if ! [[ $layer3 ]]; then layer3="E404"; fi
layer4=$(sed -n "$(expr $usageLine + 5)p" $fr_log | sed -E 's/.*\s+(\S+)%.*/\1/')
if ! [[ $layer4 ]]; then layer4="E404"; fi
layer5=$(sed -n "$(expr $usageLine + 6)p" $fr_log | sed -E 's/.*\s+(\S+)%.*/\1/')
if ! [[ $layer5 ]]; then layer5="E404"; fi
layer6=$(sed -n "$(expr $usageLine + 7)p" $fr_log | sed -E 's/.*\s+(\S+)%.*/\1/')
if ! [[ $layer6 ]]; then layer6="E404"; fi

#Extracting Endcaps and TapCells
endcaps=$(grep "Endcaps inserted:" $tapcell_log -s | tail -1 | sed -E 's/.*Endcaps inserted: (\S+)/\1/')
if ! [[ $endcaps ]]; then endcaps=0; fi

tapcells=$(grep "Tapcells inserted:" $tapcell_log -s | tail -1 | sed -E 's/.*Tapcells inserted: (\S+)/\1/')
if ! [[ $tapcells ]]; then tapcells=0; fi


#Extracting Diodes
diodes=$(grep "inserted!" $diodes_log -s | tail -1 | sed -E 's/.* (\S+) of .* inserted!/\1/')
if ! [[ $diodes ]]; then
        diodes=$(grep "diodes inserted" $fr_log -s | tail -1 | sed -E 's/.* (\S+) diodes inserted./\1/')
        if ! [[ $diodes ]]; then diodes=0; fi
fi

#Summing the number of Endcaps, Tapcells, and Diodes
physical_cells=$(((endcaps+tapcells)+diodes));

#Extracting the total number of lvs errors
if ! [[ -f "$lvs_report" ]]; then
        lvs_total_errors=$(grep "Total errors =" $lvs_report -s | tail -1 | sed -r 's/[^0-9]*//g')
        if ! [[ $lvs_total_errors ]]; then lvs_total_errors=0; fi
else
        lvs_total_errors="E404";
fi


#Extracting the total number of cvc errors
cvc_total_errors=$(grep "CVC: Total: " $cvc_log -s | tail -1 | sed -r 's/[^0-9]*//g')
if ! [[ $cvc_total_errors ]]; then cvc_total_errors="E404"; fi

result="$flow_status $total_runtime $routed_runtime $diearea $cellperum $opendpUtil $tritonRoute_memoryPeak $cell_count $tritonRoute_violations $Short_violations $MetSpc_violations $OffGrid_violations $MinHole_violations $Other_violations $Magic_violations $antenna_violations $lvs_total_errors $cvc_total_errors $klayout_violations $wire_length $vias $wns $pl_wns $opt_wns $fr_wns $spef_wns $tns $pl_tns $opt_tns $fr_tns $spef_tns $hpwl $layer1 $layer2 $layer3 $layer4 $layer5 $layer6"
for val in "${metrics_vals[@]}"; do
        result+=" $val"
done
result+=" $input_output"
result+=" $level"
result+=" $endcaps $tapcells $diodes $physical_cells"
echo "$result"
