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
    let list = await SqliteHelper.getInstance(context).queryData(predicates, moduleType)
    for (let i = 0; i < list.length; i++) {
      let predicates = new relationalStore.RdbPredicates(moduleType === 1 ? 'cachecourse' : 'studymaterial');
      await request.agent.remove(list[i].taskId);
      predicates.equalTo('downloadId', list[i].downloadId)
      FileUtil.writeTmpBytes(context, list[i].downloadId + '/' + list[i].fileName, async bytes => {
        await SqliteHelper.getInstance(context).update({
          'status': 0,
          begins: bytes,
        }, predicates)
      })
    }
  }

  //去除对象数组中相同fid 对应资源包非空属性值、并进行统一合并
  public static mergedObj(data: API_COMMON_INTERFACE.IFidPackage[]) {
    // 使用Map来存储合并后的数据
    const mergedData: Map<string, API_COMMON_INTERFACE.IFidPackage> = new Map();
    data.forEach(entry => {
      const fid = entry.fid;
      const imPackageUrl = entry.imPackageUrl;
      const videoPackageUrl = entry.videoPackageUrl;
      const playbackImg = entry.playbackImg;
      // 如果该fid还没有对应的条目，则初始化一个
      if (!mergedData.has(fid)) {
        mergedData.set(fid, {
          fid,
          imPackageUrl: "",
          videoPackageUrl: "",
          playbackImg: ""
        });
      }
      // 合并非空属性
      const existingEntry = mergedData.get(fid) as API_COMMON_INTERFACE.IFidPackage;
      if (imPackageUrl) {
        existingEntry.imPackageUrl = imPackageUrl;
      }
      if (videoPackageUrl) {
        existingEntry.videoPackageUrl = videoPackageUrl;
      }
      if (playbackImg) {
        existingEntry.playbackImg = playbackImg;
      }
    });
    const result = Array.from(mergedData.values());
    return result;
  }

  //重组资源包链接
  public static getPackage(fileName: string, item: API_COMMON_INTERFACE.IPackage) {
    let imPackageUrl = '', videoPackageUrl = '', playbackImg = '';
    if (fileName.lastIndexOf('.jpg') != -1) {
      playbackImg = fileName;
    } else if (fileName.lastIndexOf('.mp4') != -1) {
      videoPackageUrl = fileName
    } else {
      imPackageUrl = fileName
    }
    let fidPackage: API_COMMON_INTERFACE.IFidPackage = {
      fid: item.fid as string,
      imPackageUrl,
      videoPackageUrl,
      playbackImg,
    }
    return fidPackage;
  }

  //进度监听
  public static async progressCallback(moduleType: number, valuesBuket: ValuesBucket, progress: request.agent.Progress,
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
      let list = await SqliteHelper.getInstance(getContext()).queryData(predicates, moduleType);
      try {
        if (list.length > 0) {
          if (moduleType === 1) {
            //缓存课程逻辑
            let fidPackage = DownloadManager.getPackage(valuesBuket.fileName as string, item);
            let firstPackage: API_COMMON_INTERFACE.IFidPackage[] =
              JSON.parse((list[0] as API_COMMON_INTERFACE.ICacheCourse).playbackUrl) as API_COMMON_INTERFACE.IFidPackage[]
            let urls: API_COMMON_INTERFACE.IFidPackage[] = [...firstPackage, fidPackage]
            let setArr = new Set(urls.map((item) => JSON.stringify(item)));
            let uniquePlayBackUrl: string[] = [];
            setArr.forEach(item => {
              uniquePlayBackUrl.push(item);
            })
            let newUniqueArr = uniquePlayBackUrl.map(item => JSON.parse(item)) as API_COMMON_INTERFACE.IFidPackage[];
            let merged = DownloadManager.mergedObj(newUniqueArr);
            valuesBuket.playBackUrl = JSON.stringify(merged);
          }
          await SqliteHelper.getInstance(getContext()).update(valuesBuket, predicates);
        } else {
          if (moduleType === 1) {
            //缓存课程逻辑
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
        //缓存课程 以最大fileSize字节数显示进度
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

  public static async completedCallback(moduleType: number, valuesBuket: ValuesBucket, progress: request.agent.Progress,
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
      FileUtil.deleteTmpFile(getContext(), valuesBuket.downloadId + '/' + valuesBuket.fileName as string);
      if (moduleType === 1) {
        if (maxObj?.url === item.url) {
          promptAction.showToast({
            message: "下载完成"
          })
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

  public static async pausedCallback(moduleType: number, valuesBuket: ValuesBucket, progress: request.agent.Progress,
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

  public static async failedCallback(moduleType: number, valuesBuket: ValuesBucket, progress: request.agent.Progress,
    downloadTask: request.agent.Task,
    predicates: relationalStore.RdbPredicates,
    callback: (proceed: number, fileSize: number, status: number, id: string, taskId?: string) => void,
  ) {
    valuesBuket.downloadSize = progress.sizes[0] + (valuesBuket.begins as number);
    let list = await SqliteHelper.getInstance(getContext()).queryData(predicates, moduleType);
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