import relationalStore from '@ohos.data.relationalStore';
import { ValuesBucket } from '@ohos.data.ValuesBucket';
import { DownloadInfo } from '../model/DownloadInfo';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from '../utils/Logger';

export default class SqliteHelper {
  private static instance: SqliteHelper
  private static rdbStore: relationalStore.RdbStore | undefined = undefined
  private context: Context

  private constructor(context: Context) {
    this.context = context
  }

  static getInstance(context: Context): SqliteHelper {
    if (!SqliteHelper.instance) {
      SqliteHelper.instance = new SqliteHelper(context)
    }
    return SqliteHelper.instance
  }

  /**
   * 数据库初始化
   * */
  public async initRDB() {
    let downloadInfo = 'downloadinfo';
    const STORE_CONFIG: relationalStore.StoreConfig = {
      name: 'filedownloader.db', // 数据库文件名
      securityLevel: relationalStore.SecurityLevel.S1, // 数据库安全级别
      encrypt: false, // 可选参数，指定数据库是否加密，默认不加密
      // customDir: 'customDir/subCustomDir',
      // 可选参数，数据库自定义路径。数据库将在如下的目录结构中被创建：context.databaseDir + '/rdb/' + customDir，其中context.databaseDir是应用沙箱对应的路径，'/rdb/'表示创建的是关系型数据库，customDir表示自定义的路径。当此参数不填时，默认在本应用沙箱目录下创建RdbStore实例。
      isReadOnly: false // 可选参数，指定数据库是否以只读方式打开。该参数默认为false，表示数据库可读可写。该参数为true时，只允许从数据库读取数据，不允许对数据库进行写操作，否则会返回错误码801。
    };

    // 判断数据库版本，如果不匹配则需进行升降级操作
    //创建文件下载信息数据表
    let SQL_CREATE_TABLE = "CREATE TABLE IF NOT EXISTS " + downloadInfo + " ("
      + "id INTEGER PRIMARY KEY  AUTOINCREMENT NOT NULL , "
      + "userID TEXT, " //用户id
      + "taskID TEXT, " //当前下载任务id
      + "url TEXT, "  //下载文件地址
      + "filePath TEXT, " //文件存储路径
      + "fileName TEXT, " // 文件名
      + "fileSize INTEGER, " // 文件大小
      + "downLoadSize INTEGER , " //文件已下载大小
      + "status INTEGER DEFAULT 3 , " //下载状态  待下载、下载中、已下载、已暂停、下载失败 默认待下载
      + "downloadId TEXT, " //下载列表每项id
      + "moduleType INTEGER, " //资料下载 、缓存课程
      + "begins INTEGER" //开始下载位置
      + ")";
    try {
      SqliteHelper.rdbStore = await relationalStore.getRdbStore(this.context, STORE_CONFIG)
      await SqliteHelper.rdbStore?.executeSql(SQL_CREATE_TABLE)
    } catch (e) {
      Logger.init({
        tag: '数据库建表出错'
      })
      Logger.info(e);
    }
  }

  /**
   * 插入数据
   * */
  public insert(tabName: string, data: ValuesBucket): Promise<number> {
    // this.rdbStore?.beginTransaction();
    return new Promise(async (resolve, reject) => {
      SqliteHelper.rdbStore ?.insert(tabName, data).then(number => {
        resolve(number);
      }).catch((err: BusinessError) => {
        reject(0)
      })
    })
  }

  /*
  * 删除数据
  * */
  public deleteData(predicates: relationalStore.RdbPredicates): Promise<number> {
    return new Promise((resolve, reject) => {
      SqliteHelper.rdbStore?.delete(predicates).then(number => {
        resolve(number);
      })
    })
  }

  /**
   * 更新数据
   * */

  public update(data: ValuesBucket, predicates: relationalStore.RdbPredicates): Promise<number> {
    return new Promise((resolve, reject) => {
      SqliteHelper.rdbStore?.update(data, predicates).then(number => {
        resolve(number);
      }).catch((err: BusinessError) => {
        reject(0);
      })
    })
  }

  // userId taskId status  downloadId
  public queryData(predicates: relationalStore.RdbPredicates): Promise<Array<DownloadInfo>> {
    let list: Array<DownloadInfo> = [];
    return new Promise(async (resolve, reject) => {
      const resultSet = await SqliteHelper.rdbStore?.query(predicates,
        ['userID', 'taskID', 'url', 'filePath', 'fileName', 'fileSize', 'downLoadSize', 'status', 'downloadId',
          'moduleType', 'begins']);
      while (resultSet?.goToNextRow()) {
        const userId = resultSet.getString(resultSet.getColumnIndex('userID'));
        const taskId = resultSet.getString(resultSet.getColumnIndex('taskID'));
        const url = resultSet.getString(resultSet.getColumnIndex('url'));
        const filePath = resultSet.getString(resultSet.getColumnIndex('filePath'));
        const fileName = resultSet.getString(resultSet.getColumnIndex('fileName'));
        const fileSize = resultSet.getLong(resultSet.getColumnIndex('fileSize'));
        const downLoadSize = resultSet.getLong(resultSet.getColumnIndex('downLoadSize'));
        const status = resultSet.getLong(resultSet.getColumnIndex('status'))
        const downloadId = resultSet.getString(resultSet.getColumnIndex('downloadId'))
        const moduleType = resultSet.getLong(resultSet.getColumnIndex('moduleType'))
        const begins = resultSet.getLong(resultSet.getColumnIndex('begins'))
        let downloadInfo: DownloadInfo =
          new DownloadInfo(userId, taskId, url, filePath, fileName, fileSize, downLoadSize, status, downloadId,
            moduleType, begins);
        list.push(downloadInfo);
      }
      resolve(list);
      resultSet?.close()
      // 释放数据集的内存
    })
  }
}