import relationalStore from '@ohos.data.relationalStore';
import { ValuesBucket } from '@ohos.data.ValuesBucket';
import { CacheCourse } from '../model/CacheCourse';
import { BusinessError } from '@kit.BasicServicesKit';
import { Log } from '@abner/log';
import { StudyMaterial } from '../model/StudyMaterial';
import { JSON } from '@kit.ArkTS';
import { API_COMMON_INTERFACE } from '../interface/ICommon';

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
    let cacheCourse = 'cachecourse';
    let studyMaterial = 'studymaterial';
    const STORE_CONFIG: relationalStore.StoreConfig = {
      name: 'filedownloader.db', // 数据库文件名
      securityLevel: relationalStore.SecurityLevel.S1, // 数据库安全级别
      encrypt: false, // 可选参数，指定数据库是否加密，默认不加密
      // customDir: 'customDir/subCustomDir',
      // 可选参数，数据库自定义路径。数据库将在如下的目录结构中被创建：context.databaseDir + '/rdb/' + customDir，其中context.databaseDir是应用沙箱对应的路径，'/rdb/'表示创建的是关系型数据库，customDir表示自定义的路径。当此参数不填时，默认在本应用沙箱目录下创建RdbStore实例。
      isReadOnly: false // 可选参数，指定数据库是否以只读方式打开。该参数默认为false，表示数据库可读可写。该参数为true时，只允许从数据库读取数据，不允许对数据库进行写操作，否则会返回错误码801。
    };

    //创建缓存课程信息数据表
    let SQL_CREATE_CACHE_COURSE_TABLE = "CREATE TABLE IF NOT EXISTS " + cacheCourse + " ("
      + "id INTEGER PRIMARY KEY  AUTOINCREMENT NOT NULL , "
      + "userId TEXT, " //用户id
      + "playbackList TEXT, " //回放list
      + "bigRoomId TEXT, "
      + "subRoomId TEXT, "
      + "version TEXT, "
      + "subClazzNumber TEXT, "
      + "property TEXT, "
      + "roomType INTEGER, "
      + "layoutType INTEGER, "
      + "layoutTypeV2 INTEGER, "
      + "flexiblySwitchGreyFlag INTEGER, "
      + "clazzLessonNumber TEXT, " //课节id
      + "clazzLessonName TEXT, " //课节名称
      + "clazzLessonTagDesc TEXT, " //课节描述
      + "clazzNumber TEXT, " //课程ID
      + "clazzName TEXT, " //课程名称
      + "taskId TEXT, " //当前下载任务id
      + "url TEXT, "
      + "filePath TEXT, "
      + "fileName TEXT, "
      + "playBackUrl TEXT, " //playback回放文件存储路径
      + "fileSize INTEGER, " // 文件大小
      + "downLoadSize INTEGER , " //文件已下载大小
      + "status INTEGER DEFAULT 3 , " //下载状态  待下载、下载中、已下载、已暂停、下载失败 默认待下载
      + "downloadId TEXT, " //下载列表每项id
      + "begins INTEGER"
      + ")";
    let SQL_CREATE_STUDY_MATERIAL_TABLE = "CREATE TABLE IF NOT EXISTS " + studyMaterial + " ("
      + "id INTEGER PRIMARY KEY  AUTOINCREMENT NOT NULL , "
      + "userId TEXT, " //用户id
      + "entityNumber TEXT, " //用户id
      + "parentNumber LONG, " //用户id
      + "rootNumber LONG, " //用户id
      + "name TEXT, " //用户id
      + "entityType INTEGER, " //用户id
      + "fileSizeStr TEXT, " //用户id
      + "taskId TEXT, " //当前下载任务id
      + "url TEXT, "
      + "fid TEXT, "
      + "filePath TEXT, "
      + "fileName TEXT, "
      + "fileSize INTEGER, " // 文件大小
      + "downLoadSize INTEGER , " //文件已下载大小
      + "status INTEGER DEFAULT 3 , " //下载状态  待下载、下载中、已下载、已暂停、下载失败 默认待下载
      + "downloadId TEXT, " //下载列表每项id
      + "begins INTEGER"
      + ")";
    try {
      SqliteHelper.rdbStore = await relationalStore.getRdbStore(this.context, STORE_CONFIG)
      await SqliteHelper.rdbStore?.executeSql(SQL_CREATE_CACHE_COURSE_TABLE)
      await SqliteHelper.rdbStore?.executeSql(SQL_CREATE_STUDY_MATERIAL_TABLE)
    } catch (e) {
      Log.info("数据库建表异常", e.message);
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
        reject(err)
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
      }).catch((e: BusinessError) => {
        reject(e);
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
        reject(err);
        console.log('异常日志', err.message)
      })
    })
  }

  public queryData(predicates: relationalStore.RdbPredicates,
    moduleType: number): Promise<Array<CacheCourse> | Array<StudyMaterial>> {
    if (moduleType === 1) {
      return this.queryCacheCourseData(predicates);
    } else {
      return this.queryStudyMaterialData(predicates);
    }
  }

  // 查询缓存课程
  public queryCacheCourseData(predicates: relationalStore.RdbPredicates): Promise<Array<CacheCourse>> {
    let list: Array<CacheCourse> = [];
    return new Promise(async (resolve, reject) => {
      SqliteHelper.rdbStore?.query(predicates,
        ['userId', 'playbackList', 'bigRoomId', 'subRoomId', 'version', 'subClazzNumber', 'property', 'roomType',
          'layoutType', 'layoutTypeV2', 'flexiblySwitchGreyFlag', 'clazzLessonNumber', 'clazzLessonName',
          'clazzLessonTagDesc',
          'clazzNumber', 'clazzName', 'taskId', 'url', 'filePath', 'fileName', 'playBackUrl', 'downloadSize',
          'fileSize', 'status', 'downloadId',
          'begins']).then(resultSet => {
        while (resultSet?.goToNextRow()) {
          const userId = resultSet.getString(resultSet.getColumnIndex('userId'));
          const playbackList = resultSet.getString(resultSet.getColumnIndex('playbackList'));
          const bigRoomId = resultSet.getString(resultSet.getColumnIndex('bigRoomId'));
          const subRoomId = resultSet.getString(resultSet.getColumnIndex('subRoomId'));
          const version = resultSet.getString(resultSet.getColumnIndex('version'));
          const subClazzNumber = resultSet.getString(resultSet.getColumnIndex('subClazzNumber'));
          const property = resultSet.getString(resultSet.getColumnIndex('property'));
          const roomType = resultSet.getLong(resultSet.getColumnIndex('roomType'));
          const layoutType = resultSet.getLong(resultSet.getColumnIndex('layoutType'));
          const layoutTypeV2 = resultSet.getLong(resultSet.getColumnIndex('layoutTypeV2'));
          const flexiblySwitchGreyFlag = resultSet.getLong(resultSet.getColumnIndex('flexiblySwitchGreyFlag'));
          const clazzLessonNumber = resultSet.getString(resultSet.getColumnIndex('clazzLessonNumber'));
          const clazzLessonName = resultSet.getString(resultSet.getColumnIndex('clazzLessonName'));
          const clazzLessonTagDesc = resultSet.getString(resultSet.getColumnIndex('clazzLessonTagDesc'));
          const clazzNumber = resultSet.getString(resultSet.getColumnIndex('clazzNumber'));
          const clazzName = resultSet.getString(resultSet.getColumnIndex('clazzName'));
          const taskId = resultSet.getString(resultSet.getColumnIndex('taskId'));
          const url = resultSet.getString(resultSet.getColumnIndex('url'));
          const filePath = resultSet.getString(resultSet.getColumnIndex('filePath'));
          const fileName = resultSet.getString(resultSet.getColumnIndex('fileName'));
          const playBackUrl = resultSet.getString(resultSet.getColumnIndex('playBackUrl'));
          const fileSize = resultSet.getLong(resultSet.getColumnIndex('fileSize'));
          const downLoadSize = resultSet.getLong(resultSet.getColumnIndex('downLoadSize'));
          const status = resultSet.getLong(resultSet.getColumnIndex('status'))
          const downloadId = resultSet.getString(resultSet.getColumnIndex('downloadId'))
          const begins = resultSet.getLong(resultSet.getColumnIndex('begins'))
          let cacheCourse: CacheCourse =
            new CacheCourse(userId, JSON.parse(playbackList) as API_COMMON_INTERFACE.IPlayback[], bigRoomId, subRoomId,
              version, subClazzNumber
              , property, roomType, layoutType, layoutTypeV2, flexiblySwitchGreyFlag == 1, clazzLessonNumber,
              clazzLessonName, clazzLessonTagDesc, clazzNumber, clazzName, taskId, url, filePath, fileName, playBackUrl,
              fileSize, downLoadSize, status, downloadId, begins)
          list.push(cacheCourse);
        }
        resolve(list);
        resultSet?.close()
        // 释放数据集的内存
      }).catch((e: BusinessError) => {
        console.log('查询缓存课程数据异常...', e.message)
        reject(e);
      })
    })
  }

  // 查询学习资料
  public queryStudyMaterialData(predicates: relationalStore.RdbPredicates): Promise<Array<StudyMaterial>> {
    let list: Array<StudyMaterial> = [];
    return new Promise(async (resolve, reject) => {
      SqliteHelper.rdbStore?.query(predicates,
        ['userId', 'entityNumber', 'parentNumber', 'rootNumber', 'name', 'entityType', 'fileSizeStr',
          'taskId', 'url', 'fid', 'filePath', 'fileName', 'downloadSize',
          'fileSize', 'status', 'downloadId',
          'begins']).then(resultSet => {
        while (resultSet?.goToNextRow()) {
          const userId = resultSet.getString(resultSet.getColumnIndex('userId'));
          const entityNumber = resultSet.getString(resultSet.getColumnIndex('entityNumber'));
          const parentNumber = resultSet.getLong(resultSet.getColumnIndex('parentNumber'));
          const rootNumber = resultSet.getLong(resultSet.getColumnIndex('rootNumber'));
          const name = resultSet.getString(resultSet.getColumnIndex('name'));
          const entityType = resultSet.getLong(resultSet.getColumnIndex('entityType'));
          const fileSizeStr = resultSet.getString(resultSet.getColumnIndex('fileSizeStr'));
          const taskId = resultSet.getString(resultSet.getColumnIndex('taskId'));
          const url = resultSet.getString(resultSet.getColumnIndex('url'));
          const fid = resultSet.getString(resultSet.getColumnIndex('fid'));
          const filePath = resultSet.getString(resultSet.getColumnIndex('filePath'));
          const fileName = resultSet.getString(resultSet.getColumnIndex('fileName'));
          const fileSize = resultSet.getLong(resultSet.getColumnIndex('fileSize'));
          const downloadSize = resultSet.getLong(resultSet.getColumnIndex('downLoadSize'));
          const status = resultSet.getLong(resultSet.getColumnIndex('status'))
          const downloadId = resultSet.getString(resultSet.getColumnIndex('downloadId'))
          const begins = resultSet.getLong(resultSet.getColumnIndex('begins'))
          let studyMaterial: StudyMaterial =
            new StudyMaterial(userId, entityNumber, parentNumber, rootNumber, name, entityType, fileSizeStr, taskId,
              url, fid, filePath, fileName, fileSize, downloadSize, status, downloadId, begins)
          list.push(studyMaterial);
        }
        console.log('333', list)
        resolve(list);
        resultSet?.close()
        // 释放数据集的内存
      }).catch((e: BusinessError) => {
        console.log('查询学习资料数据异常...', e.message)
        reject(e);
      })
    })
  }
}