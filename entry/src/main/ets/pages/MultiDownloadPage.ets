import { API_COMMON_INTERFACE } from '../interface/ICommon';
import { DownloaderUtil } from '../utils/DownloaderUtil';

@Entry
@Component
struct MultiFileDownload {
  @State statusText: string = '下载'
  @State taskId: string = '';
  @State dataSource: API_COMMON_INTERFACE.ICacheCourse = {
    "playbackList": [{
      "imPackage": {
        "size": "11354",
        "url": "https://d.wenzaizhibo.com/video-signal/8faf40a3a4bb4aa80143aeaa8acea31a/group/0/0.tar.gz?OSSAccessKeyId\u003dLTAI4G97E1JngXNN8WxsY4FN\u0026Expires\u003d1726839797\u0026Signature\u003dRWCQvCYK%2FdyBfg2cj3VSLY%2Fdvfs%3D"
      },
      "videoPackage": {
        "size": "31648774",
        "url": "http://dtx-video.wenzaizhibo.com/84ef28687d5bdca76eab4c0efbe251c7/66ed7bf6/00-x-upload/video/205840692_4c4e46d043eac57b6be22ba5e9335c55_bgYzATsO_mp4/205840692_4c4e46d043eac57b6be22ba5e9335c55_bgYzATsO_f.wz1"
      },
      "roomId": "62091504722899810",
      "sessionId": 1,
      "playbackName": "课前回放",
      "duration": 786,
      "playbackImg": "https://imgs.genshuixue.com/00-x-upload/snapshot/205840692/00001.jpg",
      "fid": "205840692"
    }, {
      "imPackage": {
        "size": "35174",
        "url": "https://d.wenzaizhibo.com/video-signal/283434793034a2dba4e51da34ca2dfa9/group/40104303/40104303.tar.gz?OSSAccessKeyId\u003dLTAI4G97E1JngXNN8WxsY4FN\u0026Expires\u003d1726839798\u0026Signature\u003d0KZQ%2BRW80tbD%2Faku27FEfO49%2Bp0%3D"
      },
      "videoPackage": {
        "size": "270549967",
        "url": "http://dtx-video.wenzaizhibo.com/32ed2ce150acfe18de83faaaa658f052/66ed7bf6/00-x-upload/video/205840151_2b392743e048075be8176a3fb4919b51_98OW3z8r_mp4/205840151_2b392743e048075be8176a3fb4919b51_98OW3z8r_f.wz1"
      },
      "roomId": "6209080866069850",
      "sessionId": 0,
      "playbackName": "课中回放",
      "duration": 5884,
      "playbackImg": "https://imgs.genshuixue.com/00-x-upload/snapshot/205840151/00001.jpg",
      "fid": "205840151"
    }],
    "bigRoomId": "6209080866069850",
    "subRoomId": "62091504722899810",
    "version": "v2",
    "subClazzNumber": "19680276488520064",
    "property": "0",
    "roomType": 0,
    "layoutType": 1,
    "layoutTypeV2": 1,
    "flexiblySwitchGreyFlag": false,
    "clazzLessonNumber": "9801550417103232",
    "clazzLessonName": "围棋初识：基本规则和吃子游戏",
    "clazzLessonTagDesc": "第1讲",
    "clazzNumber": "9801550416710016",
    "clazzName": "1-4年级 围棋课-提升孩子专注力，培养全局思维",
    userId: '1'
  }

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
    // let predicates = new relationalStore.RdbPredicates('downloadinfo');
    // let list = await SqliteHelper.getInstance(getContext()).queryData(predicates);
    // list.forEach(obj => {
    //   this.downloadList?.forEach((item) => {
    //     if (item.id === obj.downloadId) {
    //       item.pro = Math.trunc(obj.downloadSize * 100 / obj.fileSize);
    //       item.status = obj.status;
    //       item.begins = obj.downloadSize;
    //     }
    //   })
    // })
    // this.downloadList = [...this.downloadList];
  }

  build() {
    Column() {
      Button('下载').onClick((event: ClickEvent) => {
        DownloaderUtil.downloadFile(this.dataSource, 1, (downloadSize, fileSize, status, id, taskId) => {

        });
      })
      // List({ space: 12 }) {
      //   ForEach(this.downloadList, (item: IDownload) => {
      //     ListItem() {
      //       Row() {
      //         Column() {
      //           Text(item.url)
      //             .maxLines(2)
      //           Stack({ alignContent: Alignment.Start }) {
      //             Row() {
      //             }.width(item.pro + '%')
      //             .backgroundColor(Color.Red)
      //             .height('100%')
      //             .borderRadius(6)
      //
      //             Text(item.pro + '%')
      //               .fontColor(Color.White).width('100%')
      //               .textAlign(TextAlign.Center)
      //               .fontSize(10)
      //           }
      //           .backgroundColor(Color.Gray)
      //           .height(10)
      //           .borderRadius(6)
      //           .margin({
      //             top: 16
      //           })
      //         }.alignItems(HorizontalAlign.Start)
      //         .layoutWeight(1)
      //
      //         Button(item.status === 2 ? '下载暂停' :
      //           item.status === -1 ? '重新下载' : item.status === 1 ? '下载完成' : '下载')
      //           .type(ButtonType.Normal)
      //           .stateEffect(true)
      //           .borderRadius(2)
      //           .size({
      //             height: 32,
      //           })
      //
      //           .fontColor(Color.White)
      //           .margin({
      //             left: 16
      //           })
      //
      //           .onClick(() => {
      //             // if (item.status === DownloadStatus.NO_START || item.status === DownloadStatus.PAUSE ||
      //             //   item.status === DownloadStatus.FAILED) {
      //             //   DownloaderUtil.downloadFile([item], (downloadSize, fileSize, status, id) => {
      //             //     this.downloadList = this.downloadList.map((item) => {
      //             //       if (item.id == id) {
      //             //         item.pro = Math.trunc(downloadSize * 100 / fileSize);
      //             //         item.status = status;
      //             //       }
      //             //       return item;
      //             //     })
      //             //   });
      //             // }
      //           })
      //       }.width('100%')
      //       .padding(16)
      //       .backgroundColor(Color.White)
      //     }
      //   })
      // }.layoutWeight(1)
      // .margin({
      //   top: 12
      // })
      //
      // Row() {
      //   Button('全部下载').onClick(() => {
      //     // DownloaderUtil.downloadFile(this.downloadList, (proceed, fileSize, status, id) => {
      //     //   this.downloadList = this.downloadList.map((item) => {
      //     //     if (item.id == id) {
      //     //       item.pro = Math.trunc(proceed * 100 / fileSize);
      //     //       item.status = status;
      //     //     }
      //     //     return item;
      //     //   })
      //     // });
      //   }).backgroundColor(Color.Red)
      //   Blank()
      //   Button('查看下载').onClick(() => {
      //
      //     router.pushUrl({
      //       url: 'pages/ReadSqlitePage',
      //     })
      //   }).backgroundColor(Color.Red)
      // }.width('100%')
      // .padding({
      //   left: 16,
      //   right: 16
      // })

    }.width('100%')
    .height('100%')
    .backgroundColor('#f4f4f4')
  }
}