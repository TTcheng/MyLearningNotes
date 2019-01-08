## 实现过程

### 1、编写任务类

`note:继承AbstractJob`

```java
import com.hand.hap.job.AbstractJob;
import org.quartz.JobExecutionContext;

public class HelloJob extends AbstractJob {
    @Override
    public void safeExecute(JobExecutionContext jobExecutionContext) throws Exception {
        System.out.println("============================");
        System.out.println("=========HelloWorld=========");
        System.out.println("============================");
    }
}

```
### 2、配置任务

计划任务=>任务明细=>新增简单任务