import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import SqliteHelper from '../db/SqliteHelper';
import { PreferencesUtil } from '../utils/PreferencesUtil';


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

  }

  async onBackground() {
    PreferencesUtil.putSync('store',1);
  }
}