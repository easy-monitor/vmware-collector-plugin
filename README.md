# EasyOps VMware 监控插件包

EasyOps VMware 监控插件包是适用于 EasyOps 新版监控平台，专门提供 VMware 监控服务的官方插件包。它提供了对 VMware 的常见监控指标进行采集的采集插件以及可视化的仪表盘展示。

## 目录

- [背景](#背景)
- [适用环境](#适用环境)
- [工作原理](#工作原理)
- [准备工作](#准备工作)
- [使用方法](#使用方法)
- [启动参数](#启动参数) 
- [项目内容](#项目内容)
- [维护者](#维护者)
- [许可证](#许可证)

## 背景

由于目前在 EasyOps 新版监控平台上搭建 VMware 监控场景需要经过以下步骤：

1. 自行搜索 VMware Exporter 并调试配置。
2. 在插件中心创建采集插件，使用步骤1输出的指标数据录入监控指标。
3. 使用创建的采集插件为具体的资源实例创建采集任务。
4. 理解监控指标含义后配置仪表盘展示。

所以为了实现 VMware 监控场景的快速搭建，该项目对 VMware 一些常见的监控指标及其采集脚本进行了封装，同时提供一个基本的仪表盘展示。

用户能够借助 EasyOps 平台提供的自动化工具来一键导入该插件包，真正做到 VMware 监控场景的开箱即用。

## 适用环境

VMware 6.0 以上

## 工作原理

1. VMware 监控插件包使用了第三方的 VMware Exporter 进行指标采集，该 Exporter 的 GitHub 链接为 https://github.com/pryorda/vmware_exporter 。

## 准备工作

1. 确认采集的 VMware 实例的地址。
2. 确认用来连接 VMware 实例的用户和密码。

## 使用方法

### 导入监控插件包

1. 下载该项目的压缩包 ( https://github.com/easy-monitor/vmware-collector-plugin/archive/master.zip )。

2. 建议解压到 EasyOps 平台服务器上的 `/data/easyops/monitor_plugin_packages` 目录下。

3. 使用 EasyOps 平台提供的自动化工具一键导入该插件包，具体命令如下，请替换其中的 `8888` 为当前 EasyOps 平台具体的 `org`。

```sh
$ cd /usr/local/easyops/collector_plugin_service/tools
$ sh plugin_op.sh install 8888 /data/easyops/monitor_plugin_packages/vmware-collector-plugin
```

4. 导入成功后访问 EasyOps 平台的「采集插件」列表页面 ( http://your-easyops-server/next/collector-plugin )，就能看到导入的 "vmware_collector_plugin" 采集插件。

### 启动 VMware Exporter

1. 编辑 `conf/config.yml` 配置文件，修改 `vsphere_host` 字段为采集的 VMware 实例具体的地址，`vsphere_user` 和 `vsphere_password` 字段为用来连接 VMware 实例具体的用户和密码。

```
default:
    vsphere_host: ''
    vsphere_user: ''
    vsphere_password: ''
    ...
```

2. 在启动时指定选择的配置文件，具体命令如下，请替换其中的 `--config—file-path` 参数为具体选择的配置文件路径。

```sh
$ cd /data/easyops/monitor_plugin_packages/vmware-collector-plugin/script
$ sh deploy/start_script.sh --config-file-path conf/config.yml
```

3. 通过访问 http://127.0.0.1:9272/metrics 来获取指标数据，请替换其中的 `127.0.0.1:9272` 为 Exporter 具体的监听地址和端口。

```sh
$ curl http://127.0.0.1:9272/metrics
```

4. 接下来可使用导入的采集插件创建采集任务来对接启动的 Exporter。

## 启动参数

| 名称 | 类型 | 必填 | 默认值 | 说明 |
| --- | --- | --- | --- | --- |
| config-file-path | string | false | conf/config.yml | 配置文件路径 |
| exporter-port | int | false | 9272 | Exporter 监听端口 |

## 项目内容

### 目录结构

```
vmware-collector-plugin
├── dashboard.json
├── log
│   └── vmware-collector-plugin.log
├── origin_metric.json
└── script
    ├── conf
    │   └── config.yml
    ├── deploy
    │   └── start_script.sh
    ├── package.conf.yaml
    ├── plugin.yaml
    └── src
        └── ...
```

该项目的目录结构遵循标准的 EasyOps 监控插件包规范，具体内容如下：

- dashboard.json: 仪表盘的定义文件
- log: 日志文件目录
- origin_metric.json: 采集插件关联的监控指标定义文件
- script: 采集插件关联的程序包目录，执行采集任务时会部署到指定的目标机器上
- script/conf: 配置文件目录
- script/deploy/start_script.sh: 启动脚本
- script/package.conf.yaml: 采集插件关联的程序包的定义文件
- script/plugin.yaml: 采集插件包的定义文件
- script/src: 采集插件包的 Exporter 目录

### plugin.yaml

```yaml
# 支持 easyops/prometheus/zabbix-agent 三种采集类型
# 1. easyops: 表示使用 EasyOps Agent 进行指标采集
# 2. prometheus: 表示对接 Prometheus Exporter 进行指标采集
# 3. zabbix-agent: 表示对接 Zabbix Agent 进行指标采集
agentType: prometheus

# 采集插件的名称，也是采集插件关联的程序包名称
name: vmware_collector_plugin
# 采集插件关联的程序包版本名称
version: 1.0.0

# 采集插件类别 
category: 虚拟化
# 采集插件参数列表
params:
  - config_file_path
  - exporter_port
```

## 维护者

@easyopscyrilchen

## 许可证

[MIT](#许可证) © EasyOps
