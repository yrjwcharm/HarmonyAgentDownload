export enum DownloadStatus {
  COMPLETED = 1, //下载完成
  PAUSE = 0, //暂停
  // RESUME = 4, //恢复下载
  FAILED = -1, //下载失败
  RUNNING = 2, //下载进行中
  NO_START = 3 //待下载

}