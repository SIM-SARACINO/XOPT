#!/bin/bash
#set -n -v # test the script !

## Overview : 'Plot4' is a robust and powerful toolkit
# for visualization and data processing. 
# Plot4 it's a spin-off package of the optimization 
# code 'XOPT'.
# See the main documentation.

## BUG : xfoil generate a sequence of data that we use
#  to plot the aerodinamic coefficients chats.
# Sometimes any point (α values) of the polar 
# could not be transcripted in '.pol' file data, so
# the polar may lack in accuracy.
# If the 'α-Obj' (the point leading the optimization 
# process <see XOPT documentation>) were absent you will
# be advised by a warning.
# In this case we got the solution by setting one of the 
# outer value of the α range just equal to α-Obj.
# Next release will deal automatically with the problem.

## Input-argument evaluation
############################

narg="$#"
cod="$1" # cod is the short string that define every 
# airfoil configuration generated by XOPT.
# 'g<generation index>k<configuration index>'

# ex.: 'g0k1' -> generation '0', configuration '1'
# plot4 look for 'g0k1.xy' (coordinates data file)
# and 'g0k1.cp' (cp-coeff. distribution data file)
# in ~/../XOPT/GEN/0/1/

## Notes
# If decimal numbers are required use the exponential 
# notation.
# for ex.: 2°.5' -> 25e-1 or 25E-1 

# Provide angles in degree (°)

# Make sure that the file data are not corrupted or 
# incomplete (ex. NaN element). Comment-line inside the
# structure of the coordinate data file are not checked ! 
# Although Plot4 recognize only the first line header, it's 
# suitable for most of the data format in worlwide databases.
# Check out the DATABASE in the workspace (~/XOPT/DATABASE).

Re="$2" # Reynolds number
Mach="$3" # Mach number
alfaObj="$4" # alpha of project
alfa0="$5" # first angle of the polar (°) 
alfa1="$6" # last angle ""
delta="$7" # delta alpha
pan="$8" # number of panel nodes
codX0="$9" # ex. if 'naca4415.dat' were my
# firts base configuration ( located in any folder
# in the workspace ), then i get 'naca4415'

# CONFIGURATION
#################################################

foldGen="GEN" # data forder create by XOPT during 
	      # optimization process
	
fileOut="multiplot.pdf" # set a name for output plot file
			# it can be also .eps, .ps , ...
			# see the terminal section in gnuplot
			# gnuplot> help set terminal
## terminal
###########

term="pdf" # default terminal is "pdfcairo"
# it's one of the best among other.
# However "tikz","eps","ps" terminal work very well and are simple 
# to import in your latex reports.

opt="enhanced color size 5.0,4.0" # 'enhanced' give useful features
# for typing label, key, title,etc..; the size is set to 5inch x 3.5inch
# see gnuplot documentation for terminal option available.
 
## Font 
#font="" # uncomment and set font face and font size 
         # ex : font "<face>,<size>" 

#fontscale=""

## Diagrams setting map
########################################

# Cl-Cd diagram

xminLD=""
xmaxLD="" # empty for default value
xlbLD="Cd" # either Cl or Cd, set xflag 
xflagLD="3" # '2' for Cl on x axes ,
	    # '3' for Cd ""
# Oss: '2' is the column of Cl values in the 
# polar file generated by Xfoil. 
# { Xfoil is the core
# 'engine' provided within XOPT code for aerodynamic
# analisys. 
# Read XOPT doc and xfoil manual for more detailed info}  

yminLD=""
ymaxLD="" #empty for default value
ylbLD="Cl" 
yflagLD="2" # depend on xflag  
 
# Cl-α diagram

xminL="" 
xmaxL=$((${alfa1}+1))
xlbL="α" # latex terminal $\alpha$
xflagL="1"

yminL=""
ymaxL=""
ylbL="Cl" # Cd,Cm
yflagL="2" # '3' -> Cd

# Cm-α diagram

xminM=""
xmaxM="$((${alfa1}+1))"
xlbM="α"
xflagM="1"

yminM="-0.25"
ymaxM=""
ylbM="Cm"
yflagM="5"

# reverse yrange of Cm-alpha diagram
yCmrev="reverse" # or noreverse

# Cp-ψ diagram 
#(ψ is the normalized chord-station : x/chord)

