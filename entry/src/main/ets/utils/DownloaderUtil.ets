import { request } from '@kit.BasicServicesKit';
import { relationalStore, ValuesBucket } from '@kit.ArkData';
import { DownloadManager } from '../downloadmanager/DownloadManager';
import { Log } from '@abner/log';


export interface IDownload {
  url: string;
  id: string;
  pro?: number;
  status?: number;
  begins?: number;
  moduleType?: number;
  title?: string;

}

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

  static async pause(taskId: string) {
    const taskObj = await request.agent.getTask(getContext(), taskId);
    await taskObj.pause();

  }

  static async resume(taskId: string, callback?: (code: number) => void) {
    const taskObj = await request.agent.getTask(getContext(), taskId);
    await taskObj.resume()
  }

  static async downloadFile(downloadList: IDownload[],
    callback: (downloadSize: number, fileSize: number, status: number, id: string, taskId?: string) => void) {
    for (let i = 0; i < downloadList.length; i++) {
      let item = downloadList[i];
      let downloadConfig: request.agent.Config = {
        action: request.agent.Action.DOWNLOAD,
        url: item.url,
        title: item.title,
        mode: request.agent.Mode.FOREGROUND,
        retry: true,
        network: request.agent.Network.ANY,
        saveas: `./`,
        overwrite: true,
        gauge: true,
        priority: 0,
        begins: item.begins ?? 0
      }
      try {
        let downloadTask = await request.agent.create(getContext(), downloadConfig);
        let fileName = item.url.substring(item.url.lastIndexOf('/') + 1);
        let valuesBuket: ValuesBucket = {
          'userID': '1',
          'taskID': downloadTask.tid, //必传
          'url': item.url, //必传
          'filePath': getContext().cacheDir,
          'fileName': fileName,
          'downloadId': item.id, //必传
          'moduleType': 2,
          "begins": item.begins ?? 0
        }
        let predicates = new relationalStore.RdbPredicates('downloadinfo');
        predicates.equalTo('downloadId', item.id);
        let progressCallback = (progress: request.agent.Progress) => {
          DownloadManager.getInstance()
            .progressCallback(valuesBuket, progress, downloadTask, predicates, callback);
        }
        let completedCallback = (progress: request.agent.Progress) => {
          DownloadManager.getInstance()
            .completedCallback(valuesBuket, progress, downloadTask, predicates, callback);
        };
        let pauseCallback = (progress: request.agent.Progress) => {
          DownloadManager.getInstance()
            .pausedCallback(valuesBuket, progress, downloadTask, predicates, callback);

        }
        let failedCallback = (progress: request.agent.Progress) => {
          DownloadManager.getInstance()
            .failedCallback(valuesBuket, progress, downloadTask, predicates, callback);
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