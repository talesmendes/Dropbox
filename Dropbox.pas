unit Dropbox;

interface

uses
  System.SysUtils, System.Classes, System.JSON, System.Generics.Collections, System.Hash,
  IdHTTP, IdBaseComponent, IdComponent, IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL,
  DoFinally;

type
  TFileDropbox = record
    tag, name, path_lower, path_display, client_modified, server_modified, content_hash: String;
    constructor Create(tag, name, path_lower, path_display, client_modified, server_modified, content_hash: String);
  end;

  TDropbox = class
  private
    FApiToken: String;
    FFolder: String;
    FProc: TProc<String>;
  public
    procedure SetApiToken(aApiToken: String);
    procedure SetFolder(aFolder: String);
    procedure DoLog(aLog: String);
    function JsonListFolder: String;
    function GetFiles: TList<TFileDropbox>;
    function UploadFile(aName, aLocalFile: String; var aError: String): Boolean;
    function DownloadFile(aName, aLocalFile: String; var aError: String): Boolean;
    function GetFileHashSHA256(FileName: WideString): String;

    property ApiToken: String read FApiToken write FApiToken;
    property Folder: String read FFolder write FFolder;
    property Proc: TProc<String> read FProc write FProc;
  end;

implementation

{ TFileDropbox }

constructor TFileDropbox.Create(tag, name, path_lower, path_display, client_modified, server_modified, content_hash: String);
begin
  Self.tag             := StringReplace(tag            , sLineBreak, '', [rfReplaceAll]);
  Self.name            := StringReplace(name           , sLineBreak, '', [rfReplaceAll]);
  Self.path_lower      := StringReplace(path_lower     , sLineBreak, '', [rfReplaceAll]);
  Self.path_display    := StringReplace(path_display   , sLineBreak, '', [rfReplaceAll]);
  Self.client_modified := StringReplace(client_modified, sLineBreak, '', [rfReplaceAll]);
  Self.server_modified := StringReplace(server_modified, sLineBreak, '', [rfReplaceAll]);
  Self.content_hash    := StringReplace(content_hash   , sLineBreak, '', [rfReplaceAll]);
end;

{ TDropbox }

function TDropbox.GetFiles: TList<TFileDropbox>;
var
  DF: IDoFinally;
  JsFolder: String;
  JsObject : TJSONObject;
  JsPair: TJSONPair;
  JsArray: TJSONArray;
  Value: TJSONValue;
begin
  Result   := TList<TFileDropbox>.Create;
  JsFolder := JsonListFolder;
  JsObject := TDoFinally.Guard(TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(JsFolder), 0) as TJSONObject, DF);
  JsPair   := JsObject.Get(0);

  if JsObject.Size > 0 then
  begin
    JsPair := JsObject.Get(0);

    if JsPair.JsonString.Value.Equals('entries') then
    begin
      JsArray := TJSONArray(JsPair.JsonValue);
      for Value in JsArray do
      begin
        JsPair := (Value as TJSONObject).Get(0);
        Result.Add(TFileDropbox.Create(JsPair.JsonValue.ToString, Value.GetValue<String>('name'),
          Value.GetValue<String>('path_lower'), Value.GetValue<String>('path_display'),
          Value.GetValue<String>('client_modified'), Value.GetValue<String>('server_modified'),
          Value.GetValue<String>('content_hash')));
      end;
    end;
  end;
end;

procedure TDropbox.DoLog(aLog: String);
begin
  if Assigned(Proc) then
    Proc(aLog);
end;

function TDropbox.DownloadFile(aName, aLocalFile: String; var aError: String): Boolean;
var
  DF: IDoFinally;
  IdHTTP: TIdHTTP;
  StrResp: TMemoryStream;
  FilePath: String;
  Json: TJsonObject;
Begin
  Result   := False;
  FilePath := Folder + aName;

  IdHTTP  := TDoFinally.Guard(TIdHTTP.Create, DF);
  StrResp := TDoFinally.Guard(TMemoryStream.Create, DF);
  Json    := TDoFinally.Guard(TJsonObject.Create, DF);

  IdHTTP.IOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(IdHTTP);
  IdHTTP.IOHandler.LargeStream := True;
  IdHTTP.Request.CustomHeaders.AddValue('Authorization', 'Bearer ' + ApiToken);

  Json.AddPair('path', TJSONString.Create(FilePath));
  IdHTTP.Request.CustomHeaders.AddValue('Dropbox-API-Arg', json.ToString);
  IdHTTP.Request.Accept      := 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8';
  IdHTTP.HandleRedirects     := true;
  IdHTTP.Request.ContentType := '';

  try
    IdHTTP.get('https://content.dropboxapi.com/2/files/download', StrResp);
    DoLog('Download ok');
  except
    Result := False;
    DoLog('Erro no Download');
  end;

  Result := IdHTTP.ResponseCode = 200;
  StrResp.Position := 0;

  if Result then
  begin
    DeleteFile(PChar(aLocalFile));
    StrResp.SaveToFile(aLocalFile);
  end;