xminP="-0.05"
xmaxP="1.05"
xlbP="ψ"

yminP="-1.4"
ymaxP=""
ylbP="Cp"

# reverse yrange of Cp-α diagram
yCprev="reverse" # or noreverse

## multiplot scale (wide,hight)
###############################
wiMul="1.1"
hiMul="1.0"

## label/tics/title font
########################

# x|ylabel font ("face,size")
fxlb=",10" 
fylb=",10"

# x|ytics font
fxt=",8"
fyt=",8"

# title font 
ft=",11"

# key boxe font
fK="7"
fKCp="7" # 'ad-hoc' font for Cp-chart key box

## x|ytics range
################

xtLD=""
ytLD="0.2"

xtL="2"
ytL="0.2"

xtM="2"
ytM="0.02"

xtP="0.2"
ytP=""

## x|ytics mirror
#################
xtMir="nomirror"
ytMir="nomirror"

## xfoil option
###############
# mod 
mod="VISC" # Viscous or Inviscid analisys

# iter -> maximum iteration number 
iter="50"

## α-Obj label options
######################

# label coordinates
xlbAlfa="0.8"
ylbAlfa="-1.2"

# font size
falfaLb="7"

## colour
#########

# rgb code for color selection 
greyGrid="\"#B2B2B2\"" # 30% grey
carb="\"#050402\""
red="\"#bd2129\"" 
blue="\"#6d78ab\""
darkpesc="\"#FF421E\""

## mark α-Obj colours
CmarkX="\"#4B0082\""
CmarkX0="\"#960018\""

## miscellaneous colours
#pesc="\"#FF8141\""
#avocado="\"#E0E074\""
#giada="\"#3F621F\""
#pist="\"#93C572\""
#bro="\"#75663F\""
#AspGrey="\"#2F4F4F\""
#leef="\"#82FFCA\""

# width of the lines in Cp-x/c diagram
wlineP="4"
wline0P="0.5"
 
## line options Cl-Cd, Cl-alpha, Cm- alpha
########################################## 
# diagrams (X)
lLD="w l lc rgb ${darkpesc}"
lL="w l lc rgb ${darkpesc}"
lM="w l lc rgb ${darkpesc}"

# line options Cl-Cd, Cl-alpha, Cm- alpha 
# diagrams (X0)
l0LD="w l lc rgb ${carb}"
l0L="w l lt 7 lc rgb ${carb}"
l0M="w l lt 7 lc rgb ${carb}"

# line options Cp-x/c diagram (X)
lP_u="w l lc rgb ${red} lw ${wlineP}"
lP_l="w l lc rgb ${blue} lw ${wlineP}"

# line options Cp-x/c diagram (X0)
l0P_u="w l lc rgb ${red} lw ${wline0P}"
l0P_l="w l lc rgb ${blue} lw ${wline0P}"

## label options
################
 
# labels position -> offset
xlbOf="0.0,0.0" # x,y offset x-axis label
ylbOf="2.0,0.0" # "" y-axis label

# rotation of ylabels
rot="norotate" # or rotate by <angle°>

# spacing of the label in the key boxe
spK="0.5"
spKCp="0.5" # ad-hoc spacing for Cp-chart key box

## mark α-Obj options
#####################

# mark α-Obj point size 
psX="0.5"
psX0="0.5"

# mark α-Obj point type
ptX="10"
ptX0="10"

# mark α-Obj option style
markX="w lp pt ${ptX} ps ${psX} lc rgb ${CmarkX}"
markX0="w lp pt ${ptX0} ps ${psX0} lc rgb ${CmarkX0}"

## key options
##############

# vertical / horizontal key box
#vhK_M="vertical maxrows 2"  # or "horizontal maxcols <max n.ro of columns>"

# height of the key boxe
hK="0.5"
hKCp="0.5" # ad-hoc height for Cp-chart key box

# samplen 
sampl="1"

# key boxe position, height, spacing, samplen
keyLD="bottom right font \",${fK}\" height ${hK} spacing ${spK}"
keyL="bottom right font \",${fK}\" height ${hK} spacing ${spK}"
keyM="top right vertical maxcols 2 font \",${fK}\" height ${hK} spacing ${spK}"
keyP="bottom center font \",${fKCp}\" height ${hKCp} spacing ${spKCp}" 

# width of the key 
width="-3"
widthCp="-5" # ad-hoc width for Cp-chart key box

