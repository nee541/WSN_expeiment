# WSN_expeiment

实验所需的的所有文件位于**1.0**中, 进入1.0文件夹然后使用如下命令：

``` shell
make micaz sim
python simu.py
```

然后启动信息就会打印在屏幕上。发送方，接收方和数据包的信息分别能够在**log**文件夹内的*send.log*, *rec.log*, *pkg.log*找到。
如果想要更改打印位置，修改*simu.py*文件中stream字典即可，sys.stdout将输出定向到屏幕，open()则将输出定向到文件

```python
stream = {
    "Boot": sys.stdout,
    "Radio": sys.stdout,
    "Led": sys.stdout,
    "RadioSend": open(logDir + "/send.log", "w"),
    "RadioRec": open(logDir + "/rec.log", "w"),
    "Pkg": open(logDir + "/pkg.log", "w")
}
```

输出信息数据包如下所示

```shell
        >>>Pack
                 Payload length 4
                 AM Adress: 2
                 Source: 1
                 Destination: 2
                 AM Type: 240
                         Payload
                         node_id:  1
                         msg_number: 19
                         value: 0
```

- Payload 代表自定义的数据
  - node_id 代表发送方的node id
  - msg_number 代表发送发发送的包的序列号，所以不同发送方可以有相同的序列号
  - value 自定义的value(忘了删了，没有特殊含义)

- AM Adress 代表当前节点的地址

- Source 代表数据包发送方的地址

- Destination 代表数据包接收方地址

- AM Type 代表自定义的数据包类型(240是随便定的)
