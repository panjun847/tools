#!/bin/bash
function main(){
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

    printf "`getGreenText " gen_template start  $i -> $distName"`";
    gen_template $i $distName;
    del_comments $distName;
   fi
  done
}
function del_comments(){
  local distFile=$1;
  sed -i '/<!--del-->/,/<!--delend-->/d' $distFile;
}
function gen_template(){
  local srcFile=$1;
  local distFile=$2;
  #cat file to dist
  cat $srcFile >$distFile
  grep -E -o '<!--include\s+(.*)-->' $srcFile | while read line
  do
    tplName=`get_tpl_name "$line"`;
    insert_tpl_to_html $tplName $distFile;
  done
}
function insert_tpl_to_html(){
  local tplName="$1";
  local distFile="$2";
  local tmpA=./.tmp/$distFile.a;
  local tmpB=./.tmp/$distFile.b;
  local dir=${tmpA%/*};
  mkdir -p $dir;
  if [ -f $tplName ] ;then
    #split distFile by include position
    local num=`grep -nEo "<!--include\s+$tplName-->" $distFile |head -1| awk -F":" '{print $1}'`;
    local count=`wc -l $distFile | awk '{print $1}'`; 
      sed -n -e "1,${num}p" $distFile | sed -e "${num}d" > $tmpA;
    num=`expr $num + 1`
      sed -n "${num},${count}p" $distFile > $tmpB;

    cat $tmpA $tplName $tmpB > $distFile
  else
    echo "Tpl not exist"
  fi
  printf "`getGreenText "   insert tpl($tplName) to html($distFile)"`";
}
function get_tpl_content(){
  local tplName=$1;
  result=""
  cat $tplName | while read line
  do
    result="${result}"\n"${line}";
  done
  print "${result}";
}
function get_tpl_name(){
  local tplName="$1";
  tplName=${tplName/#<!--/};
  tplName=${tplName/%-->/};
  tplName=${tplName/include/};
  tplName=${tplName##};
  tplName=${tplName%%};
  echo $tplName
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
  dname=${dname/\/html/}
  echo ${dname/src/dist}
}
#hard code template url
function get_template_url(){
  local dname="$1"
  dname=${dname/\/html/\/template}
  echo $dname$2;
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
