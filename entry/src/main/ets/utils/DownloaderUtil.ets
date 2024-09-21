import { request } from '@kit.BasicServicesKit';
import { Log } from '@abner/log';
import { DownloadManager } from '../downloadmanager/DownloadManager';
import { relationalStore, ValuesBucket } from '@kit.ArkData';
import { API_COMMON_INTERFACE } from '../interface/ICommon';


export class DownloaderUtil {
  static deleteTask = async (downloadTask: request.agent.Task) => {
    try {
      downloadTask.off('progress');
      downloadTask.off('completed');
      downloadTask.off('failed');
      await request.agent.remove(downloadTask.tid);
    } catch (err) {
      Log.info(`deleteTask fail, err= ${JSON.stringify(err)}`);
    }
  }

  static async downloadFile(data: API_COMMON_INTERFACE.ICacheCourse | API_COMMON_INTERFACE.IStudyMaterial,
    moduleType: number,
    callback: (downloadSize: number, fileSize: number, status: number, id: string, taskId?: string) => void) {
    let downloadList: API_COMMON_INTERFACE.IPackage[] = [];
    let maxObj: API_COMMON_INTERFACE.IPackage | undefined = undefined;
    if ((data as API_COMMON_INTERFACE.ICacheCourse).playbackList?.length > 0) {
      for (let i = 0; i < (data as API_COMMON_INTERFACE.ICacheCourse).playbackList.length; i++) {
        let item = (data as API_COMMON_INTERFACE.ICacheCourse).playbackList[i];
        if (item.imPackage.url && item.playbackImg && item.videoPackage.url) {
          downloadList.push({
            url: item.imPackage.url,
            size: item.imPackage.size,
            playbackName: item.playbackName,
            fid: item.fid
          },
            {
              url: item.videoPackage.url,
              size: item.videoPackage.size,
              playbackName: item.playbackName,
              fid: item.fid
            }, {
              url: item.playbackImg, playbackName: item.playbackName,
              fid: item.fid
            })
        }
      }
      let maxSize = Math.max(...downloadList.filter(item => item.size).map(item => parseInt(item.size as string)));
      maxObj = downloadList.find(item => parseInt(item.size as string) === maxSize);
    }
    for (let i = 0; i < downloadList.length; i++) {
      let item = downloadList[i];
      let downloadConfig: request.agent.Config = {
        action: request.agent.Action.DOWNLOAD,
        url: item.url,
        mode: request.agent.Mode.FOREGROUND,
        retry: true,
        network: request.agent.Network.ANY,
        saveas: `./`,
        overwrite: true,
        gauge: true,
        priority: 0,
        begins: data.begins ?? 0
      }
      try {
        let downloadTask = await request.agent.create(getContext(), downloadConfig);
        let downloadId = moduleType === 1 ? (data as API_COMMON_INTERFACE.ICacheCourse).clazzLessonNumber :
        (data as API_COMMON_INTERFACE.IStudyMaterial).entityNumber
        let fileName = item.url.substring(item.url.lastIndexOf('/') + 1);
        let valuesBuket: ValuesBucket = {
          'userId': data.userId,
          'taskId': downloadTask.tid, //必传
          'downloadId': downloadId, //必传
          'url': item.url, //必传
          'filePath': './',
          'fileName': fileName,
          "begins": data.begins ?? 0
        }
        let predicates: relationalStore.RdbPredicates | undefined = undefined;
        if (moduleType == 1) { //缓存课程
          let dataSource = data as API_COMMON_INTERFACE.ICacheCourse;
          valuesBuket.playbackList = JSON.stringify(dataSource.playbackList);
          valuesBuket.bigRoomId = dataSource.bigRoomId;
          valuesBuket.subRoomId = dataSource.subRoomId;
          valuesBuket.version = dataSource.version;
          valuesBuket.subClazzNumber = dataSource.subClazzNumber;
          valuesBuket.property = dataSource.property;
          valuesBuket.roomType = dataSource.roomType;
          valuesBuket.layoutType = dataSource.layoutType;
          valuesBuket.layoutTypeV2 = dataSource.layoutTypeV2;
          valuesBuket.flexiblySwitchGreyFlag = dataSource.flexiblySwitchGreyFlag;
          valuesBuket.clazzLessonNumber = dataSource.clazzLessonNumber;
          valuesBuket.clazzLessonName = dataSource.clazzLessonName;
          valuesBuket.clazzLessonTagDesc = dataSource.clazzLessonTagDesc;
          valuesBuket.clazzNumber = dataSource.clazzNumber;
          valuesBuket.clazzName = dataSource.clazzName;
          predicates = new relationalStore.RdbPredicates('cachecourse');
          predicates.equalTo('downloadId', (data as API_COMMON_INTERFACE.ICacheCourse).clazzLessonNumber)
        } else {
          let dataSource = data as API_COMMON_INTERFACE.IStudyMaterial;
          valuesBuket.entityNumber = dataSource.entityNumber;
          valuesBuket.parentNumber = dataSource.parentNumber;
          valuesBuket.rootNumber = dataSource.rootNumber;
          valuesBuket.name = dataSource.name;
          valuesBuket.entityType = dataSource.entityType;
          valuesBuket.fileSizeStr = dataSource.fileSizeStr;
          //学习资料
          predicates = new relationalStore.RdbPredicates('studymaterial');
          predicates.equalTo('downloadId', (data as API_COMMON_INTERFACE.IStudyMaterial).entityNumber)
        }
        let progressCallback = (progress: request.agent.Progress) => {
          DownloadManager
            .progressCallback(moduleType, valuesBuket, progress, downloadTask,
              predicates as relationalStore.RdbPredicates, item, maxObj,
              callback);
        }
        let completedCallback = (progress: request.agent.Progress) => {
          DownloadManager
            .completedCallback(moduleType, valuesBuket, progress, downloadTask,
              predicates as relationalStore.RdbPredicates, item, maxObj,
              callback);
        };
        let pauseCallback = (progress: request.agent.Progress) => {
          DownloadManager
            .pausedCallback(moduleType, valuesBuket, progress, downloadTask,
              predicates as relationalStore.RdbPredicates, callback);

        }
        let failedCallback = (progress: request.agent.Progress) => {
          DownloadManager
            .failedCallback(moduleType, valuesBuket, progress, downloadTask,
              predicates as relationalStore.RdbPredicates, callback);
        }
        //四种状态
        downloadTask.on('progress', progressCallback)
        downloadTask.on('completed', completedCallback);
        downloadTask.on('pause', pauseCallback);
        downloadTask.on('failed', failedCallback)
        await downloadTask.start();
      } catch (err) {
        Log.error(`task  err, err  = ${JSON.stringify(err)}`);
      }
    }
  }
}