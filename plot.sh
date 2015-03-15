#!/bin/bash
#set -n -v

narg="$#"
gen="$1"
k="$2"
miny="$3"
maxy="$4"
panel="$5"
genOpt="$6"
kOpt="$7"

#conf. gnuplot :
# xrange
	x_min="-0.05"
	x_max="1.05"
# yrange (coordinates)
	y_min="-1.0"
	y_max="1.0"
# width key box
	width="2"
# width lines
	wline="4"

x0=`find -name "g${gen}k${k}.xy"`
hx0=`head -n 1 "$x0" | tail -1`

Cp=`find -name "g${gen}k${k}.cp"`
#h0=`head -n 1 ${Cp} | tail -1`
#n0=${#h0}

#if [ ${hx0} = g${gen}k$k -a ${n0} = 22 ];then
if [ "${hx0}" = "g${gen}k$k" ];then
	sed -i '1d' ${x0}
#	sed -i '1d' ${Cp}
fi

if [ "${narg}" -eq  5 ];then
	
	gnuplot <<- EOF
	set terminal pdf
	set output "Cp_g${gen}k${k}.pdf"
	set sample 1000
	set title "Cp distribution g${gen}k$k"
	set xlabel 'x/c'
	set ylabel 'y/c'
	set y2label 'Cp'
	set ytics nomirror
	set y2tics nomirror
	set xrange [${x_min}:${x_max}]
	set x2range [${x_min}:${x_max}]
	set yrange [${y_min}:${y_max}]
	set y2range [$3:$4] reverse
	set key box top right opaque width ${width}
	set grid
	#set size ratio -1 
	pl '$x0' w l lt 7 t "g${gen}k$k" axes x1y1,\
'$Cp' every ::1::$5/2 w l lt 1 t "Cp_g${gen}k${k}_u" axes x1y2,''\
 every ::$5/2::$5 w l lt 3 t "Cp_g${gen}k${k}_u" axes x1y2
	set output
	EOF

elif [ "${narg}" -eq 7 ];then
	
	xOpt=`find -name "g${genOpt}k${kOpt}.xy"`
	hOpt=`head -n 1 ${xOpt} | tail -1`

	CpOpt=`find -name g${genOpt}k${kOpt}.cp`
#	hCpOpt=`head -n 1 ${CpOpt} | tail -1` % comment are readable !
#	nCpOpt=${#hCpOpt}
 
#	if [ ${hOpt} = g${genOpt}k${kOpt} -a ${nCpOpt} = 22 ];then
	if [ "${hOpt}" = "g${genOpt}k${kOpt}" ];then
		sed -i '1d' ${xOpt}
#		sed -i '1d' ${CpOpt}
	fi

	gnuplot <<- EOF
	set terminal pdf
	set output "Cp_g${gen}k${k}_Opt.pdf"
	set sample 1000
	set title "Cp distribution g${gen}k$k g${genOpt}k${kOpt}"
	set xlabel 'x/c'
	set ylabel 'y/c'
	set y2label 'Cp'
	set ytics nomirror
	set y2tics nomirror
	set xrange [${x_min}:${x_max}]
	set x2range [${x_min}:${x_max}]
	set yrange [${y_min}:${y_max}]
	set y2range [$3:$4] reverse
	set key box top right opaque width ${width} 
	set grid
	pl '$x0' w l lt 7 t "g${gen}k$k" axes x1y1,\
'$xOpt' w l lt 7 lw ${wline} t "g${genOpt}k${kOpt}" axes x1y1,\
'$Cp' every ::1::$5/2 w l lt 1 t "Cp_g${gen}k${k}_u" axes x1y2,\
'' every ::$5/2::$5 w l lt 3 t "Cp_g${gen}k${k}_l" axes x1y2,\
'$CpOpt' every ::1::$5/2 w l lt 1 lw ${wline} t 'Cp_g${genOpt}k${kOpt}_u' axes x1y2,\
'' every ::$5/2::$5 w l lt 3 lw ${wline} t "Cp_g${genOpt}k${kOpt}_l" axes x1y2
	set output
	EOF

else
	echo ""
	echo "WARNING: INVALID PARAMETER NUMBER OR INVALID VALUE"
	echo "Call-command example:"
	echo "./plot.sh PlotOption Gen0 k0 cpmax cpmin GenOpt kOpt"
	echo "PlotOption = 1 (to write plot in .pdf) or 0"
	echo "Gen0,GenOpt = number of generations of 'battle' s"
	echo "k,kOpt = id numbers"
	echo "cpmin,cpmax = define min and max of y-label"
	echo "Five parameters are necessary to plot a  distribution;"
	echo "Seven parameters must be given to make a 'battle'"
	echo "SEE plot.sh"
	echo ""
fi
