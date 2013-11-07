#!/bin/bash
#********************************#
#**   Deka Thumb Generator     **#
#********************************#
#** Share under GPLv2    ********#
#** Dincer Kavraal         ******#
#** dkavraal@gmail.com        ***#
#********************************#
STHUMBROOT=thumbs
BTHUMBROOT=thumbbig
TMP=/tmp
WEBROOT="http://127.0.0.1"
TMP_HTML_THUMBS=${TMP}/thumbs.txt
HTML_KEY_NAME=my
HTML_MAIN=show/
HTML_TEMP_UP=queries/lasthtml/my_up.html
HTML_TEMP_DOWN=queries/lasthtml/my_dn.html


##########################################################################
##### Keep edits above, below is the source not to be changed so much ####
##########################################################################
lib_progress_bar() {
	local current=0
	local max=100
	local completed_char="#"
	local uncompleted_char="."
	local decimal=1
	local prefix=" ["
	local suffix="]"
	local percent_sign="%"
	local max_width=$(tput cols)
 
	local complete remain subtraction width atleast percent chars
	local padding=3
 
	local OPTIND
 
	while getopts c:u:d:p:s:%:m:hV flag; do
		case "$flag" in
			c) completed_char="$OPTARG";;
			u) uncompleted_char="$OPTARG";;
			d) decimal="$OPTARG";;
			p) prefix="$OPTARG";;
			s) suffix="$OPTARG";;
			%) percent_sign="$OPTARG";;
			m) max_width="$OPTARG";;
 
			(h) lib_help;;
			(V) echo "$lib_script_name: version $Revision$ ($Date$)"; exit 0;;
			(*) lib_usage;;
		esac
	done
	shift $((OPTIND-1))
 
	current=${1:-$current}
	max=${2:-$max} 
 
	if (( decimal > 0 )); then
		(( padding = padding + decimal + 1 ))
	fi
 
	let subtraction=${#completed_char}+${#prefix}+${#suffix}+padding+${#percent_sign}
	let width=max_width-subtraction
 
	if (( width < 5 )); then
		(( atleast = 5 + subtraction ))
		echo >&2 "the max_width of ($max_width) is too small, must be atleast $atleast"
		return 1
	fi
 
    if (( current > max ));then
        echo >&2 "current value must be smaller than max. value"
        return 1
    fi
 
    percent=$(awk -v "f=%${padding}.${decimal}f" -v "c=$current" -v "m=$max" 'BEGIN{printf('f', c / m * 100)}')
 
    (( chars = current * width / max))
 
    # sprintf n zeros into the var named as the arg to -v
    printf -v complete '%0*.*d' '' "$chars" ''
    printf -v remain '%0*.*d' '' "$((width - chars))" ''
 
    # replace the zeros with the desired char
    complete=${complete//0/"$completed_char"}
    remain=${remain//0/"$uncompleted_char"}
 
    printf '%s%s%s%s %s%s\r' "$prefix" "$complete" "$remain" "$suffix" "$percent" "$percent_sign"
 
	if (( current >= max )); then
		echo ""
	fi
} ### ProgressBar from: http://www.brianhare.com/wordpress/2011/03/02/bash-progress-bar/
PICDIR=$1					# /EK/A/B/160Interior
if [ $# -ne 1 ]; then
	echo "One parameter and only one ! ";
	echo -e "\tie. $0 /MY/JPEGFOLDER/ABSPATH";
	exit -1;
fi
BSD=$(basename $PICDIR)				# 160Interior
DIRBASE=${PICDIR:0:${#PICDIR}-${#BSD}-1}	# /EK/A/B/
STHUMBDIR=${STHUMBROOT}/$BSD
BTHUMBDIR=${BTHUMBROOT}/$BSD
HOWMANY=$(find $PICDIR -name *.jpg -size +10c -type f | wc -l)
HTML_MAIN_PAGE=${HTML_MAIN}${HTML_KEY_NAME}.html
HTML_SUB=${HTML_MAIN}${HTML_KEY_NAME}-${BSD}.html

if [ -e $STHUMBDIR ] || [ -e $BTHUMBDIR ]; then
	echo "Thumbs directories exist. Checking...";
	echo -e "\t\t$STHUMBDIR";
        echo -e "\t\t$BTHUMBDIR";
	echo -e "\tShould be ${HOWMANY} in total.";
	if [ -e $STHUMBDIR ] && [ -e $BTHUMBDIR ]; then
		sleep 0.05
	else
		if [ -e $STHUMBDIR ]; then
			mkdir -p ${BTHUMBDIR}
		else
			mkdir -p ${STHUMBDIR}
		fi
	fi

	HOWMANY_SMALL=$(find "$STHUMBDIR" -name *.gif -type f | wc -l)
	HOWMANY_BIG=$(find "$BTHUMBDIR" -name *.gif -type f | wc -l)
	TMP_DONE_SMALLTHUMBS_LIST=$TMP/donelist`date +%Y%m%d%H%M%S%N`
	sleep 0.03 ## delay a bit is enough
        TMP_DONE_BIGTHUMBS_LIST=$TMP/donelist`date +%Y%m%d%H%M%S%N`
	sleep 0.03 ## delay a bit is enough
	TMP_ALL_LIST=$TMP/donelist`date +%Y%m%d%H%M%S%N`
	IS_SMALL_DONE=$(if [[ $HOWMANY_SMALL -eq HOWMANY ]]; then echo 'all done.'; else echo 'missing...'; fi)
	IS_BIG_DONE=$(if [[ $HOWMANY_BIG -eq HOWMANY ]]; then echo 'all done.'; else echo 'missing...'; fi)
	printf "\tSmall Thumbs: %6s\t\t[%13s]\n" "${HOWMANY_SMALL}" "${IS_SMALL_DONE}"
	printf "\tBig Thumbs:   %6s\t\t[%13s]\n" "${HOWMANY_BIG}" "${IS_BIG_DONE}"
	find "$PICDIR" -name *.jpg -type f -printf "%i\n" | sort > $TMP_ALL_LIST
        if [[ "${IS_SMALL_DONE:0:1}" == "m" ]]; then
                REMAINING_CNT=$((${HOWMANY}-${HOWMANY_SMALL}))
                echo "Going on to small thumbs... Remains ${REMAINING_CNT} images to go.";
                cnt=$[$HOWMANY_SMALL+1]
                find "$STHUMBDIR" -name *.gif -type f -printf '%f\n' | cut -d"_" -f2 | cut -d"." -f1 | sort > "$TMP_DONE_SMALLTHUMBS_LIST"
                diff $TMP_ALL_LIST $TMP_DONE_SMALLTHUMBS_LIST | grep "<" | cut -c3- | while read i; do
                        find "$PICDIR" -inum "$i" -printf "convert -define jpeg:size=200x200 '%p' -thumbnail '100x100>' -gravity center -crop 120x120+0+0! -background skyblue -flatten '$STHUMBDIR/thumb_%i.gif'\n" | bash
                        lib_progress_bar -d 2 -m 55 $cnt ${HOWMANY}
                        cnt=$[$cnt+1]
                done
                rm  $TMP_DONE_SMALLTHUMBS_LIST
        fi

        if [[ "${IS_BIG_DONE:0:1}" =~ "m" ]]; then
                REMAINING_CNT=$((${HOWMANY}-${HOWMANY_BIG}))
                echo "Going on to big thumbs... Remains ${REMAINING_CNT} images to go.";
                cnt=$[$HOWMANY_BIG+1]
                find "$BTHUMBDIR" -name *.gif -type f -printf '%f\n' | cut -d"_" -f2 | cut -d"." -f1 | sort > "$TMP_DONE_BIGTHUMBS_LIST"
                diff $TMP_ALL_LIST $TMP_DONE_BIGTHUMBS_LIST | grep "<" | cut -c3- | while read i; do
                        find "$PICDIR" -inum "$i" -printf "convert '%p' -resize x640 -resize '640x<' -gravity center -crop 640x480+0+0 +repage -flatten '${BTHUMBDIR}/thumbbig_%i.gif'\n" | bash
                        lib_progress_bar -d 2 -m 55 $cnt ${HOWMANY}
                        cnt=$[$cnt+1]
                done
                rm $TMP_DONE_BIGTHUMBS_LIST
        fi

	rm $TMP_ALL_LIST
else
	## from scratch: goo!
	mkdir -p ${STHUMBDIR}
	mkdir -p ${BTHUMBDIR}
	cnt=1
	echo "Generating small thumbs..."
	find $PICDIR -name *.jpg -size +10c -type f -printf "convert -define jpeg:size=200x200 '%p' -thumbnail '100x100>' -gravity center -crop 120x120+0+0! -background skyblue -flatten '$STHUMBDIR/thumb_%i.gif'\n" | while read i; do
		sh -c "$i"
		lib_progress_bar -d 2 -m 55 $cnt ${HOWMANY}
                cnt=$[$cnt+1]
	done
	echo "Generating big thumbs..."
	find $PICDIR -name *.jpg -size +10c -type f -printf "convert '%p' -resize x640 -resize '640x<' -gravity center -crop 640x480+0+0 +repage -flatten '$BTHUMBDIR/thumbbig_%i.gif'\n" | while read i; do
                sh -c "$i"
                lib_progress_bar -d 2 -m 55 $cnt ${HOWMANY}
                cnt=$[$cnt+1]
        done
fi


## web
echo "Generating HTML body..."
cnt=1
> $TMP_HTML_THUMBS
find ${STHUMBDIR} -name *.gif -printf '%f\n' | xargs -n1 echo | while read i; do
	INUM=${i:6:-4}
	find ${DIRBASE} -inum ${INUM} -printf '"%p" "%i" "%p" "%i"' | xargs -n4 printf '<li><a href="'${WEBROOT}'%s" data-largesrc="'${WEBROOT}${BTHUMBROOT}/${BSD}'/thumbbig_%s.gif" data-title="%s" data-description="Thumb"><img src="'${WEBROOT}${STHUMBROOT}/${BSD}'/thumb_%s.gif" alt="image thumb"/></a></li>\n' >> $TMP_HTML_THUMBS
	lib_progress_bar -d 2 -m 55 $cnt ${HOWMANY}
        cnt=$[$cnt+1]
done

cat "$HTML_TEMP_UP" "$TMP_HTML_THUMBS" "$HTML_TEMP_DOWN" > $HTML_SUB
rm "$TMP_HTML_THUMBS"

## update main page with links to generated html's
ls $HTML_MAIN | grep ^$HTML_KEY_NAME | grep html$ | while read i; do
	echo "<li><a href=\"${i}\">${i}</a></li>";
done > $HTML_MAIN_PAGE

echo "ok."