## border option
border="3" # x-y underlined 
widBord="1"

## sample specification
sampl="1000"

## sleep variable
sl="3s" # time waiting for xfoil routine 
# to process data
 
#################################################


len=$(expr length "$cod")
i_k=$(expr index "$cod" k)

len_gen=$(( $i_k-2 ))
len_k=$(( $len-$i_k ))

gen=$(echo ${cod:1:$len_gen})

k=$(echo ${cod:$i_k:$len_k})

x=`find -type f -name "${cod}.xy"`
hx=`head -n 1 "$x" | tail -1`

xCp=`find -name "${cod}.cp"`

var=$(echo ${hx:0:0})
i=0

while [ -z ${var} ] || [ ! ${var} -eq ${var} 2>/dev/null ];do

	i=$(($i+1))
	var=$(echo ${hx:0:i})

	if [ -z ${var} ];then
		continue
	elif [ $var -eq $var 2>/dev/null ];then
		break
	else
		sed -i '1d' ${x}
		break
	fi
done

if [ "${narg}" -eq  8 ];then
	
	exec 6>&1
	exec > ${cod}.run 

	echo "PLOP"
	echo "G F"
	echo ""
	echo "LOAD"
	echo "./${foldGen}/${gen}/${k}/${cod}.xy"
	echo "${cod}"
	echo "OPER"
	echo "${mod}"
	echo "${Re}"
	echo "MACH"
	echo "${Mach}"
	echo "ITER"
	echo "${iter}"
	echo "CPMI"
	echo "${cpmin}"
	echo "PACC"
	echo "${cod}.pol"
	echo ""
	echo "ASEQ ${alfa0} ${alfa1} ${delta}"
	echo "PACC"
	echo ""
	echo "QUIT"
		
	exec 1>&6
	exec 6<&-

	xfoil < ${cod}.run >> log 
	sleep ${sl}

	gnuplot <<- EOF
#Common options
	set term ${term} ${opt}
	set output "${fileOut}"
	set sample ${sampl}
	set grid lc rgb ${greyGrid}
	set border ${border} lw ${widBord}
	#unset key
	#set size ratio -1

	set multiplot layout 2,2 columnsfirst scale ${wiMul},${hiMul} title '${cod} ,\
	α ϵ [${alfa0}°,${alfa1}°] , α-Obj = ${alfaObj}° , Re_c = ${2} , Mach = ${3}\\ 
	T = ${} , p = ${} atm standard ' 
#Cl-Cd	
	#set title "Cl-Cd ${cod}" font "${ft}"
	#set format y "%.2e"
	set xlabel '${xlbLD}' font "${fxlb}" offset ${xlbOf}
	set ylabel '${ylbLD}' font "${fylb}" ${rot} offset ${ylbOf}
	set xrange [${xminLD}:${xmaxLD}] 
	set yrange [${yminLD}:${ymaxLD}]
	#set key box ${keyLD} opaque width ${width}
	set xtics ${xtLD} ${xtMir} font "${fxt}"
	set ytics ${ytLD} ${ytMir} font "${fyt}"
	pl '${cod}.pol' u ${xflagLD}:${yflagLD} ${lLD} notitle
#Cm-alpha	
	#set title "Cm-alpha ${cod}" font "${ft}"
	set format y "%g"
	set xlabel '${xlbM}' font "${fxl}" offset ${xlbOf}
	set ylabel '${ylbM}' font "${fylb}" ${rot} offset ${ylbOf}
	set xrange [${xminM}:${xmaxM}]
	set yrange [${yminM}:${ymaxM}] ${yCmrev}
	#set key box ${keyM} opaque width ${width}
	set xtics ${xtM} ${xtMir} font "${fxt}"
	set ytics ${ytM} ${ytMir} font "${fyt}"
	pl '${cod}.pol' u ${xflagM}:${yflagM} ${lM} notitle
#Cl-alpha
	#set title "Cl-alpha ${cod}" font "${ft}"
	set xlabel '${xlbL}' font "${fxlb}" offset ${xlbOf}
	set ylabel '${ylbL}' font "${fylb}" ${rot} offset ${ylbOf}
	set xrange [${xminL}:${xmaxL}]
	set yrange [${yminL}:${ymaxL}] noreverse
	#set key box ${keyL} opaque width ${width}
	set xtics ${xtL} ${xtMir} font "${fxt}"
	set ytics ${ytL} ${ytMir} font "${fyt}"
	pl '${cod}.pol' u ${xflagL}:${yflagL} ${lL} notitle
