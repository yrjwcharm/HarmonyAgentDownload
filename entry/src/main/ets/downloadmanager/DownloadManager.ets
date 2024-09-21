import { request } from '@kit.BasicServicesKit';
import { relationalStore, ValuesBucket } from '@kit.ArkData';
import SqliteHelper from '../db/SqliteHelper';
import { DownloadStatus } from '../constants/DownloadStatus';
import { promptAction } from '@kit.ArkUI';
import { DownloaderUtil } from '../utils/DownloaderUtil';
import { API_COMMON_INTERFACE } from '../interface/ICommon';
import { JSON } from '@kit.ArkTS';
import { FileUtil } from '../utils/FileUtil';

export class DownloadManager {
  private static instance: DownloadManager;

  public static getInstance() {
    if (!DownloadManager.instance) {
      DownloadManager.instance = new DownloadManager();
    }
    return DownloadManager.instance;
  }

  //退出App暂停
  public static async exitAppPause(context: Context) {
    DownloadManager.pauseAllCacheCourse(context, 1);
    DownloadManager.pauseAllCacheCourse(context, 2);
  }

  //暂停所有缓存课程
  public static async pauseAllCacheCourse(context: Context, moduleType: number) {
    let predicates = new relationalStore.RdbPredicates(moduleType === 1 ? 'cachecourse' : 'studymaterial');
    predicates.equalTo('status', 2).or()
    predicates.equalTo('status', 0)
    predicates
    let list = await SqliteHelper.getInstance(context).queryData(predicates)
    for (let i = 0; i < list.length; i++) {
      let predicates = new relationalStore.RdbPredicates(moduleType === 1 ? 'cachecourse' : 'studymaterial');
      await request.agent.remove(list[i].taskId);
      predicates.equalTo('downloadId', list[i].downloadId)
      FileUtil.writeTmpBytes(context, list[i].fileName, async bytes => {
        await SqliteHelper.getInstance(context).update({
          'status': 0,
          begins: bytes,
        }, predicates)
      })
    }
  }


  public static getPackage(fileName: string, item: API_COMMON_INTERFACE.IPackage) {
    let imPackageUrl = '', videoPackageUrl = '', playbackImg = '';
    if (fileName.indexOf('.jpg') != -1) {
      playbackImg = fileName;
    } else if (fileName.indexOf('.wz1"') != -1) {
      videoPackageUrl = fileName
    } else {
      imPackageUrl = fileName
    }
    let package_1: API_COMMON_INTERFACE.IPackage_1 = {
      fid: item.fid as string,
      imPackageUrl,
      videoPackageUrl,
      playbackImg,
    }
    return package_1;
  }

  public async progressCallback(moduleType: number, valuesBuket: ValuesBucket, progress: request.agent.Progress,
    downloadTask: request.agent.Task,
    predicates: relationalStore.RdbPredicates,
    item: API_COMMON_INTERFACE.IPackage,
    maxObj: API_COMMON_INTERFACE.IPackage | undefined = undefined,
    callback: (proceed: number, fileSize: number, status: number, id: string, taskId?: string) => void,
  ) {
    if (progress.sizes[0] > -1) {
      valuesBuket.fileSize = progress.sizes[0] + (valuesBuket.begins as number);
      valuesBuket.downloadSize = progress.processed + (valuesBuket.begins as number);
      valuesBuket.status = DownloadStatus.RUNNING;
      //判断当前下载任务是否已经在数据库中
      let list = await SqliteHelper.getInstance(getContext()).queryData(predicates);
      try {
        if (list.length > 0) {
          if (moduleType === 1) {
            let package_1 = DownloadManager.getPackage(valuesBuket.fileName as string, item);
            let firstPackage: API_COMMON_INTERFACE.IPackage_1[] =
              JSON.parse(list[0].playbackUrl) as API_COMMON_INTERFACE.IPackage_1[]
            let urls: API_COMMON_INTERFACE.IPackage_1[] = [...firstPackage, package_1]
            let setArr = new Set(urls.map((item) => JSON.stringify(item)));
            let uniquePlayBackUrl: string[] = [];
            setArr.forEach(item => {
              uniquePlayBackUrl.push(item);
            })
            let newUniqueArr = uniquePlayBackUrl.map(item => JSON.parse(item))
            valuesBuket.playBackUrl = JSON.stringify(newUniqueArr);
          }
          await SqliteHelper.getInstance(getContext()).update(valuesBuket, predicates);
        } else {
          if (moduleType === 1) {
            let package_1 = DownloadManager.getPackage(valuesBuket.fileName as string, item);
            valuesBuket.playBackUrl = JSON.stringify([package_1]);
          }
          await SqliteHelper.getInstance(getContext())
            .insert(moduleType === 1 ? 'cachecourse' : 'studymaterial', valuesBuket);
        }
      } catch (e) {
        console.log(e.message)
      }
      if (moduleType === 1) {
        //缓存课程 以最大下载字节数 走进度
        if (item.url === maxObj?.url) {
          callback(valuesBuket.downloadSize, valuesBuket.fileSize, DownloadStatus.RUNNING,
            valuesBuket.downloadId as string,
            downloadTask.tid)
        }
      } else {
        callback(valuesBuket.downloadSize, valuesBuket.fileSize, DownloadStatus.RUNNING,
          valuesBuket.downloadId as string,
          downloadTask.tid)
      }
    }
  }

