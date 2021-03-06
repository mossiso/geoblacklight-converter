#! /usr/bin/env bash

#set -x

ESC_SEQ="\x1b["
COL_RESET=$ESC_SEQ"39;49;00m"
COL_RED=$ESC_SEQ"31;01m"
COL_GREEN=$ESC_SEQ"32;01m"
COL_YELLOW=$ESC_SEQ"33;01m"
COL_BLUE=$ESC_SEQ"34;01m"
COL_MAGENTA=$ESC_SEQ"35;01m"
COL_CYAN=$ESC_SEQ"36;01m"

MODS_DIR="mods"
GEOB_DIR="geoblacklight"
DATA_DIR="data"
GEOSERVER_ROOT="http://gis.lib.virginia.edu/geoserver"
STACKS_ROOT="http://gis.lib.virginia.edu"

make_dirs() {
  echo -e "${COL_CYAN}Making data directories... $COL_RESET"
  mkdir -p $MODS_DIR
  mkdir -p $GEOB_DIR
  mkdir -p $DATA_DIR
}

convert_mods() {
  for file in $DATA_DIR/*.xml; do
    ofn="$MODS_DIR/`basename $file`"
    if [ ! -r "$ofn" ]; then
      echo  -e "$COL_GREEN Converting ISO for$COL_RESET$COL_YELLOW $ofn$COL_RESET$COL_GREEN to MODS $COL_RESET"
      xsltproc \
        xslt/iso2mods.xsl "$file" > "$ofn"
    fi
  done
}

convert_solr()
{
  for file in $MODS_DIR/*.xml; do
    ofn="$GEOB_DIR/`basename $file`"
    if [ ! -r "$ofn" ]; then
      echo  -e "$COL_GREEN  Converting MODS for$COL_RESET$COL_YELLOW $ofn$COL_RESET$COL_GREEN to Solr $COL_RESET"
      xsltproc \
        -stringparam geoserver_root $GEOSERVER_ROOT \
        -stringparam now `date -u "+%Y-%m-%dT%H:%M:00Z"` \
        -stringparam rights "Public" \
        -stringparam stacks_root $STACKS_ROOT \
        xslt/mods2geoblacklight.xsl "$file" > "$ofn"
    fi
  done
}

cleanup() {
  echo -e "${COL_CYAN}Cleaning up old files... $COL_RESET"
  rm -f $DATA_DIR/*.xml
  rm -f $MODS_DIR/*.xml
  rm -f $GEOB_DIR/*.xml
}

clear

if [ -d "$DATA_DIR" ]; then
    cleanup
else
    make_dirs
fi

ruby fetch-data.rb
convert_mods
convert_solr


exit $?


