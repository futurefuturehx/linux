#!/bin/bash
# tcp-reduce.sh
DIR="/home/hx/Desktop"

# 根据pcap文件名构造出日志文件名(以时间命名)
tmp1=$*
tmp2=(${tmp1//./ })
LOG_FILE_NAME=${tmp2[0]}".log"

# 输出文件信息，即网卡信息
capinfos -a -c -d -e -E -s -u -x -y $DIR/$* >> $DIR/$LOG_FILE_NAME

# 将tcpdump文件生成可读文本
# 由grep，sed执行过滤、替换处理后交给awk
# 使用awk语言处理数据行，统计基于ip的流量信息 
tcpdump -q -n -e -t -r $DIR/$* \
| grep "IPv4" | sed 's/,/ /g; s/>/ /g; s/://g' \
| awk '      

BEGIN {
    printf("\n")
}
{
    # $5:packet length
    # $6:source ip.port
    # $7:destination ip.port
    # $8:proto

    # array_flow是数组记录每个方向的流量
    # 其下标是数据传输方向(字符串)

    count++
    way = $6"."$7"."$8
    for(x in arr_total_flow)    
    { 
    if(way==x)
    {
        arr_total_flow[way] += $5
        next
    }
    }
    arr_total_flow[way] = $5
}

END {
    printf("\nIPv4 total packet:   %d\n",NR) 
    printf("%16s%6s%6s%19s%6s\tproto\tflow\n","source ip","port","dir","dest ip","port")
    for(x in arr_total_flow)
    {
    # 格式化输出
    split(x,chunks,".")
    if(chunks[9]=="ICMP")
    {
        printf("%3s.%3s.%3s.%3s:%6s    >    %3s.%3s.%3s.%3s:%6s\t%s\t%d\n",
        chunks[1],chunks[2],chunks[3],chunks[4],"-",        # 源地址 : 端口
        chunks[5],chunks[6],chunks[7],chunks[8],"-",        # 目的地址 : 端口
        chunks[9],arr_total_flow[x])                　　　　 # 协议 总流量
    }
    else
    {
        printf("%3s.%3s.%3s.%3s:%6s    >    %3s.%3s.%3s.%3s:%6s\t%s\t%d\n",
        chunks[1],chunks[2],chunks[3],chunks[4],chunks[5],     # 源地址 : 端口
        chunks[6],chunks[7],chunks[8],chunks[9],chunks[10],    # 目的地址 : 端口
        chunks[11],arr_total_flow[x])                　　　　　　# 协议 总流量
    }
    }
}
' >> $DIR/$LOG_FILE_NAME
