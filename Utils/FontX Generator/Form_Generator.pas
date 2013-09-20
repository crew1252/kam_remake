﻿unit Form_Generator;
{$I ..\..\KaM_Remake.inc}
interface
uses
  {$IFDEF WDC} Windows, {$ENDIF} //Declared first to get TBitmap overriden with VCL version
  {$IFDEF FPC} lconvencoding, {$ENDIF}
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, StdCtrls, Spin, StrUtils,
  KM_CommonTypes, KM_Defaults, KM_ResFonts, KM_ResFontsEdit, KM_ResPalettes, Vcl.ComCtrls;


type
  TForm1 = class(TForm)
    Label4: TLabel;
    Image1: TImage;
    btnSave: TButton;
    dlgSave: TSaveDialog;
    btnExportTex: TButton;
    dlgOpen: TOpenDialog;
    btnImportTex: TButton;
    GroupBox1: TGroupBox;
    sePadding: TSpinEdit;
    Label5: TLabel;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    btnGenerate: TButton;
    Memo1: TMemo;
    seFontSize: TSpinEdit;
    cbBold: TCheckBox;
    cbItalic: TCheckBox;
    btnCollectChars: TButton;
    rgSizeX: TRadioGroup;
    rgSizeY: TRadioGroup;
    cbCells: TCheckBox;
    cbAntialias: TCheckBox;
    cbFontName: TComboBox;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    btnSetRange: TButton;
    tbAtlas: TTrackBar;
    Label6: TLabel;
    procedure btnGenerateClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnExportTexClick(Sender: TObject);
    procedure btnImportTexClick(Sender: TObject);
    procedure btnCollectCharsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure UpdateCaption(const aString: UnicodeString);
    procedure btnSetRangeClick(Sender: TObject);
    procedure tbAtlasChange(Sender: TObject);
  private
    Fnt: TKMFontDataEdit;
  end;


var
  Form1: TForm1;


implementation
uses CharsCollector;
{$R *.dfm}


procedure TForm1.FormCreate(Sender: TObject);
begin
  Caption := 'KaM FontX Generator (' + GAME_REVISION + ')';
  ExeDir := ExtractFilePath(Application.ExeName);

  cbFontName.Items.AddStrings(Screen.Fonts);
end;


procedure TForm1.FormDestroy(Sender: TObject);
begin
  FreeAndNil(Fnt);
end;


procedure TForm1.btnGenerateClick(Sender: TObject);
var
  chars: UnicodeString;
  useChars: array of WideChar;
  fntStyle: TFontStyles;
begin
  FreeAndNil(Fnt);
  Fnt := TKMFontDataEdit.Create;

  {$IFDEF WDC}
  chars := Memo1.Text;
  {$ENDIF}
  {$IFDEF FPC}
  chars := UTF8Decode(Memo1.Text);
  {$ENDIF}
  SetLength(useChars, Length(chars));
  Move(chars[1], useChars[0], Length(chars) * SizeOf(WideChar));

  fntStyle := [];
  if cbBold.Checked then
    fntStyle := fntStyle + [fsBold];
  if cbItalic.Checked then
    fntStyle := fntStyle + [fsItalic];

  Fnt.TexPadding := sePadding.Value;
  Fnt.TexSizeX := StrToInt(rgSizeX.Items[rgSizeX.ItemIndex]);
  Fnt.TexSizeY := StrToInt(rgSizeY.Items[rgSizeY.ItemIndex]);
  Fnt.CreateFont(cbFontName.Text, seFontSize.Value, fntStyle, cbAntialias.Checked, useChars);
  tbAtlas.Max := Fnt.AtlasCount - 1;

  Fnt.ExportAtlasBmp(Image1.Picture.Bitmap, tbAtlas.Position, cbCells.Checked);
  Image1.Repaint;
end;


procedure TForm1.tbAtlasChange(Sender: TObject);
begin
  Fnt.ExportAtlasBmp(Image1.Picture.Bitmap, tbAtlas.Position, cbCells.Checked);
  Image1.Repaint;
end;


procedure TForm1.btnSaveClick(Sender: TObject);
begin
  dlgSave.DefaultExt := 'fntx';
  dlgSave.FileName := cbFontName.Text;
  dlgSave.InitialDir := ExpandFileName(ExeDir + '..\..\data\gfx\fonts\');
  if not dlgSave.Execute then Exit;

  Fnt.SaveToFontX(dlgSave.FileName);
end;


procedure TForm1.UpdateCaption(const aString: UnicodeString);
begin
  btnCollectChars.Caption := aString;
end;


procedure TForm1.btnSetRangeClick(Sender: TObject);
var
  uniText: UnicodeString;
  I: Integer;
begin
  uniText := '';

  for I := SpinEdit1.Value to SpinEdit2.Value do
    uniText := uniText + WideChar(I);

  {$IFDEF WDC}
    Memo1.Text := uniText;
  {$ENDIF}
  {$IFDEF FPC}
    //FPC controls need utf8 strings
    Memo1.Text := UTF8Encode(uniText);
  {$ENDIF}
end;


procedure TForm1.btnCollectCharsClick(Sender: TObject);
var
  lab: string;
  uniText: UnicodeString;
begin
  lab := btnCollectChars.Caption;
  try
    uniText := CollectChars(UpdateCaption);

    {$IFDEF WDC}
      Memo1.Text := uniText;
    {$ENDIF}
    {$IFDEF FPC}
      //FPC controls need utf8 strings
      Memo1.Text := UTF8Encode(uniText);
    {$ENDIF}
  finally
    btnCollectChars.Caption := lab;
  end;
end;


procedure TForm1.btnExportTexClick(Sender: TObject);
begin
  dlgSave.DefaultExt := 'png';
  if not dlgSave.Execute then Exit;

  Fnt.ExportAtlasPng(dlgSave.FileName, tbAtlas.Position);
end;


procedure TForm1.btnImportTexClick(Sender: TObject);
begin
  if not dlgOpen.Execute then Exit;

  Fnt.ImportPng(dlgOpen.FileName, tbAtlas.Position);
end;


end.