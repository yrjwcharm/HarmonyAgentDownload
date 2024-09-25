import fileIo from '@ohos.file.fs';

/**
 * TODO 文件操作相关工具类
 */
export class FileUtil {
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
      FileUtil.readFileBytes(srcPath, dstPath);
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
      FileUtil.readFileBytes(srcPath, dstPath, callback);
    } catch (e) {
      console.log('异常信息', e);
    }
  }
}
