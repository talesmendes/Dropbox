unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.IOUtils, System.Types,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, DoFinally, Vcl.StdCtrls, Dropbox,
  System.Generics.Collections, Vcl.ExtCtrls;

type
  TfMain = class(TForm)
    btnUpload: TButton;
    memLog: TMemo;
    lbledtApiToken: TLabeledEdit;
    lbledtFolder: TLabeledEdit;
    lbledtFolderRemoto: TLabeledEdit;
    GroupBox1: TGroupBox;
    memDB: TMemo;
    GroupBox2: TGroupBox;
    lbledtFolderDownload: TLabeledEdit;
    lbledtFileDownload: TLabeledEdit;
    lbledtDestino: TLabeledEdit;
    Button1: TButton;
    procedure btnUploadClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fMain: TfMain;

implementation

{$R *.dfm}

procedure TfMain.btnUploadClick(Sender: TObject);
var
  DF: IDoFinally;
  MyDB: TDropbox;
  Fldb: TFileDropbox;
  &File, FileHash, FileName, Msg: String;
  Files: TList<TFileDropbox>;
  Dicts: TDictionary<String,TFileDropbox>;
  Locais: TStringDynArray;
begin
  MyDB  := TDoFinally.Guard(TDropbox.Create, DF);
  Dicts := TDoFinally.Guard(TDictionary<String,TFileDropbox>.Create, DF);

  MyDB.SetApiToken(lbledtApiToken.Text);
  MyDB.SetFolder(lbledtFolderRemoto.Text);

  MyDB.Proc := procedure(aLog: String) begin
    memDB.Lines.Add(aLog);
  end;

  Files := TDoFinally.Guard(MyDB.GetFiles, DF);
  for Fldb in Files do
    Dicts.AddOrSetValue(Fldb.name.ToLower, Fldb);

  memLog.Lines.Add('-->> Begin');

  Locais := TDirectory.GetFiles(lbledtFolder.Text);
  for &File in Locais do
  begin
    FileHash := MyDB.GetFileHashSHA256(&File);
    FileName := ExtractFileName(&File);

    if (not Dicts.ContainsKey(FileName.ToLower)) or (Dicts[FileName.ToLower].content_hash <> FileHash) then
    begin
      Msg := EmptyStr;
      MyDB.UploadFile(FileName, &File, Msg);
      memLog.Lines.Add(FileName + ' - Uploaded');
    end;
  end;

  memLog.Lines.Add('-->> End');
  memLog.Lines.Add('');
end;

procedure TfMain.Button1Click(Sender: TObject);
var
  DF: IDoFinally;
  MyDB: TDropbox;
  Msg: String;
begin
  MyDB := TDoFinally.Guard(TDropbox.Create, DF);
  MyDB.SetApiToken(lbledtApiToken.Text);
  MyDB.SetFolder(lbledtFolderDownload.Text);

  MyDB.Proc := procedure(aLog: String) begin
    memDB.Lines.Add(aLog);
  end;

  MyDB.DownloadFile(lbledtFileDownload.Text, IncludeTrailingBackslash(lbledtDestino.Text) + lbledtFileDownload.Text, Msg);
end;

procedure TfMain.FormCreate(Sender: TObject);
begin
  lbledtFolder.Text := ExtractFilePath(ParamStr(0)) + 'Imagens';
end;

end.
