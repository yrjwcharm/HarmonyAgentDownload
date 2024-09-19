import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import SqliteHelper from '../db/SqliteHelper';
import { relationalStore } from '@kit.ArkData';
import { request } from '@kit.BasicServicesKit';
import { DownloadManager } from '../downloadmanager/DownloadManager';


export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    console.log('MyAbility onCreate');
  }


  async onDestroy() {
    let predicates = new relationalStore.RdbPredicates('downloadinfo');
    predicates.equalTo('userID', '1');
    predicates.equalTo('status', 2)
    let list = await SqliteHelper.getInstance(this.context).queryData(predicates)
    for (let i = 0; i < list.length; i++) {
      let predicates = new relationalStore.RdbPredicates('downloadinfo');
      await request.agent.remove(list[i].taskId);
      // 进度更新... 2521665 15268894 0
      DownloadManager.writeTmpBytes(list[0].fileName);
      predicates.equalTo('downloadId', list[i].downloadId)
      await SqliteHelper.getInstance(this.context).update({
        'status': 0,
        begins: list[i].downloadSize,
      }, predicates)
    }

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

  }

  async onBackground() {

  }
}