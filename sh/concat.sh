#!/bin/bash
endStr="#####end####";
function main(){
  local conf="$1";
  if [ ! -f "${conf}" ];then
    printf "$0 的参数必须为文件\n";
    exit 1;
  fi
  which sass > /dev/null 2>&1
  if [ $? != 0  ]; then
    echo "找不到sass命令"
    exit 1;
  fi
  currentTarget="";
  echo "$endStr" >> $1;
  cat $1 | while read line
  do
    is_comment $line;
    if [ $? -ne 1 ];then #行没有被注释
      is_target $line;
      if [ $? -ne 0 ];then  #此行定义的是一个目标
        #如果上一个target存在，那进行一下结尾操作
        targetType=`getTargetType $currentTarget`;
        if [ "$currentTarget" != "" ] && [ "$2" != 'debug' ] && [ "$targetType" != "css" ] ;then
          #不在debug下的时候，用jar压缩一下
          minify $currentTarget;
        fi
        #开启一个新的target
        currentTarget=`get_target $line`;
        echo "" > $currentTarget;
        printf "=====================================\n `getGreenText "create $currentTarget"` \n"
      else 
        if [ "$currentTarget" != "" ];then
          targetType=`getTargetType $currentTarget`;
          if [ "$targetType" = "css" ];then
            sass --style compressed $line > $currentTarget;
          else
            cat $line >> $currentTarget;
          fi
          printf "     + $line\n";
        fi
      fi
    fi
    #如果文件读取结束target存在，进行一下结尾操作
    targetType=`getTargetType $currentTarget`;
    is_end $line;
    if [ $? -eq 1 ] && [ "$currentTarget" != "" ] && [ "$targetType" != "css" ] && [ "$2" != 'debug' ];then
      #不在debug下的时候，用jar压缩一下
      minify $currentTarget;
    fi
  done
  sed -i "/$endStr/d" $1;
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
  local len=${#trimed};
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
function getTargetType(){
  local trimed=$1;
  trimed=${trimed%%:*};
  echo ${trimed##*.};
}
function getGreenText(){
  echo "\033[32;49;1m [$1] \033[39;49;0m";
}
function minify(){
  if [ -f $1 ];then
      cat $1 | java -jar jar/compiler.jar  > $1.tmpfile 2>/dev/null; 
      mv $1.tmpfile $1;
      printf "\n `getGreenText "minify $1" `\n=====================================\n"
  fi
}
function is_end(){
  if [ $1"##" = "$endStr##" ];then
    return 1
  else
    return 0;
  fi
}
###############################

main "$1" "$2";

##############################
