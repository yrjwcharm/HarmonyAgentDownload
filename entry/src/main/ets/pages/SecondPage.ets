import { request } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct SecondPage {
  @State pro: number = 0
  private picUrl: string =
    'https://pics2.baidu.com/feed/902397dda144ad342b90f338f2bb94fa31ad850d.jpeg';

  build() {
    Column() {
      Button('下载文件').onClick((event: ClickEvent) => {
        //多线程去下载文件
        //主线程负责更新进度
        //独一份 不能复写
        let config: request.DownloadConfig = {
          url: this.picUrl,
          title: 'download',
          background: true
        }
        request.downloadFile(getContext(), config).then((task: request.DownloadTask) => {
          //就是后台下载的任务 将网络资源下载到Entry cache里面 并且还对外提供进度
          task.on("progress", (rs, ts) => {
            this.pro = Math.ceil(rs * 100 / ts);
          })
          task.on("complete", () => {
            this.pro = 100;
            promptAction.showToast({
              message: '文件下载完毕'
            })
          })
        })

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