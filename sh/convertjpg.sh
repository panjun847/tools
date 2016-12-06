#!/bin/bash
function main(){
  which convert > /dev/null 2>&1
  if [ $? != 0  ]; then
    echo "找不到 convert 命令 请先安装ImageMagick，apt，yum或者http://www.imagemagick.org/"
    exit 1;
  fi
  forEach "$1"
}
function forEach(){
  local distDir=`get_dist_dir $1`;
  mkdir -p $distDir;
  printf "`getRedText "createDir $distDir"`"
  for i in "$1"/*
  do
   if [ -d $i ];then
    forEach $i;
   else
    local suffix=`get_suffix $i`;
    local distName=`get_dist_dir $i`;
    if [ "$suffix" = "jpg" ] || [ "$suffix" = "jpeg" ];then
      convert -quality 80% $i $distName;
      printf "`getGreenText "   convert $i -> $distName"`";
    else
      cp $i $distName;
      printf "`getGreenText "   copy $i -> $distName"`";
    fi
   fi
  done
}
function get_suffix(){
  local file="$1";
  echo ${file##*.};
}
function get_dirname(){
  local file="$1";
  echo ${file%/*};
}
function get_dist_dir(){
  local dname="$1"
  #dname=${dname/.jpg/.jpeg}
  echo ${dname/src/dist}
}
function getGreenText(){
  echo "\033[32;49;1m $1 \n\033[39;49;0m";
}
function getRedText(){
  echo "\033[31;49;1m $1 \n\033[39;49;0m";
}
#####################
main $1;
####################
