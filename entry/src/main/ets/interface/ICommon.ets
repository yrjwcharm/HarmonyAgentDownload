export declare namespace API_COMMON_INTERFACE {
  interface IPackage {
    url: string;
    size?: string;
    playbackName?: string;
    fid?: string;
  }

  interface IPlayback {
    imPackage: IPackage;
    videoPackage: IPackage;
    roomId: string;
    sessionId: number;
    playbackName: string,
    duration: number,
    playbackImg: string;
    fid: string;
  }

  //缓存课程接口定义
  interface ICacheCourse {
    userId: string,
    playbackList: IPlayback[],
    bigRoomId: string,
    subRoomId: string,
    version: string,
    subClazzNumber: string,
    property: string,
    roomType: number,
    layoutType: number,
    layoutTypeV2: number,
    flexiblySwitchGreyFlag: boolean,
    begins?: number, //数据库必传字段
    playbackUrl?: string
    clazzLessonNumber: string, //课节id
    clazzLessonName: string, //课节名称
    clazzLessonTagDesc: string, //课节tag
    clazzNumber: string, //课程id
    clazzName: string; //课程名称
    // "gradeDesc": "一年级",
    // "subjectDesc": "围"
    // lessonStartTimeDesc: "09月22日 周四",
    // "timeInternalDesc": "19:00-20:10",
    // "liveId": "9801550417103232",
    // "liveType": 1,
    // "lessonLiveType": 0,
    // "sessionIdList": null,
    // "lessonType": 0,
    // "videoType": 0,
    // "roomType": 0,
    // "beginTimeStamp": 1663844400
  }

  //学习资料接口定义
  interface IStudyMaterial {
    userId: string,
    entityNumber: string,
    parentNumber: number,
    rootNumber: number,
    name: string,
    entityType: number,
    fileSizeStr: string,
    fileSize: number,
    url: string,
    fid: string,
    begins?: number,

  }

  interface IFidPackage {
    fid: string;
    videoPackageUrl: string,
    imPackageUrl: string;
    playbackImg: string
  }

  interface IMergedData {
    fid: IFidPackage
  }
}