# 相关命令
lscpu
cpupower frequency-info

# 相关软件包
cpupower        自带
cpupower-gui    aur
thermald        防止cpu过热（只支持SandyBridge或IvyBridge架构的CPU）

# 切换CPU调节器(governor)

使用如下命令或者安装cpupower-gui来切换

```shell
# cpupower frequency-set -g governor
# 如
cpupower frequency-set -g powersave
```

| 调速器           | 描述                                                         |
| ---------------- | ------------------------------------------------------------ |
| performance      | 更好性能                                                     |
| powersave        | 更省电                                                       |
| ~~userspace~~    | ~~运行于用户指定的频率~~                                     |
| ~~ondemand~~     | ~~按需快速动态调整CPU频率， 一有cpu计算量的任务，就会立即达到最大频率运行，空闲时间增加就降低频率~~ |
| ~~conservative~~ | ~~按需快速动态调整CPU频率， 比 ondemand 的调整更保守~~       |
| ~~schedutil~~    | ~~基于调度程序调整 CPU 频率 [[1\]](http://lwn.net/Articles/682391/), [[2\]](https://lkml.org/lkml/2016/3/17/420).~~ |

**SandyBridge或更新架构只有powersave和performance两种调节器**

Depending on the scaling driver, one of these governors will be loaded by default:

- `ondemand` for AMD and older Intel CPU.
- `powersave` for Intel CPUs using the `intel_pstate` driver (Sandy Bridge and newer).

