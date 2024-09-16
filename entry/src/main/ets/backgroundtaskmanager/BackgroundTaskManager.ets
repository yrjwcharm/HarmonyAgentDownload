import { WantAgent, wantAgent } from '@kit.AbilityKit';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { BusinessError } from '@kit.BasicServicesKit';

export class BackgroundTaskManager {
  private static instance: BackgroundTaskManager;
  private static context: Context;
  private id: number = 0; // 申请短时任务ID
  private delayTime: number = 0; // 本次申请短时任务的剩余时间
  constructor(context: Context) {
    BackgroundTaskManager.context = context;
  }

  public static getInstance(context: Context) {
    if (!BackgroundTaskManager.instance) {
      BackgroundTaskManager.instance = new BackgroundTaskManager(context);
    }
    return BackgroundTaskManager.instance;
  }

  requestSuspendDelay() {
    let myReason = 'test requestSuspendDelay'; // 申请原因
    let delayInfo = backgroundTaskManager.requestSuspendDelay(myReason, () => {
      // 回调函数。应用申请的短时任务即将超时，通过此函数回调应用，执行一些清理和标注工作，并取消短时任务
      console.info('suspend delay task will timeout');
      backgroundTaskManager.cancelSuspendDelay(this.id);
    })
    this.id = delayInfo.requestId;
    this.delayTime = delayInfo.actualDelayTime;
  }

  startContinuousTask = () => {
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      // 点击通知后，将要执行的动作列表
      // 添加需要被拉起应用的bundleName和abilityName
      wants: [
        {
          bundleName: "com.example.myapplication",
          abilityName: "com.example.myapplication.EntryAbility"
        }
      ],
      // 指定点击通知栏消息后的动作是拉起ability
      actionType: wantAgent.OperationType.START_ABILITY,
      // 使用者自定义的一个私有值
      requestCode: 0,
      // 点击通知后，动作执行属性
      actionFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    };

    // 通过wantAgent模块下getWantAgent方法获取WantAgent对象
    wantAgent.getWantAgent(wantAgentInfo).then((wantAgentObj: WantAgent) => {
      backgroundTaskManager.startBackgroundRunning(BackgroundTaskManager.context,
        backgroundTaskManager.BackgroundMode.TASK_KEEPING, wantAgentObj).then(async () => {
        // 此处执行具体的长时任务逻辑，如放音等。
        backgroundTaskManager.stopBackgroundRunning(BackgroundTaskManager.context);
      }).catch((err: BusinessError) => {
        console.error(`Failed to operation startBackgroundRunning. Code is ${err.code}, message is ${err.message}`);
      });
    });
  }
}