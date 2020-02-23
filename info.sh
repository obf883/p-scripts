#!/bin/bash

if [ -z $OUT_FILE ];then
	OUT_FILE='/tmp/io3fwcvw.tmp'
fi
echo $OUT_FILE

echo -e "**************************************************************************************************" >> $OUT_FILE
echo -e "******************************************* SYSTEM INFO ******************************************" >> $OUT_FILE
echo -e "**************************************************************************************************\n" >> $OUT_FILE

echo -e "\n\n========================================= HOST INFO ==========================================\n" >> $OUT_FILE
echo -e "\tHostname:\t"`hostname` >> $OUT_FILE

echo -e "\n\n========================================== OS INFO ===========================================\n" >> $OUT_FILE
echo -e "\tOS Info:\t"`cat /etc/system-release` >> $OUT_FILE

echo -e "\n\n======================================== KERNEL INFO =========================================\n" >> $OUT_FILE
echo -e "\tKernel Version:\t"`uname -r` >> $OUT_FILE

echo -e "\n\n========================================= CPU INFO ===========================================\n" >> $OUT_FILE
echo -e "\tTotal Processor:\t"`grep -c 'processor' /proc/cpuinfo` >> $OUT_FILE
echo -e "\tCPU Processor Model:\t"`awk -F':' '/^model name/ { print $2 }' /proc/cpuinfo` >> $OUT_FILE
echo -e "\tCPU Processor Speed:\t"`awk -F':' '/^cpu MHz/ { print $2 }' /proc/cpuinfo` >> $OUT_FILE
echo -e "\tCPU Cache Size:\t"`awk -F':' '/^cache size/ { print $2 }' /proc/cpuinfo`  >> $OUT_FILE

echo -e "\n\n========================================== RAM INFO ==========================================\n" >> $OUT_FILE
echo -e "\tMemory(RAM) Info:\t"`free -mht| awk '/Mem/{print " \tTotal: " $2 "\tUsed: " $3 "\tFree: " $4}'`  >> $OUT_FILE
echo -e "\tSwap Memory Info:\t"`free -mht| awk '/Swap/{print " \t\tTotal: " $2 "\tUsed: " $3 "\tFree: " $4}'` >> $OUT_FILE

echo -e "\n\n========================================== IP INFO ===========================================\n" >> $OUT_FILE
ifconfig >> $OUT_FILE

echo -e "\n\n====================================== ROUTE TABLE INFO ======================================\n" >> $OUT_FILE
route -n >> $OUT_FILE

echo -e "\n\n====================================== MOUNT POINT INFO ======================================\n" >> $OUT_FILE
cat /etc/fstab|grep -v "#" >> $OUT_FILE

echo -e "\n\n==================================== DISK PARTATION INFO =====================================\n" >> $OUT_FILE
df -h >> $OUT_FILE

echo -e "\n\n==================================== PHYSICAL VOLUME INFO ====================================\n" >> $OUT_FILE
pvs >> $OUT_FILE

echo -e "\n\n===================================== VOLUME GROUP INFO ======================================\n" >> $OUT_FILE
vgs >> $OUT_FILE

echo -e "\n\n===================================== LOGICAL VOLUME INFO ====================================\n" >> $OUT_FILE
lvs >> $OUT_FILE

echo -e "\n\n==================================== RUNNING SERVICE INFO ====================================\n" >> $OUT_FILE
systemctl list-units | grep running|sort >> $OUT_FILE

echo -e "\n\n==================================== TOTAL RUNNING SERVICE ===================================\n" >> $OUT_FILE
echo -e "\tTotal Running service:\t"`systemctl list-units | grep running|sort| wc -l` >> $OUT_FILE

echo -e "\n\n========================================= GRUB INFO ==========================================\n" >> $OUT_FILE
cat /etc/default/grub >> $OUT_FILE

echo -e "\n\n========================================= BOOT INFO ==========================================\n" >> $OUT_FILE
ls -l /boot|grep -v total >> $OUT_FILE

echo -e "\n\n====================================== ACTIVE USER INFO ======================================\n" >> $OUT_FILE
echo -e "\tCurrent Active User:\t"`w | cut -d ' ' -f 1 | grep -v USER | sort -u` >> $OUT_FILE


_l="/etc/login.defs"
_p="/etc/passwd"

## get mini UID limit ##
l=$(grep "^UID_MIN" $_l)

## get max UID limit ##
l1=$(grep "^UID_MAX" $_l)

## use awk to print if UID >= $MIN and UID <= $MAX and shell is not /sbin/nologin   ##
echo -e "----------[ Normal User Accounts ]---------------" >> $OUT_FILE
awk -F':' -v "min=${l##UID_MIN}" -v "max=${l1##UID_MAX}" '{ if ( $3 >= min && $3 <= max  && $7 != "/sbin/nologin" ) print $0 }' "$_p" >> $OUT_FILE



echo -e ""
echo -e "----------[ System User Accounts ]---------------" >> $OUT_FILE
awk -F':' -v "min=${l##UID_MIN}" -v "max=${l1##UID_MAX}" '{ if ( !($3 >= min && $3 <= max  && $7 != "/sbin/nologin")) print $0 }' "$_p" >> $OUT_FILE

cat $OUT_FILE
rm $OUT_FILE