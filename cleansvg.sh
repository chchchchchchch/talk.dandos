#!/bin/bash

# TO BE TESTED!!!# TO BE TESTED!!!!!
# REMOVE SODIPODI IMAGE LINKS, ABSOLUTE LINKS, PERSONAL DATA

  SVG="show.svg"
  XLINKID="xlink:href"
  REF=/tmp/ref${RANDOM}.tmp


# SAVE TIMESTAMP
# ---------------------------------------------------------------- #
  touch -r $SVG $REF

# CHANGE TO SVG FOLDER
# ---------------------------------------------------------------- #
  SVGPATH=`realpath $SVG | rev | cut -d "/" -f 2- | rev`
  cd $SVGPATH; SVG=`basename $SVG`

# VACUUM DEFS, REMOVE SODIPODI IMG LINK, REMOVE EXPORT PATH
# ---------------------------------------------------------------- #
  inkscape --vacuum-defs $SVG
  sed -i 's/sodipodi:absref="[^"]*"//' $SVG
  sed -i 's/inkscape:export-filename="[^"]*"//g' $SVG
  sed -i '/^[ \t]*$/d' $SVG

# ---------------------------------------------------------------- #
# CHANGE ABSOLUTE PATHS TO RELATIVE

  for XLINK in `cat $SVG | \
                sed "s/$XLINKID/\n$XLINKID/g" | \
                grep "$XLINKID"`
   do
    if [ `echo $XLINK   | # START WITH XLINK
          grep -v '="#' | # IGNORE NO IMAGES
          wc -l` -gt 0 ]; then
    IMGSRC=`echo $XLINK         | # START WITH XLINKG
            cut -d "\"" -f 2    | # SELECT IN QUOTATION
            sed "s/$XLINKID//g" | # RM XLINK
            sed 's,file://,,g'`   # RM file://
    if [ -f "$IMGSRC" ]; then
    IMG=`basename $IMGSRC`
    IMGPATH=`realpath $IMGSRC | rev | # GET FULL PATH
             cut -d "/" -f 2- | rev`  #  
    RELATIVEPATH=`python -c \
    "import os.path; print os.path.relpath('$IMGPATH','$SVGPATH')"`
    NEWXLINK="$XLINKID=\"$RELATIVEPATH/$IMG\""
    sed -i "s,$XLINK,$NEWXLINK,g" $SVG

    echo "SVG =  $SVGPATH/$SVG"
    echo "IMG =  $IMGPATH/$IMG"
    echo "NEW =  $RELATIVEPATH/$IMG"

    fi
   fi
  done
# ---------------------------------------------------------------- #

# RESTORE TIMESTAMP
# ---------------------------------------------------------------- #
  touch -r $REF $SVG
  cd - > /dev/null

rm $REF

exit 0;

