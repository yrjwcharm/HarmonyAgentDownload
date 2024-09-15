import SqliteHelper from '../db/SqliteHelper';
import { relationalStore } from '@kit.ArkData';
import { DownloadInfo } from '../model/DownloadInfo';
import { Logger } from '../utils/Logger';
import { DownloadFileUtil } from '../utils/DownloadFileUtil';
import { request } from '@kit.BasicServicesKit';

@Entry
@Component
struct ReadSqlitePage {
  @State fontColor: string = '#333'
  @State selectedFontColor: string = 'red'
  @State currentIndex: number = 0
  timer = 0;
  @State downloadedList: Array<DownloadInfo> = [];
  @State downloadingList: Array<DownloadInfo> = [];
  private controller: TabsController = new TabsController()

  async aboutToAppear() {
    let predicates = new relationalStore.RdbPredicates('downloadinfo');
    predicates.equalTo('userID', '1');
    this.timer = setInterval(async () => {
      let list = await SqliteHelper.getInstance(getContext()).queryData(predicates)
      this.downloadedList = list.filter(item => item.status == 1);
      this.downloadingList = list.filter(item => item.status == 2 || item.status == 0);
    }, 150)
  }

  aboutToDisappear(): void {
    this.timer && clearTimeout(this.timer);
  }

  @Builder
  tabBuilder(index: number, name: string) {
    Column() {
      Text(name)
        .fontColor(this.currentIndex === index ? this.selectedFontColor : this.fontColor)
        .fontSize(16)
        .fontWeight(this.currentIndex === index ? 500 : 400)
        .lineHeight(22)
        .margin({ top: 17, bottom: 7 })
      Divider()
        .strokeWidth(2)
        .color(Color.Red)
        .opacity(this.currentIndex === index ? 1 : 0)
    }.width('100%')
  }

  onPageShow(): void {

  }

  build() {
    Tabs({ barPosition: BarPosition.Start, index: this.currentIndex, controller: this.controller }) {
      TabContent() {
        Column() {
          List({ space: 12 }) {
            ForEach(this.downloadedList, ((item: DownloadInfo) => {
              ListItem() {
                Row() {
                  Text(item.url.substring(item.url.lastIndexOf('/') + 1)).maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis }).layoutWeight(1)
                  Stack({ alignContent: Alignment.Start }) {
                    Row() {
                    }.width(Math.ceil(item.downloadSize * 100 / item.fileSize) + '%')
                    .backgroundColor(Color.Red)
                    .height('100%')
                    .borderRadius(6)

                    Text(Math.ceil(item.downloadSize * 100 / item.fileSize) + '%')
                      .fontColor(Color.White).width('100%')
                      .textAlign(TextAlign.Center)
                      .fontSize(10)
                  }
                  .backgroundColor(Color.Gray)
                  .height(10)
                  .layoutWeight(1)
                  .borderRadius(6)

                  Text((+item.status === 3 ? '已暂停' : +item.status === 1 ? '已完成' :
                    +item.status === 2 ? '下载中' : item.status === 1 ? '下载失败' : '待下载'))
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .layoutWeight(1)
                    .textAlign(TextAlign.End)
                    .fontColor(Color.Red)
                    .margin({
                      left: 16
                    })
                }.width('100%')
                .height(48)
                .backgroundColor(Color.White)
                .padding({
                  left: 16,
                  right: 16
                })
              }
            }))
          }

        }.width('100%').height('100%')
      }.tabBar(this.tabBuilder(0, '已下载'))

      TabContent() {
        Column() {
          List({ space: 12 }) {
            ForEach(this.downloadingList, ((item: DownloadInfo) => {
              ListItem() {
                Row() {
                  Text(item.url).maxLines(2)
                    .layoutWeight(1)
                  Stack({ alignContent: Alignment.Start }) {
                    Row() {
                    }.width(Math.ceil(item.downloadSize * 100 / item.fileSize) + '%')
                    .backgroundColor(Color.Red)
                    .height('100%')
                    .borderRadius(6)

                    Text(Math.ceil(item.downloadSize * 100 / item.fileSize) + '%')
                      .fontColor(Color.White).width('100%')
                      .textAlign(TextAlign.Center)
                      .fontSize(10)
                  }
                  .backgroundColor(Color.Gray)
                  .height(10)
                  .layoutWeight(1)
                  .borderRadius(6)

                  Text((+item.status === 0 ? '已暂停' : +item.status === 1 ? '已完成' :
                    +item.status === 2 ? '下载中' : '下载失败'))
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .layoutWeight(1)
                    .textAlign(TextAlign.End)
                    .fontColor(Color.Red)
                    .margin({
                      left: 16
                    })
                }.width('100%')
                .height(48)
                .backgroundColor(Color.White)
                .padding({
                  left: 16,
                  right: 16
                })
              }.onClick(async () => {
                try {
                  if (item.status === 2) {
                    const taskObj = await request.agent.getTask(getContext(), item.taskId)
                    taskObj.pause();
                  } else if (item.status === 0) {
                    DownloadFileUtil.downloadFile([{
                      id: item.downloadId,
                      url: item.url,
                      // title:
                      status: item.status,
                      begins: item.begins,
                    }], (downloadSize, fileSize, status, i) => {

                    })

                  }
                } catch (e) {
                  Logger.init({
                    tag: '异常',
                  })
                  Logger.debug(e);
                }
              })
            }))
          }

        }.width('100%').height('100%')
      }.tabBar(this.tabBuilder(1, '下载中'))

    }
    .vertical(false)
    .barMode(BarMode.Fixed)
    .barWidth(360)
    .barHeight(56)
    .animationDuration(400)
    .onChange((index: number) => {
      this.currentIndex = index
    })
    .width('100%')
    .height('100%')
    .backgroundColor('#f4f5f6')
  }
}