end;

function TDropbox.GetFileHashSHA256(FileName: WideString): String;
var
  HashSHA: THashSHA2;
  Stream: TStream;
  Readed: Integer;
  Buffer: PByte;
  BufLen: Integer;
  HashCombinado: TBytes;
  HashFinal: string;
begin
  HashSHA := THashSHA2.Create(SHA256);
  BufLen  := 4 * 1024 * 1024;
  Buffer  := AllocMem(BufLen);
  SetLength(HashCombinado, 0);

  try
    Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
    try
      while Stream.Position < Stream.Size do
      begin
        Readed := Stream.Read(Buffer^, BufLen);
        if Readed > 0 then
        begin
          HashSHA.Reset;
          HashSHA.update(Buffer^, Readed);
          HashCombinado := HashCombinado + HashSHA.HashAsBytes;
        end;
      end;
    finally
      Stream.Free;
    end;
  finally
    FreeMem(Buffer)
  end;

  HashSha.Reset;
  HashSHA.Update(HashCombinado[0], Length(HashCombinado));
  HashFinal := HashSHA.HashAsString;
  Result    := HashFinal;
end;

function TDropbox.JsonListFolder: String;
const
  URL = 'https://api.dropboxapi.com/2/files/list_folder';
var
  DF: IDoFinally;
  IdHTTP: TIdHTTP;
  Source: TStringStream;
  Stream: TMemoryStream;
  Json: TJSONObject;
begin
  Json := TDoFinally.Guard(TJSONObject.Create, DF);
  Json.AddPair('path'                               , TJSONString.Create(Folder));
  Json.AddPair('recursive'                          , TJSONBool.Create(False));
  Json.AddPair('include_media_info'                 , TJSONBool.Create(False));
  Json.AddPair('include_deleted'                    , TJSONBool.Create(False));
  Json.AddPair('include_has_explicit_shared_members', TJSONBool.Create(False));

  Source := TDoFinally.Guard(TStringStream.Create(Json.ToString), DF);
  IdHTTP := TDoFinally.Guard(TIdHTTP.Create(nil), DF);

  try
    IdHTTP.IOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(IdHTTP);
    IdHTTP.Request.CustomHeaders.Values['Authorization'] := 'Bearer ' + ApiToken;
    IdHTTP.Request.BasicAuthentication                   := False;
    IdHTTP.Request.ContentType                           := 'application/json';
    Result := IdHTTP.Post(URL, Source);
    DoLog(Result);
  except on E: Exception do
    Result := EmptyStr;
  end;
end;

procedure TDropbox.SetApiToken(aApiToken: String);
begin
  ApiToken := aApiToken;
end;

procedure TDropbox.SetFolder(aFolder: String);
begin
  Folder := aFolder;
end;

function TDropbox.UploadFile(aName, aLocalFile: String; var aError: String): Boolean;
var
  DF: IDoFinally;
  IdHTTP: TIdHTTP;
  FilePath, StrPost: String;
  StrResp: TFileStream;
  Json: TJSONObject;
begin
  Result   := False;
  FilePath := Concat(Folder, '/', aName).Trim;
  IdHTTP   := TDoFinally.Guard(TIdHTTP.Create, DF);
  StrResp  := TDoFinally.Guard(TFileStream.Create(aLocalFile, fmOpenRead or fmShareDenyNone), DF);
  Json     := TDoFinally.Guard(TJSONObject.Create, DF);

  try
    IdHTTP.IOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(IdHTTP);
    IdHTTP.IOHandler.LargeStream := True;
    StrResp.Position := 0;

    IdHTTP.Request.CustomHeaders.AddValue('Authorization', 'Bearer ' + ApiToken);
    Json.AddPair('autorename', TJSOnbool.Create(false));
    Json.AddPair('path', TJSONString.Create(FilePath));
    Json.AddPair('mute', TJSOnbool.Create(False));
    Json.AddPair('mode', TJSONString.Create('overwrite'));

    IdHTTP.Request.CustomHeaders.AddValue('Dropbox-API-Arg', Json.ToString);
    IdHTTP.Request.Accept      := 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8';
    IdHTTP.HandleRedirects     := True;
    IdHTTP.Request.CharSet     := 'utf-8';
    IdHTTP.Request.ContentType := 'text/plain; charset=dropbox-cors-hack';

    StrPost := IdHTTP.Post('https://content.dropboxapi.com/2/files/upload', StrResp);
    Result  := IdHTTP.ResponseCode = 200;

    if not Result then
      aError := IdHTTP.ResponseText;

  except on E: Exception do
    aError := E.Message;
  end;
end;

end.
