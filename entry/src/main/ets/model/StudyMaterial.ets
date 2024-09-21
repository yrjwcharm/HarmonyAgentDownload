export class StudyMaterial {
  private _userId: string;

  public set userId(value: string) {
    this._userId = value;
  }

  public get userId(): string {
    return this._userId;
  }

  private _entityNumber: string;

  public set entityNumber(value: string) {
    this._entityNumber = value;
  }

  public get entityNumber(): string {
    return this._entityNumber;
  }

  private _parentNumber: number;

  public set parentNumber(value: number) {
    this._parentNumber = value;
  }

  public get parentNumber(): number {
    return this._parentNumber;
  }

  private _rootNumber: number;

  public set rootNumber(value: number) {
    this._rootNumber = value;
  }

  public get rootNumber(): number {
    return this._rootNumber;
  }

  private _name: string;

  public set name(value: string) {
    this._name = value;
  }

  public get name(): string {
    return this._name;
  }

  private _entityType: number;

  public set entityType(value: number) {
    this._entityType = value;
  }

  public get entityType(): number {
    return this._entityType;
  }

  private _fileSizeStr: string;

  public set fileSizeStr(value: string) {
    this._fileSizeStr = value;
  }

  public get fileSizeStr(): string {
    return this._fileSizeStr;
  }

  private _taskId: string;

  public set taskId(value: string) {
    this._taskId = value;
  }

  public get taskId(): string {
    return this._taskId;
  }

  private _url: string;

  public set url(value: string) {
    this._url = value;
  }

  public get url(): string {
    return this._url;
  }

  private _filePath: string;

  public set filePath(value: string) {
    this._filePath = value;
  }

  public get filePath(): string {
    return this._filePath;
  }

  private _fileName: string;

  public set fileName(value: string) {
    this._fileName = value;
  }

  public get fileName(): string {
    return this._fileName;
  }

  private _fileSize: number;

  public set fileSize(value: number) {
    this._fileSize = value;
  }

  public get fileSize(): number {
    return this._fileSize;
  }

  private _downloadSize: number;

  public set downloadSize(value: number) {
    this._downloadSize = value;
  }

  public get downloadSize(): number {
    return this._downloadSize;
  }

  private _status: number;

  public set status(value: number) {
    this._status = value;
  }

  public get status(): number {
    return this._status;
  }

  private _downloadId: string;

  public set downloadId(value: string) {
    this._downloadId = value;
  }

  public get downloadId(): string {
    return this._downloadId;
  }

  private _begins: number;

  public set begins(value: number) {
    this._begins = value;
  }

  public get begins(): number {
    return this._begins;
  }

  constructor(userId: string, entityNumber: string, parentNumber: number, rootNumber: number, name: string,
    entityType: number, fileSizeStr: string, taskId: string, url: string, filePath: string,
    fileName: string, fileSize: number, downloadSize: number, status: number, downloadId: string, begins: number) {
    this._userId = userId;
    this._entityNumber = entityNumber;
    this._parentNumber = parentNumber;
    this._rootNumber = rootNumber;
    this._name = name;
    this._entityType = entityType;
    this._fileSizeStr = fileSizeStr;
    this._fileSize = fileSize;
    this._taskId = taskId;
    this._url = url;
    this._filePath = filePath;
    this._fileName = fileName;
    this._downloadSize = downloadSize;
    this._status = status;
    this._downloadId = downloadId;
    this._begins = begins;
  }
}