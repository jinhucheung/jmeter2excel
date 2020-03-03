# JMeter2Excel

JMeter 测试用例转 Excel 工具

## 安装

首先使用 RVM 安装 Ruby 环境，参考 Ruby China [文档](https://ruby-china.org/wiki/rvm-guide)

然后执行以下命令安装依赖：

```
bundle install
```

## 使用

执行以下命令进行导出：

```
./run.rb $jmeter_file_path
```

其中 `$jmeter_file_path` 是待处理的 jmeter 文件路径，导出文件将在 `outs` 目录内
