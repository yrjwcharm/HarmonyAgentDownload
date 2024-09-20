import { router } from '@kit.ArkUI';
import SqliteHelper from '../db/SqliteHelper';
import { DownloaderUtil, IDownload } from '../utils/DownloaderUtil';
import { relationalStore } from '@kit.ArkData';
import { DownloadStatus } from '../constants/DownloadStatus';

@Entry
@Component
struct MultiFileDownload {
  @State statusText: string = '下载'
  @State taskId: string = '';
  @State downloadList: IDownload[] = [
    {
      id: '1',
      title: '你知道冬天的雪是什么颜色吗, 我猜你不知道',
      url: 'https://vd4.bdstatic.com/mda-pku9q3zt0rzybip0/hd/cae_h264/1701381974031001593/mda-pku9q3zt0rzybip0.mp4',
      moduleType: 2,
      pro: 0,
      status: 3,
      begins: 0
    },
    {
      id: '2',
      title: '宝子们，我当众社死了，我竟然在众目睽睽之下完成了自己人生中的第一段程序',
      url: 'https://vd2.bdstatic.com/mda-pkkf9qb7zksdaqs9/576p/h264/1700564765354260319/mda-pkkf9qb7zksdaqs9.mp4',
      moduleType: 2,
      pro: 0,
      begins: 0,
      status: 3,
    },
    {
      id: '3',
      title: '其实老高最爱的是文学，可以在寂静的夜用曼妙的文字勾勒出关于人生，职场，感情的诸多情绪，无奈此生当为程序员',
      url: 'https://vd2.bdstatic.com/mda-pj8qa65bc9r1v1cf/576p/h264/1696871444324088416/mda-pj8qa65bc9r1v1cf.mp4',
      moduleType: 1,
      pro: 0,
      begins: 0,
      status: 3,
    }

  ]

  async aboutToAppear() {
    this.initData();
    getContext().eventHub.on('trigger', () => {
      this.initData();
    })
  }

  aboutToDisappear(): void {
    getContext().eventHub.off('trigger')
  }

  async initData() {
    let predicates = new relationalStore.RdbPredicates('downloadinfo');
    let list = await SqliteHelper.getInstance(getContext()).queryData(predicates);
    list.forEach(obj => {
      this.downloadList?.forEach((item) => {
        if (item.id === obj.downloadId) {
          item.pro = Math.trunc(obj.downloadSize * 100 / obj.fileSize);
          item.status = obj.status;
          item.begins = obj.downloadSize;
        }
      })
    })
    this.downloadList = [...this.downloadList];
  }

  build() {
    Column() {
      List({ space: 12 }) {
        ForEach(this.downloadList, (item: IDownload) => {
          ListItem() {
            Row() {
              Column() {
                Text(item.url)
                  .maxLines(2)
                Stack({ alignContent: Alignment.Start }) {
                  Row() {
                  }.width(item.pro + '%')
                  .backgroundColor(Color.Red)
                  .height('100%')
                  .borderRadius(6)

                  Text(item.pro + '%')
                    .fontColor(Color.White).width('100%')
                    .textAlign(TextAlign.Center)
                    .fontSize(10)
                }
                .backgroundColor(Color.Gray)
                .height(10)
                .borderRadius(6)
                .margin({
                  top: 16
                })
              }.alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Button(item.status === 2 ? '下载暂停' :
                item.status === -1 ? '重新下载' : item.status === 1 ? '下载完成' : '下载')
                .type(ButtonType.Normal)
                .stateEffect(true)
                .borderRadius(2)
                .size({
                  height: 32,
                })

                .fontColor(Color.White)
                .margin({
                  left: 16
                })

                .onClick(() => {
                  if (item.status === DownloadStatus.NO_START || item.status === DownloadStatus.PAUSE ||
                    item.status === DownloadStatus.FAILED) {
                    DownloaderUtil.downloadFile([item], (downloadSize, fileSize, status, id) => {
                      this.downloadList = this.downloadList.map((item) => {
                        if (item.id == id) {
                          item.pro = Math.trunc(downloadSize * 100 / fileSize);
                          item.status = status;
                        }
                        return item;
                      })
                    });
                  }
                })
            }.width('100%')
            .padding(16)
            .backgroundColor(Color.White)
          }
        })
      }.layoutWeight(1)
      .margin({
        top: 12
      })

      Row() {
        Button('全部下载').onClick(() => {
          DownloaderUtil.downloadFile(this.downloadList, (proceed, fileSize, status, id) => {
            this.downloadList = this.downloadList.map((item) => {
              if (item.id == id) {
                item.pro = Math.trunc(proceed * 100 / fileSize);
                item.status = status;
              }
              return item;
            })
          });
        }).backgroundColor(Color.Red)
        Blank()
        Button('查看下载').onClick(() => {

          router.pushUrl({
            url: 'pages/ReadSqlitePage',
          })
        }).backgroundColor(Color.Red)
      }.width('100%')
      .padding({
        left: 16,
        right: 16
      })

    }.width('100%')
    .height('100%')
    .backgroundColor('#f4f4f4')
  }
}