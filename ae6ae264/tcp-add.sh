#!/bin/bash
# 作为tcpdump的-z参数使用
# 将已经存储完的pcap文件名加入ready.txt等待处理

echo $* >> ready.txt
