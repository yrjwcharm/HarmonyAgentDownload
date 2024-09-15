import { request } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct ThirdPage {
  @State message: string = 'Hello World';
  @State pro: number = 0;
  private downloadUrl = 'https://pics7.baidu.com/feed/42a98226cffc1e1726d3144158c8600d738de93d.jpeg';
  config: request.agent.Config = {
    action: request.agent.Action.DOWNLOAD,
    url: this.downloadUrl,
    mode: request.agent.Mode.BACKGROUND,
    network: request.agent.Network.WIFI,
    overwrite: true,
    saveas: './',
    retry: true

  }
  private taskId: string = '';

  async onPageShow() {

    let task = await request.agent.create(getContext(), this.config);
    task.on('progress', (progress: request.agent.Progress) => {
      this.pro = Math.ceil(progress.processed * 100 / progress.sizes[0]);
    })
    task.on("completed", () => {
      this.pro = 100;
      promptAction.showToast({
        message: '下载完毕'
      })
    })
    this.taskId = task.tid;
  }

  build() {
    Column() {
      Button('下载文件').onClick(async (event: ClickEvent) => {
        //多线程去下载文件
        const taskObj = await request.agent.getTask(getContext(), this.taskId);
        taskObj.start();
      }).alignSelf(ItemAlign.Start)
      Button('暂停').onClick(async (event: ClickEvent) => {
        //多线程去下载文件
        const taskObj = await request.agent.getTask(getContext(), this.taskId);
        taskObj.pause();
      }).alignSelf(ItemAlign.Start)
      Button('继续').onClick(async (event: ClickEvent) => {
        //多线程去下载文件
        const taskObj = await request.agent.getTask(getContext(), this.taskId);
        taskObj.resume();
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