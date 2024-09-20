import { request } from '@kit.BasicServicesKit';
import { relationalStore, ValuesBucket } from '@kit.ArkData';
import SqliteHelper from '../db/SqliteHelper';
import { DownloadStatus } from '../constants/DownloadStatus';
import { promptAction } from '@kit.ArkUI';
import { fileIo } from '@kit.CoreFileKit';
import { DownloaderUtil } from '../utils/DownloaderUtil';

export class DownloadManager {
  private static instance: DownloadManager;

  public static getInstance() {
    if (!DownloadManager.instance) {
      DownloadManager.instance = new DownloadManager();
    }
    return DownloadManager.instance;
  }

  //视频文件下载读取字节数据、然后给目标临时文件tmp写入数据
  public static readFileBytes(srcPath: string, dstPath: string, callback?: (bytes: number) => void) {
    if (fileIo.accessSync(srcPath)) {
      //读取数据
      let file = fileIo.openSync(srcPath, fileIo.OpenMode.READ_WRITE);
      let buf = new ArrayBuffer(fileIo.statSync(file.fd).size);
      fileIo.readSync(file.fd, buf);
      fileIo.closeSync(file);
      //写入数据
      try {
        let file0 =
          fileIo.openSync(dstPath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.APPEND);
        let writeLen = fileIo.writeSync(file0.fd, buf);
        console.info("write data to file succeed and size is:" + writeLen);
        callback && callback(writeLen);
        fileIo.closeSync(file0);
      } catch (e) {
      }
    }
  }

  //下载完成后删除临时文件
  public static deleteTmpFile(context: Context, fileName: string) {
    let srcPath = context.cacheDir + "/" + fileName;
    let dstPath = context.cacheDir + "/tmp/" + fileName;
    if (fileIo.accessSync(dstPath)) {
      DownloadManager.readFileBytes(srcPath, dstPath);
      fileIo.copyFileSync(dstPath, srcPath);
      fileIo.rmdirSync(dstPath)
    }
  }

  //把下载的视频字节数存储到临时文件夹下面
  public static writeTmpBytes(context: Context, fileName: string, callback?: (bytes: number) => void) {
    try {
      let srcPath = context.cacheDir + "/" + fileName;
      let dstPath = context.cacheDir + "/tmp";
      if (!fileIo.accessSync(dstPath)) {
        fileIo.mkdirSync(dstPath);
      }
      //a+：以附加方式打开可读写的文件。若文件不存在，则会建立该文件，
      // 如果文件存在，写入的数据会被加到文件尾后，即文件原先的内容会被保留。
      dstPath = dstPath + '/' + fileName
      let stream = fileIo.createStreamSync(dstPath, "a+");
      stream.closeSync();
      DownloadManager.readFileBytes(srcPath, dstPath, callback);
    } catch (e) {
      console.log('异常信息', e);
    }
  }

  public async progressCallback(valuesBuket: ValuesBucket, progress: request.agent.Progress,
    downloadTask: request.agent.Task,
    predicates: relationalStore.RdbPredicates,
    callback: (proceed: number, fileSize: number, status: number, id: string, taskId?: string) => void) {
    if (progress.sizes[0] > -1) {
      valuesBuket.fileSize = progress.sizes[0] + (valuesBuket.begins as number);
      valuesBuket.downloadSize = progress.processed + (valuesBuket.begins as number);
      valuesBuket.status = DownloadStatus.RUNNING;
      console.log('进度更新...', valuesBuket.downloadSize, valuesBuket.fileSize, valuesBuket.begins)
      //判断当前下载任务是否已经在数据库中
      let list = await SqliteHelper.getInstance(getContext()).queryData(predicates);
      try {
        if (list.length > 0) {
          await SqliteHelper.getInstance(getContext()).update(valuesBuket, predicates);
        } else {
          await SqliteHelper.getInstance(getContext()).insert('downloadinfo', valuesBuket);
        }
      } catch (e) {
        console.log(e.message)
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
      DownloadManager.deleteTmpFile(getContext(), valuesBuket.fileName as string);
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
      valuesBuket.begins = progress.processed + (valuesBuket.begins as number);
      valuesBuket.status = DownloadStatus.PAUSE;
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