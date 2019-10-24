#!/bin/bash
#Параметры
#путь до скрипта
SH_FILEPATH=/root/tshark-demon.sh
#путь до лог файла
CURRENT_LOG_FILE=/var/log/tshark.log
MINUTES_MIN=15
FILESIZE_LOG_M_MIN=80
#текущая дата
DATE=$(date +"%m-%d-%y_%T")
#Копируем предыдущий лог
cp $CURRENT_LOG_FILE "${CURRENT_LOG_FILE}_${DATE}_first"
#запуск фонового процесса
tshark -i enp1s0 host 192.168.10.33 -u s -t ad -o column.format:"Time","%t","Source, %s","Destination, %d","Protocol, %p","Info, %i" | cut -c1-260 > $CURRENT$
#ИД последнего запущенного процесса
PROCESS_ID=$!
#echo $PROCESS_ID
#день запуска
DAY_START=$(date +"%d")
MINUTE_START=$(date +"%M")
#CURRENT
DAY_CURRENT=$(date +"%d")
MINUTE_CURRENT=$(date +"%M")
FILESIZE_LOG_BYTES=$(stat -c%s $CURRENT_LOG_FILE)
FILESIZE_LOG_M=0
FILESIZE_LOG_KB=0
if [ $FILESIZE_LOG_BYTES > 0 ]
then
        FILESIZE_LOG_KB=`expr $FILESIZE_LOG_BYTES / 1024`
        if [ $FILESIZE_LOG_KB > 0 ]
        then
                FILESIZE_LOG_M=`expr $FILESIZE_LOG_KB / 1024`
        fi
fi
#проверка текущего дня на соответствия с днем запуска
while :;
do
DAY_CURRENT=$(date +"%d")
MINUTE_CURRENT=$(date +"%M")
FILESIZE_LOG_BYTES=$(stat -c%s $CURRENT_LOG_FILE)
#FILESIZE_LOG_M=0
#FILESIZE_LOG_KB=0
if [ $FILESIZE_LOG_BYTES > 0 ]
then
        FILESIZE_LOG_KB=`expr $FILESIZE_LOG_BYTES / 1024`
        #echo $FILESIZE_LOG_KB
        if [ $FILESIZE_LOG_KB > 0 ]
        then
                FILESIZE_LOG_M=`expr $FILESIZE_LOG_KB / 1024`
        fi
fi

if [ $DAY_START != $DAY_CURRENT ]
then
        #echo 1
		break
fi
MINUTE_DIFF=`expr $MINUTE_CURRENT - $MINUTE_START`
#echo $MINUTE_DIFF
if [ $MINUTES_MIN -lt $MINUTE_DIFF ]
then
        #echo 2
        break
fi
#echo $FILESIZE_LOG_M
if [ $FILESIZE_LOG_M_MIN -lt $FILESIZE_LOG_M ]
then
        #echo 3
        break
fi

if ! ps -p $PROCESS_ID > /dev/null
then
        break
fi

done
cp $CURRENT_LOG_FILE "${CURRENT_LOG_FILE}_${DATE}"
#Убиваем процесс
if ps -p $PROCESS_ID > /dev/null
then
    kill $PROCESS_ID
fi
#переименовываем файл

rm "${CURRENT_LOG_FILE}_${DATE}"
#удаляем старый лог
#rm $CURRENT_LOG_FILE
#Запускаем заного скрипт
sh $SH_FILEPATH
exit
