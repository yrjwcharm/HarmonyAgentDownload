import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import SqliteHelper from '../db/SqliteHelper';
import { relationalStore } from '@kit.ArkData';
import { request } from '@kit.BasicServicesKit';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { DownloadManager } from '../downloadmanager/DownloadManager';

let id: number; // 申请短时任务ID
let delayTime: number; // 本次申请短时任务的剩余时间

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    console.log('MyAbility onCreate');
  }


  async onWindowStageCreate(windowStage: window.WindowStage) {
    // StatusBarManager.immerseFullScreenAsync(windowStage)
    await SqliteHelper.getInstance(this.context)?.initRDB();
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    windowStage.loadContent('pages/MultiDownloadPage', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
    });

  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground() {
    this.requestSuspendDelay();
  }


  // 申请短时任务
  requestSuspendDelay() {
    let myReason = 'test requestSuspendDelay'; // 申请原因
    let delayInfo = backgroundTaskManager.requestSuspendDelay(myReason, () => {
      // 回调函数。应用申请的短时任务即将超时，通过此函数回调应用，执行一些清理和标注工作，并取消短时任务
      console.info('suspend delay task will timeout');
      backgroundTaskManager.cancelSuspendDelay(id);
    })
    id = delayInfo.requestId;
    delayTime = delayInfo.actualDelayTime;
  }

  async onDestroy() {
    let predicates = new relationalStore.RdbPredicates('downloadinfo');
    predicates.equalTo('userID', '1');
    predicates.equalTo('status', 2).or()
    predicates.equalTo('status', 0)
    predicates
    let list = await SqliteHelper.getInstance(this.context).queryData(predicates)
    for (let i = 0; i < list.length; i++) {
      let predicates = new relationalStore.RdbPredicates('downloadinfo');
      await request.agent.remove(list[i].taskId);
      predicates.equalTo('downloadId', list[i].downloadId)
      DownloadManager.writeTmpBytes(this.context, list[i].fileName, async bytes => {
        await SqliteHelper.getInstance(this.context).update({
          'status': 0,
          downloadSize: bytes,
        }, predicates)
      })

    }
  }
}