#Cp-x/c	
	#set title "Cp-x/c ${cod} alpha ${alfaObj}°" font "${ft}"
	set xlabel '${xlbP}' font "${fxlb}" offset ${xlbOf}
	set ylabel '${ylbP}' font "${fylb}" ${rot} offset ${ylbOf}
	set xrange [${xminP}:${xmaxP}]
	set yrange [${yminP}:${ymaxP}] reverse
	set key box ${keyP} opaque width ${width} 
	set xtics ${xtP} ${xtMir} font "${fxt}"
	set ytics ${ytP} ${ytMir} font "${fyt}"
	set label "α = ${alfaObj}°" at $xlbAlfa,$ylbAlfa font ",9" 
	pl './${foldGen}/${gen}/${k}/${cod}.cp' every ::1::${pan}/2 ${lP_u} t 'up', \
	'' every ::${pan}/2::${pan} ${lP_l} t 'lo'

	unset multiplot

	set output
	set terminal pop
	EOF

elif [ "${narg}" -eq 9 ];then
	
	x0=`find -type f -name "${codX0}*"`
	h0=`head -n 1 ${x0}* | tail -1`

	var1=$(echo ${h0:0:0})
	j=0

	while [ -z ${var1} ] || [ ! ${var1} -eq ${var1} 2>/dev/null ];do

		j=$(($j+1))
		var1=$(echo ${h0:0:j})

		if [ -z ${var1} ];then
			continue
		elif [ $var1 -eq $var1 2>/dev/null ];then
			break
		else
			sed -i '1d' ${x0}
			break
		fi
	done

	exec 6>&1
	exec > test.run 

	echo "PLOP"
	echo "G F"
	echo ""
	echo "LOAD"
#	echo "./${foldGen}/${gen}/${k}/${cod}.xy"
	echo "$x"
	echo "${cod}"
	echo "OPER"
	echo "${mod}"
	echo "${Re}"
	echo "MACH"
	echo "${Mach}"
	echo "ITER"
	echo "${iter}"
	echo "CPMI"
	echo "${cpmin}"
	echo "PACC"
	echo "${cod}.pol"
	echo ""
	echo "ASEQ ${alfa0} ${alfa1} ${delta}"
	echo "PACC"
	echo ""
	echo "LOAD"
	echo "${x0}"
	echo "${codX0}"
	echo "PANE"
	echo "OPER"
	echo "INIT"
	echo "PACC"
	echo "${codX0}.pol"
	echo ""
	echo "ASEQ ${alfa0} ${alfa1} ${delta}"
	echo "PACC"
	echo "ALFA"
	echo "${alfaObj}"
	echo "CPWR"
	echo "${codX0}.cp"
	echo ""
	echo "QUIT"
		
	exec 1>&6
	exec 6<&-

	xfoil < test.run >> log 
	sleep ${sl}

	gnuplot <<- EOF
#Common options
	set term ${term} ${opt}
	set output "${fileOut}"
	set sample ${sampl}
	set grid lc rgb ${greyGrid}
	set border ${border} lw ${widBord}
	#unset key
	#set size ratio -1
	
	set multiplot layout 2,2 columnsfirst scale ${wiMul},${hiMul} title '${cod}-${codX0} ,\
α ϵ [${alfa0}°,${alfa1}°] , α-Obj = ${alfaObj}° , Re_c = ${2} , Mach = ${3}'
#Cl-Cd	
	#set title "Cl-Cd ${cod}" font "${ft}"
	#set format y "%.2e"
	set xlabel '${xlbLD}' font "${fxlb}" offset ${xlbOf}
	set ylabel '${ylbLD}' font "${fylb}" ${rot} offset ${ylbOf}
	set xrange [${xminLD}:${xmaxLD}] 
	set yrange [${yminLD}:${ymaxLD}]
	set key box ${keyLD} opaque width ${width}
	set xtics ${xtLD} ${xtMir} font "${fxt}"
	set ytics ${ytLD} ${ytMir} font "${fyt}"
	pl '${cod}.pol' u ${xflagLD}:${yflagLD} ${lLD} t '${cod}' ,\
	'' u (column(1) == ${alfaObj} ? column(${xflagLD}) : 1/0):(column(${yflagLD})) ${markX} notitle ,\
	'${codX0}.pol' u ${xflagLD}:${yflagLD} ${l0LD} t '${codX0}' ,\
	'' u (column(1) == ${alfaObj} ? column(${xflagLD}) : 1/0):(column(${yflagLD})) ${markX0} notitle 
