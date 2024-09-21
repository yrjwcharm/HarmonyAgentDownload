import { API_COMMON_INTERFACE } from '../interface/ICommon';

export class CacheCourse {
  constructor(userId: string, playbackList: API_COMMON_INTERFACE.IPlayback[], bigRoomId: string, subRoomId: string,
    version: string, subClazzNumber: string, property: string, roomType: number, layoutType: number,
    layoutTypeV2: number, flexiblySwitchGreyFlag: boolean, clazzLessonNumber: string, clazzLessonName: string,
    clazzLessonTagDesc: string, clazzNumber: string, clazzName: string, taskId: string, url: string, filePath: string,
    fileName: string,
    playbackUrl: string,
    fileSize: number, downloadSize: number, status: number, downloadId: string, begins: number) {
    this._userId = userId;
    this._playbackList = playbackList;
    this._bigRoomId = bigRoomId;
    this._subRoomId = subRoomId;
    this._version = version;
    this._subClazzNumber = subClazzNumber;
    this._property = property;
    this._roomType = roomType;
    this._layoutType = layoutType;
    this._layoutTypeV2 = layoutTypeV2;
    this._flexiblySwitchGreyFlag = flexiblySwitchGreyFlag;
    this._clazzLessonNumber = clazzLessonNumber;
    this._clazzLessonName = clazzLessonName;
    this._clazzLessonTagDesc = clazzLessonTagDesc;
    this._clazzNumber = clazzNumber;
    this._clazzName = clazzName;
    this._taskId = taskId;
    this._url = url;
    this._filePath = filePath;
    this._fileName = fileName;
    this._playbackUrl = playbackUrl;
    this._fileSize = fileSize;
    this._downloadSize = downloadSize;
    this._status = status;
    this._downloadId = downloadId;
    this._begins = begins;
    // this._fid = fid;
  }

  private _userId: string;

  public get userId(): string {
    return this._userId;
  }

  public set userId(value: string) {
    this._userId = value;
  }

  private _playbackList: API_COMMON_INTERFACE.IPlayback[];

  public get playbackList(): API_COMMON_INTERFACE.IPlayback[] {
    return this._playbackList;
  }

  public set playbackList(value: API_COMMON_INTERFACE.IPlayback[]) {
    this._playbackList = value;
  }

  private _bigRoomId: string;

  public get bigRoomId(): string {
    return this._bigRoomId;
  }

  public set bigRoomId(value: string) {
    this._bigRoomId = value;
  }

  private _subRoomId: string;

  public get subRoomId(): string {
    return this._subRoomId;
  }

  public set subRoomId(value: string) {
    this._subRoomId = value;
  }

  private _version: string;

  public get version(): string {
    return this._version;
  }

  public set version(value: string) {
    this._version = value;
  }

  private _subClazzNumber: string;

  public get subClazzNumber(): string {
    return this._subClazzNumber;
  }

  public set subClazzNumber(value: string) {
    this._subClazzNumber = value;
  }

  private _property: string;

  public get property(): string {
    return this._property;
  }

  public set property(value: string) {
    this._property = value;
  }

  private _roomType: number;

  public get roomType(): number {
    return this._roomType;
  }

  public set roomType(value: number) {
    this._roomType = value;
  }

  private _layoutType: number;

  public get layoutType(): number {
    return this._layoutType;
  }

  public set layoutType(value: number) {
    this._layoutType = value;
  }

  private _layoutTypeV2: number;

  public get layoutTypeV2(): number {
    return this._layoutTypeV2;
  }

  public set layoutTypeV2(value: number) {
    this._layoutTypeV2 = value;
  }

  private _flexiblySwitchGreyFlag: boolean;

  public get flexiblySwitchGreyFlag(): boolean {
    return this._flexiblySwitchGreyFlag;
  }

  public set flexiblySwitchGreyFlag(value: boolean) {
    this._flexiblySwitchGreyFlag = value;
  }

  private _clazzLessonNumber: string; //课节id

  public get clazzLessonNumber(): string {
    return this._clazzLessonNumber;
  }

  public set clazzLessonNumber(value: string) {
    this._clazzLessonNumber = value;
  }

  private _clazzLessonName: string; //课节名称

  public get clazzLessonName(): string {
    return this._clazzLessonName;
  }

  public set clazzLessonName(value: string) {
    this._clazzLessonName = value;
  }

  private _clazzLessonTagDesc: string; //课节tag

  public get clazzLessonTagDesc(): string {
    return this._clazzLessonTagDesc;
  }

  public set clazzLessonTagDesc(value: string) {
    this._clazzLessonTagDesc = value;
  }

  private _clazzNumber: string; //课程id

  public get clazzNumber(): string {
    return this._clazzNumber;
  }

  public set clazzNumber(value: string) {
    this._clazzNumber = value;
  }

  private _clazzName: string; //课程名称

  public get clazzName(): string {
    return this._clazzName;
  }

  public set clazzName(value: string) {
    this._clazzName = value;
  }

  private _taskId: string;

  public get taskId(): string {
    return this._taskId;
  }

  public set taskId(value: string) {
    this._taskId = value;
  }

  private _url: string;

  public get url(): string {
    return this._url;
  }

  public set url(value: string) {
    this._url = value;
  }

  private _filePath: string;

  public get filePath(): string {
    return this._filePath;
  }

  public set filePath(value: string) {
    this._filePath = value;
  }

  private _fileName: string;

  public get fileName(): string {
    return this._fileName;
  }

  public set fileName(value: string) {
    this._fileName = value;
  }

  private _playbackUrl: string;

  public get playbackUrl(): string {
    return this._playbackUrl;
  }

  public set playbackUrl(value: string) {
    this._playbackUrl = value;
  }

  private _fileSize: number;

  public get fileSize(): number {
    return this._fileSize;
  }

  public set fileSize(value: number) {
    this._fileSize = value;
  }

  private _downloadSize: number;

  public get downloadSize(): number {
    return this._downloadSize;
  }

  public set downloadSize(value: number) {
    this._downloadSize = value;
  }

  private _status: number;

  public get status(): number {
    return this._status;
  }

  public set status(value: number) {
    this._status = value;
  }

  private _downloadId: string;

  public get downloadId(): string {
    return this._downloadId;
  }

  public set downloadId(value: string) {
    this._downloadId = value;
  }

  private _begins: number; //数据库必传字段

  public get begins(): number {
    return this._begins;
  }

  public set begins(value: number) {
    this._begins = value;
  }

  // private _fid: string;

  // public get fid(): string {
  //   return this._fid;
  // }
  //
  // public set fid(value: string) {
  //   this._fid = value;
  // }
}