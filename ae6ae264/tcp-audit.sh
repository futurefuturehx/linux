#!/bin/bash
# tcp-audit.sh
# 读取ready.txt文件，每次读取一行
# 将其内容作为参数传给tcp-reduce.sh
# 执行完后删除该行

DIR="/home/hx/Desktop/"

while read line
do
    # tcp-reduce.sh处理
    $DIR/tcp-reduce.sh ${line}
    # 删除该pcap文件
    rm $DIR/${line}
    # 删除该行
    sed -i '1d' $DIR/ready.txt
done < $DIR/ready.txt
