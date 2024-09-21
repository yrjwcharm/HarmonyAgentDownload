export class StudyMaterial {
  constructor(userId: string, entityNumber: string, parentNumber: number, rootNumber: number, name: string,
    entityType: number, fileSizeStr: string, taskId: string, url: string, fid: string, filePath: string,
    fileName: string, fileSize: number, downloadSize: number, status: number, downloadId: string, begins: number) {
    this._userId = userId;
    this._entityNumber = entityNumber;
    this._parentNumber = parentNumber;
    this._rootNumber = rootNumber;
    this._name = name;
    this._entityType = entityType;
    this._fileSizeStr = fileSizeStr;
    this._taskId = taskId;
    this._url = url;
    this._fid = fid;
    this._filePath = filePath;
    this._fileName = fileName;
    this._fileSize = fileSize;
    this._downloadSize = downloadSize;
    this._status = status;
    this._downloadId = downloadId;
    this._begins = begins;
  }

  private _userId: string;

  public get userId(): string {
    return this._userId;
  }

  public set userId(value: string) {
    this._userId = value;
  }

  private _entityNumber: string;

  public get entityNumber(): string {
    return this._entityNumber;
  }

  public set entityNumber(value: string) {
    this._entityNumber = value;
  }

  private _parentNumber: number;

  public get parentNumber(): number {
    return this._parentNumber;
  }

  public set parentNumber(value: number) {
    this._parentNumber = value;
  }

  private _rootNumber: number;

  public get rootNumber(): number {
    return this._rootNumber;
  }

  public set rootNumber(value: number) {
    this._rootNumber = value;
  }

  private _name: string;

  public get name(): string {
    return this._name;
  }

  public set name(value: string) {
    this._name = value;
  }

  private _entityType: number;

  public get entityType(): number {
    return this._entityType;
  }

  public set entityType(value: number) {
    this._entityType = value;
  }

  private _fileSizeStr: string;

  public get fileSizeStr(): string {
    return this._fileSizeStr;
  }

  public set fileSizeStr(value: string) {
    this._fileSizeStr = value;
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

  private _fid: string;

  public get fid(): string {
    return this._fid;
  }

  public set fid(value: string) {
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

  private _begins: number;

  public get begins(): number {
    return this._begins;
  }

  public set begins(value: number) {
    this._begins = value;
  }
}