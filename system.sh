#!/bin/bash

#set -n -v

main="xopt"
sourceDir="SOURCE"
fileObj="fobj"
fileConfGen="genetic"
data=`find ./ -maxdepth 1 -type d -name "GEN"`
tesT=`find ./ -maxdepth 1 -type d -name "TEST"`
fileGen=$(find ./ -maxdepth 1 -type f -name "*.gen")
arch=$(find ./ -maxdepth 1 -type f -name "*.xy")

if [ ! -z ${arch} ] && [ -z ${fileGen} ];then
	cod=$(basename -s .xy ${arch})
	len=$(expr length "$cod")
	i_k=$(expr index "$cod" k)
	len_gen=$(( $i_k-2 ))
	len_k=$(( $len-$i_k ))
	gen=$(echo ${cod:1:$len_gen})
	k=$(echo ${cod:$i_k:$len_k})

elif [ -z ${arch} ] && [ ! -z ${fileGen} ];then
	gen=$(basename -s .gen ${fileGen})

elif [ ! -z ${arch} ] && [ ! -z ${fileGen} ];then
	cod=$(basename -s .xy ${arch})
	len=$(expr length "$cod")
	i_k=$(expr index "$cod" k)
	len_gen=$(( $i_k-2 ))
	len_k=$(( $len-$i_k ))
	gen=$(echo ${cod:1:$len_gen})
	k=$(echo ${cod:$i_k:$len_k})

fi

case $1 in
"move" | "mv")
	mv ./${cod}* ${data}/${gen}/${k}/
	;;
"mvGen" | "mvG")
	mv ${fileGen} ${data}/${gen}/ #2>/dev/null
#	ngen=$(ls *.gen | wc -l)
#	for k in `seq 1 ${ngen}`;do
#		temp=$(( ${k}-1 ))
#		mv ${temp}.gen *.out ${data}/${temp}/
#	done
	;;
"clean" | "c")
	for ext in ".run" ".log" ".pol";do 
		rm -f -r $(find ${data}/ -type f -name "*${ext}")
#		rm -f -r $(find ${data}/ -type f -name "*${ext}")
	done
	;;
"distclean" | "dc")
	rm -f -r ${data} *.out
#	rm -f -i -r ${data}	
	;;
"zip" | "z")
	if [ -z ${tesT} ];then
		tesT="TEST"
		mkdir ${tesT}		
	fi
	
#	cp ${main}.m ${data}/${main}$2.m 
	tar cvfz $2.tar.gz `basename ${data}` ${main}.m ${sourceDir}/${fileObj}.m ${sourceDir}/${fileConfGen}.m *.out *.pdf 2> /dev/null 
	mv $2.tar.gz ${tesT}/
	;;
*)
	exit 1
esac
