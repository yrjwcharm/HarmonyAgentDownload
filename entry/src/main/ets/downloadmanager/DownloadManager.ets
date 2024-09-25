import { request } from '@kit.BasicServicesKit';
import { relationalStore, ValuesBucket } from '@kit.ArkData';
import SqliteHelper from '../db/SqliteHelper';
import { DownloadStatus } from '../constants/DownloadStatus';
import { promptAction } from '@kit.ArkUI';
import { DownloaderUtil } from '../utils/DownloaderUtil';
import { FileUtil } from '../utils/FileUtil';

export class DownloadManager {
  private static instance: DownloadManager;

  public static getInstance() {
    if (!DownloadManager.instance) {
      DownloadManager.instance = new DownloadManager();
    }
    return DownloadManager.instance;
  }

  public async progressCallback(valuesBuket: ValuesBucket, progress: request.agent.Progress,
    downloadTask: request.agent.Task,
    predicates: relationalStore.RdbPredicates,
    callback: (proceed: number, fileSize: number, status: number, id: string, taskId?: string) => void) {
    if (progress.sizes[0] > -1) {

      valuesBuket.fileSize = progress.sizes[0] + (valuesBuket.begins as number);
      valuesBuket.downloadSize = progress.processed + (valuesBuket.begins as number);
      valuesBuket.status = DownloadStatus.RUNNING;
      //判断当前下载任务是否已经在数据库中
      let list = await SqliteHelper.getInstance(getContext()).queryData(predicates);
      if (list.length > 0) {
        await SqliteHelper.getInstance(getContext()).update(valuesBuket, predicates);
      } else {
        await SqliteHelper.getInstance(getContext()).insert('downloadinfo', valuesBuket);
      }
      callback(valuesBuket.downloadSize, valuesBuket.fileSize, DownloadStatus.RUNNING,
        valuesBuket.downloadId as string,
        downloadTask.tid)
    }
  }

  public async completedCallback(valuesBuket: ValuesBucket, progress: request.agent.Progress,
    downloadTask: request.agent.Task,
    predicates: relationalStore.RdbPredicates,
    callback: (proceed: number, fileSize: number, status: number, id: string, taskId?: string) => void) {
    if (progress.sizes[0] > -1) {
      valuesBuket.fileSize = progress.sizes[0] + (valuesBuket.begins as number)
      valuesBuket.downloadSize = progress.processed + (valuesBuket.begins as number)
      valuesBuket.status = DownloadStatus.COMPLETED;
      await SqliteHelper.getInstance(getContext()).update(valuesBuket, predicates)
      DownloaderUtil.deleteTask(downloadTask);
      promptAction.showToast({
        message: '下载完毕'
      })
      FileUtil.deleteTmpFile(getContext(), valuesBuket.fileName as string);
      callback(valuesBuket.downloadSize, valuesBuket.fileSize, DownloadStatus.COMPLETED,
        valuesBuket.downloadId as string,
        downloadTask.tid)
    }
  }

  public async pausedCallback(valuesBuket: ValuesBucket, progress: request.agent.Progress,
    downloadTask: request.agent.Task,
    predicates: relationalStore.RdbPredicates,
    callback: (proceed: number, fileSize: number, status: number, id: string, taskId?: string) => void,) {
    if (progress.sizes[0] > -1) {
      valuesBuket.fileSize = progress.sizes[0] + (valuesBuket.begins as number)
      valuesBuket.downloadSize = progress.processed + (valuesBuket.begins as number)
      valuesBuket.status = DownloadStatus.PAUSE;
      valuesBuket.begins = progress.processed + (valuesBuket.begins as number);
      await SqliteHelper.getInstance(getContext()).update(valuesBuket, predicates)
      callback(valuesBuket.downloadSize, valuesBuket.fileSize, DownloadStatus.PAUSE,
        valuesBuket.downloadId as string,
        downloadTask.tid)
    }
  }

  public async failedCallback(valuesBuket: ValuesBucket, progress: request.agent.Progress,
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