  public async completedCallback(moduleType: number, valuesBuket: ValuesBucket, progress: request.agent.Progress,
    downloadTask: request.agent.Task,
    predicates: relationalStore.RdbPredicates,
    item: API_COMMON_INTERFACE.IPackage,
    maxObj: API_COMMON_INTERFACE.IPackage | undefined = undefined,
    callback: (proceed: number, fileSize: number, status: number, id: string, taskId?: string) => void) {
    if (progress.sizes[0] > -1) {
      valuesBuket.fileSize = progress.sizes[0] + (valuesBuket.begins as number)
      valuesBuket.downloadSize = progress.processed + (valuesBuket.begins as number)
      valuesBuket.status = DownloadStatus.COMPLETED;
      await SqliteHelper.getInstance(getContext()).update(valuesBuket, predicates)
      DownloaderUtil.deleteTask(downloadTask);
      FileUtil.deleteTmpFile(getContext(), valuesBuket.fileName as string);
      if (moduleType === 1) {
        if (maxObj?.url === item.url) {
          callback(valuesBuket.downloadSize, valuesBuket.fileSize, DownloadStatus.COMPLETED,
            valuesBuket.downloadId as string,
            downloadTask.tid)
        }
      } else {
        callback(valuesBuket.downloadSize, valuesBuket.fileSize, DownloadStatus.COMPLETED,
          valuesBuket.downloadId as string,
          downloadTask.tid)
      }
    }
  }

  public async pausedCallback(moduleType: number, valuesBuket: ValuesBucket, progress: request.agent.Progress,
    downloadTask: request.agent.Task,
    predicates: relationalStore.RdbPredicates,
    callback: (proceed: number, fileSize: number, status: number, id: string, taskId?: string) => void,) {
    if (progress.sizes[0] > -1) {
      valuesBuket.fileSize = progress.sizes[0] + (valuesBuket.begins as number)
      valuesBuket.downloadSize = progress.processed + (valuesBuket.begins as number)
      valuesBuket.begins = progress.processed + (valuesBuket.begins as number);
      valuesBuket.status = DownloadStatus.PAUSE;
      await SqliteHelper.getInstance(getContext()).update(valuesBuket, predicates)
      callback(valuesBuket.downloadSize, valuesBuket.fileSize, DownloadStatus.PAUSE,
        valuesBuket.downloadId as string,
        downloadTask.tid)
    }
  }

  public async failedCallback(moduleType: number, valuesBuket: ValuesBucket, progress: request.agent.Progress,
    downloadTask: request.agent.Task,
    predicates: relationalStore.RdbPredicates,
    callback: (proceed: number, fileSize: number, status: number, id: string, taskId?: string) => void,
  ) {
    valuesBuket.downloadSize = progress.sizes[0] + (valuesBuket.begins as number);
    let list = await SqliteHelper.getInstance(getContext()).queryData(predicates);
    valuesBuket.fileSize = list[0].fileSize;
    valuesBuket.status = DownloadStatus.FAILED;
    await SqliteHelper.getInstance(getContext()).update(valuesBuket, predicates)
    DownloaderUtil.deleteTask(downloadTask);
    callback(valuesBuket.downloadSize, valuesBuket.fileSize, DownloadStatus.FAILED,
      valuesBuket.downloadId as string,
      downloadTask.tid)
    promptAction.showToast({
      message: "下载失败"
    })
  }
}