object fMain: TfMain
  Left = 0
  Top = 0
  Caption = 'Dropbox'
  ClientHeight = 482
  ClientWidth = 922
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object btnUpload: TButton
    Left = 8
    Top = 287
    Width = 121
    Height = 25
    Caption = 'Upload/Sinc files'
    TabOrder = 0
    OnClick = btnUploadClick
  end
  object memLog: TMemo
    Left = 8
    Top = 96
    Width = 537
    Height = 185
    TabOrder = 1
  end
  object lbledtApiToken: TLabeledEdit
    Left = 8
    Top = 24
    Width = 537
    Height = 21
    EditLabel.Width = 44
    EditLabel.Height = 13
    EditLabel.Caption = 'ApiToken'
    TabOrder = 2
  end
  object lbledtFolder: TLabeledEdit
    Left = 8
    Top = 64
    Width = 241
    Height = 21
    EditLabel.Width = 30
    EditLabel.Height = 13
    EditLabel.Caption = 'Folder'
    TabOrder = 3
    Text = 'C:\Lixo'
  end
  object lbledtFolderRemoto: TLabeledEdit
    Left = 272
    Top = 64
    Width = 273
    Height = 21
    EditLabel.Width = 67
    EditLabel.Height = 13
    EditLabel.Caption = 'Folder remoto'
    TabOrder = 4
    Text = '/test/myfolder'
  end
  object GroupBox1: TGroupBox
    Left = 551
    Top = 8
    Width = 363
    Height = 466
    Caption = ' Log '
    TabOrder = 5
    object memDB: TMemo
      Left = 2
      Top = 15
      Width = 359
      Height = 449
      Align = alClient
      ScrollBars = ssVertical
      TabOrder = 0
    end
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 328
    Width = 537
    Height = 146
    Caption = ' Download '
    TabOrder = 6
    object lbledtFolderDownload: TLabeledEdit
      Left = 10
      Top = 30
      Width = 273
      Height = 21
      EditLabel.Width = 67
      EditLabel.Height = 13
      EditLabel.Caption = 'Folder remoto'
      TabOrder = 0
      Text = '/test/myfolder/'
    end
    object lbledtFileDownload: TLabeledEdit
      Left = 10
      Top = 72
      Width = 273
      Height = 21
      EditLabel.Width = 43
      EditLabel.Height = 13
      EditLabel.Caption = 'FileName'
      TabOrder = 1
      Text = 'milky-way-nasa1.jpg'
    end
    object lbledtDestino: TLabeledEdit
      Left = 10
      Top = 113
      Width = 273
      Height = 21
      EditLabel.Width = 36
      EditLabel.Height = 13
      EditLabel.Caption = 'Destino'
      TabOrder = 2
      Text = 'C:\Lixo\Download'
    end
    object Button1: TButton
      Left = 294
      Top = 109
      Width = 219
      Height = 25
      Caption = 'Download file'
      TabOrder = 3
      OnClick = Button1Click
    end
  end
end