#Cm-alpha	
	#set title "Cm-α ${cod}" font "${ft}"
	#set format y "%g"
	set xlabel '${xlbM}' font "${fxl}" offset ${xlbOf}
	set ylabel '${ylbM}' font "${fylb}" ${rot} offset ${ylbOf}
	set xrange [${xminM}:${xmaxM}]
	set yrange [${yminM}:${ymaxM}] ${yCmrev}
	set key box ${keyM} opaque width ${width}
	set xtics ${xtM} ${xtMir} font "${fxt}"
	set ytics ${ytM} ${ytMir} font "${fyt}"
	pl '${cod}.pol' u ${xflagM}:${yflagM} ${lM} t '${cod}',\
	'' u (column(1) == ${alfaObj} ? column(1) : 1/0):(column(5)) ${markX} notitle ,\
	'${codX0}.pol' u ${xflagM}:${yflagM} ${l0M} t '${codX0}' ,\
	'' u (column(1) == ${alfaObj} ? column(1) : 1/0):(column(5)) ${markX0} notitle
#Cl-alpha
	#set title "Cl-α ${cod}" font "${ft}"
	set xlabel '${xlbL}' font "${fxlb}" offset ${xlbOf}
	set ylabel '${ylbL}' font "${fylb}" ${rot} offset ${ylbOf}
	set xrange [${xminL}:${xmaxL}]
	set yrange [${yminL}:${ymaxL}] noreverse
	set key box ${keyL} opaque width ${width}
	set xtics ${xtL} ${xtMir} font "${fxt}"
	set ytics ${ytL} ${ytMir} font "${fyt}"
	pl '${cod}.pol' u ${xflagL}:${yflagL} ${lL} t '${cod}',\
	'' u (${xflagL}) : ((column(${xflagL}) == ${alfaObj}) ? column(${yflagL}) : 1/0) ${markX} notitle ,\
	'${codX0}.pol' u ${xflagL}:${yflagL} ${l0L} t '${codX0}' ,\
	'' u (${xflagL}) : ((column(${xflagL}) == ${alfaObj}) ? column(${yflagL}) : 1/0) ${markX0} notitle
#Cp-x/c	
	#set title "Cp-ψ ${cod} alpha ${alfaObj}°" font "${ft}"
	set xlabel '${xlbP}' font "${fxlb}" offset ${xlbOf}
	set ylabel '${ylbP}' font "${fylb}" ${rot} offset ${ylbOf}
	set xrange [${xminP}:${xmaxP}]
	set yrange [${yminP}:${ymaxP}] ${yCprev}
	set key box ${keyP} opaque width ${widthCp} 
	set xtics ${xtP} ${xtMir} font "${fxt}"
	set ytics ${ytP} ${ytMir} font "${fyt}"
	set label "α-Obj = ${alfaObj}°" at $xlbAlfa,$ylbAlfa font ",${falfaLb}" 
	pl '$xCp' every ::1::${pan}/2 ${lP_u} t 'up-${cod}' ,\
	'' every ::${pan}/2::${pan} ${lP_l} t 'lo-${cod}' ,\
	'${codX0}.cp' every ::1::${pan}/2 ${l0P_u} t 'up-${codX0}' ,\
	'' every ::${pan}/2::${pan} ${l0P_l} t 'lo-${codX0}' 

	unset multiplot

	set output
	set terminal pop
	EOF
		
else
	echo ""
	echo "WARNING: INVALID PARAMETER NUMBER OR INVALID VALUE"
	echo "Call-command example:"
	echo "./plot.sh cod Re Mach alfaObj alfa0 alfa1 delta pan ," 
	echo "./plot.sh cod Re Mach alfaObj alfa0 alfa1 delta pan codX0 ,"
	echo "See the configuration map in plot4.sh" 
	echo ""

fi

rm -f log test.run
evince ${fileOut} 2> /dev/null & # set the viewer for the output file format extention


