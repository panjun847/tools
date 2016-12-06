#!/bin/bash
function main(){
  local conf="$1";
  if [ ! -f "${conf}" ];then
    printf "`getRedText "$0 的参数必须为文件"`";
    exit 1;
  fi
  cat $1 | while read line
  do
    is_comment $line;
    if [ $? -ne 1 ];then #行没有被注释
      is_target $line;
      if [ $? -ne 0 ];then  #此行定义的是一个目标
        targetFile=`get_target $line`;
        pageLink=`get_page_link $line`;
        sedTarget=`get_sed_target $line`;
        if [ -f "${targetFile}" ];then
          #
          rename $targetFile $pageLink "$sedTarget";
        else
          printf "`getRedText "$targetFile 未找到文件" ` "
        fi
      fi
    fi
  done
}
function is_comment(){
  local trimed=$1;
  trimed=${trimed%%};
  trimed=${trimed##};
  local len=${#trimed}
  local sp=`expr index "$trimed" \#`;
  if [ $len -eq 0 ] || [ $sp -ne 0 ];then # sharp的index不等于0或者有效字符为0（空行） 都视为注释行
    return 1
  else
    return 0
  fi
}
function is_target(){
  local trimed=$1;
  trimed=${trimed%%};
  trimed=${trimed##};
  local sp=`expr index "$trimed" :`;
  if [ $sp -gt 1 ];then
    return 1;
  else
    return 0;
  fi
}
function get_target(){
  local trimed=$1;
  echo ${trimed%%:*};
}
function get_page_link(){
  #获取在页面中的引用地址
  local trimed=$1;
  trimed=${trimed%:*};
  echo ${trimed#*:};
}
function get_sed_target(){
  #获取在页面中的引用地址
  local trimed=$1;
  echo ${trimed##*:};
}
function getGreenText(){
  echo "\033[32;49;1m [$1] \n\033[39;49;0m";
}
function getRedText(){
  echo "\033[31;49;1m [$1] \n\033[39;49;0m";
}
function rename(){
  local targetFile="$1"
  local pageLink="$2";
  local sedTarget="$3";
  local targetVer=`md5sum $targetFile | awk '{$a=substr($0,0,6);print $a}'`;
  #目标文件的名字和后缀名
  local targetBase=${targetFile%.*};
  local targetSuffix=${targetFile##*.};
  local targetRes="$targetBase.$targetVer.$targetSuffix"
  mv $1 $targetRes;
  printf "`getRedText "===================="`";
  printf "`getGreenText "$1 重命名为  $targetRes"`";
  #replace html include
  local pageLinkBase=${pageLink%.*};
  local pageLinkSuffix=${pageLink##*.};
  sed -i "s%$2%$pageLinkBase.$targetVer.$pageLinkSuffix%g" $sedTarget;
  printf "`getGreenText "$sedTarget \n     $2 => $targetRes"`";
  printf "`getRedText "===================="`";
}

###############################

main $1;

##############################
