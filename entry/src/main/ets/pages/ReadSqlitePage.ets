import { relationalStore } from '@kit.ArkData';
import SqliteHelper from '../db/SqliteHelper';
import { API_COMMON_INTERFACE } from '../interface/ICommon';
import { CacheCourse } from '../model/CacheCourse';
import { fileIo } from '@kit.CoreFileKit';
import { List } from '@kit.ArkTS';

@Entry
@Component
struct ReadSqlitePage {
  @State fontColor: string = '#333'
  @State selectedFontColor: string = 'red'
  @State currentIndex: number = 0
  timer = 0;
  @State downloadedList: Array<CacheCourse> = [];
  @State downloadingList: Array<CacheCourse> = [];
  private controller: TabsController = new TabsController()

  async aboutToAppear() {

  }

  //查询课程
  queryCacheCourseList(userId: string): Promise<API_COMMON_INTERFACE.ICacheCourse[]> {
    let predicates = new relationalStore.RdbPredicates('cachecourse');
    predicates.equalTo('userId', userId);
    return SqliteHelper.getInstance(getContext()).queryCacheCourseData(predicates);
  }

  //根据课程id删除课程
  async delCacheCourseListByClazzNumber(userId: string, clazzNumber: string): Promise<number> {
    let predicates = new relationalStore.RdbPredicates('cachecourse');
    predicates.equalTo('userId', userId);
    predicates.equalTo('clazzNumber', clazzNumber);
    let list = await SqliteHelper.getInstance(getContext()).queryCacheCourseData(predicates);
    list.forEach(item => {
      const path = item.filePath + '/' + item.downloadId
      fileIo.rmdirSync(path)
    })
    return SqliteHelper.getInstance(getContext()).deleteData(predicates);
  }

  //根据课节id删除缓存课节
  async delCacheCourseListByClazzLessonNumber(userId: string, clazzLessonNumbers: List<string>): Promise<number> {
    return new Promise(async (resolve, reject) => {
      try {
        for (let i = 0; i < clazzLessonNumbers.length; i++) {
          let predicates = new relationalStore.RdbPredicates('cachecourse');
          predicates.equalTo('userId', userId);
          predicates.equalTo('clazzNumber', clazzLessonNumbers[i]);
          let list = await SqliteHelper.getInstance(getContext()).queryCacheCourseData(predicates);
          fileIo.rmdirSync(list[0]?.filePath + '/' + list[0]?.downloadId)
          await SqliteHelper.getInstance(getContext()).deleteData(predicates);
        }
        resolve(1);
      } catch (e) {
        reject(0);
      }
    })
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
          // List({ space: 12 }) {
          //   ForEach(this.downloadedList, ((item: CacheCourse) => {
          //     ListItem() {
          //       Row() {
          //         Text(item.url.substring(item.url.lastIndexOf('/') + 1)).maxLines(2)
          //           .textOverflow({ overflow: TextOverflow.Ellipsis }).layoutWeight(1)
          //         Stack({ alignContent: Alignment.Start }) {
          //           Row() {
          //           }.width(Math.ceil(item.downloadSize * 100 / item.fileSize) + '%')
          //           .backgroundColor(Color.Red)
          //           .height('100%')
          //           .borderRadius(6)
          //
          //           Text(Math.ceil(item.downloadSize * 100 / item.fileSize) + '%')
          //             .fontColor(Color.White).width('100%')
          //             .textAlign(TextAlign.Center)
          //             .fontSize(10)
          //         }
          //         .backgroundColor(Color.Gray)
          //         .height(10)
          //         .layoutWeight(1)
          //         .borderRadius(6)
          //
          //         Text((+item.status === 3 ? '已暂停' : +item.status === 1 ? '已完成' :
          //           +item.status === 2 ? '下载中' : item.status === 1 ? '下载失败' : '待下载'))
          //           .maxLines(2)
          //           .textOverflow({ overflow: TextOverflow.Ellipsis })
          //           .layoutWeight(1)
          //           .textAlign(TextAlign.End)
          //           .fontColor(Color.Red)
          //           .margin({
          //             left: 16
          //           })
          //       }.width('100%')
          //       .height(48)
          //       .backgroundColor(Color.White)
          //       .padding({
          //         left: 16,
          //         right: 16
          //       })
          //     }
          //   }))
          // }

        }.width('100%').height('100%')
      }.tabBar(this.tabBuilder(0, '已下载'))

      TabContent() {
        Column() {
          // List({ space: 12 }) {
          //   ForEach(this.downloadingList, ((item: DownloadInfo) => {
          //     ListItem() {
          //       Row() {
          //         Text(item.url).maxLines(2)
          //           .layoutWeight(1)
          //         Stack({ alignContent: Alignment.Start }) {
          //           Row() {
          //           }.width(Math.ceil(item.downloadSize * 100 / item.fileSize) + '%')
          //           .backgroundColor(Color.Red)
          //           .height('100%')
          //           .borderRadius(6)
          //
          //           Text(Math.ceil(item.downloadSize * 100 / item.fileSize) + '%')
          //             .fontColor(Color.White).width('100%')
          //             .textAlign(TextAlign.Center)
          //             .fontSize(10)
          //         }
          //         .backgroundColor(Color.Gray)
          //         .height(10)
          //         .layoutWeight(1)
          //         .borderRadius(6)
          //
          //         Text((+item.status === 0 ? '已暂停' : +item.status === 1 ? '已完成' :
          //           +item.status === 2 ? '下载中' : '下载失败'))
          //           .maxLines(2)
          //           .textOverflow({ overflow: TextOverflow.Ellipsis })
          //           .layoutWeight(1)
          //           .textAlign(TextAlign.End)
          //           .fontColor(Color.Red)
          //           .margin({
          //             left: 16
          //           })
          //       }.width('100%')
          //       .height(48)
          //       .backgroundColor(Color.White)
          //       .padding({
          //         left: 16,
          //         right: 16
          //       })
          //     }.onClick(async () => {
          //       if (item.status === 2) {
          //         DownloaderUtil.pause(item.taskId);
          //
          //       } else if (item.status === 0) {
          //
          //         try {
          //           const taskObj = await request.agent.getTask(getContext(), item.taskId);
          //           if (taskObj.config.ends === -1) {
          //             // DownloaderUtil.downloadFile([{
          //             //   id: item.downloadId,
          //             //   url: item.url,
          //             //   // title:
          //             //   status: item.status,
          //             //   begins: item.begins ?? 0,
          //             // }], (downloadSize, fileSize, status, i) => {
          //             //   getContext().eventHub.emit('trigger', true);
          //             // })
          //           } else {
          //             await taskObj.resume()
          //
          //           }
          //         } catch (e) {
          //
          //         }
          //
          //       }
          //
          //     })
          //   }))
          // }

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