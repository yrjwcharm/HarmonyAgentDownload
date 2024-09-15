import { MessageEvents, worker } from '@kit.ArkTS';
import SqliteHelper from '../db/SqliteHelper';

const downloadWorker = new worker.ThreadWorker('entry/ets/workers/DownloadWorker.ets')

@Entry
@Component
export struct Index {
  @State pro: number = 0
  private picUrl = 'https://pics7.baidu.com/feed/42a98226cffc1e1726d3144158c8600d738de93d.jpeg';

  aboutToAppear(): void {
    //得到进度
    downloadWorker.onmessage = (e: MessageEvents) => {
      this.pro = e.data.pro;
    }
    SqliteHelper.getInstance(getContext()).insert('downloadinfo', {
      'userID': 1,
      'taskID': 1,
      'url': 1,
      'filePath': 1,
      'fileSize': 1,
      'downLoadSize': 1,
      'status': 1
    })
  }

  build() {
    Column() {
      Button('下载文件').onClick((event: ClickEvent) => {
        //多线程去下载文件
        //主线程负责更新进度
        // download(this.picUrl, getContext().filesDir, (progress) => {
        //   this.pro = progress;
        // })
        //独一份 不能复写
        downloadWorker.postMessage({ uri: this.picUrl, dir: getContext().filesDir })

      }).alignSelf(ItemAlign.Start)

      Stack() {
        Progress({
          value: this.pro,
          total: 100,
          type: ProgressType.Capsule
        })
          .size({
            width: '80%',
            height: 20
          })
          .color(Color.Red)
          .backgroundColor(Color.Gray)
        Text(this.pro + '%')
          .fontColor(Color.White)
      }.width('100%')
      .margin({
        top: 30
      })
    }
  }
}

