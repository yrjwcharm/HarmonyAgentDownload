export class DownloadInfo {
  constructor(userId: string, taskId: string, url: string, filePath: string, fileName: string, fileSize: number,
    downloadSize: number,
    status: number, downloadId: string, moduleType: number, begins: number) {
    this._userId = userId;
    this._taskId = taskId;
    this._url = url;
    this._filePath = filePath;
    this._fileSize = fileSize;
    this._downloadSize = downloadSize;
    this._fileName = fileName;
    this._status = status;
    this._downloadId = downloadId;
    this._moduleType = moduleType;
    this._begins = begins;
  }

  private _begins: number;

  public get begins(): number {
    return this._begins;
  }

  private set begins(value: number) {
    this._begins = value;
  }

  private _moduleType: number;

  public get moduleType(): number {
    return this._moduleType;
  }

  public set moduleType(value: number) {
    this._moduleType = value;
  }

  private _downloadId: string;

  public get downloadId(): string {
    return this._downloadId;
  }

  public set downloadId(value: string) {
    this._downloadId = value;
  }

  private _userId: string;

  public get userId(): string {
    return this._userId;
  }

  public set userId(value: string) {
    this._userId = value;
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

  private _fileSize: number;

  public get fileSize(): number {
    return this._fileSize;
  }

  public set fileSize(value: number) {
    this._fileSize = value;
  }

  private _fileName: string;

  public get fileName(): string {
    return this._fileName;
  }

  public set fileName(value: string) {
    this._fileName = value;
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
}