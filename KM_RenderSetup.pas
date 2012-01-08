unit KM_RenderSetup;
{$I KaM_Remake.inc}
interface
uses
  {$IFDEF MSWindows} Windows, {$ENDIF}
  {$IFDEF Unix} LCLIntf, LCLType, {$ENDIF}
  dglOpenGL, KromOGLUtils, KromUtils, Math, KM_TGATexture;

type
  TCardinalArray = array of Cardinal;
  TTexFormat = (tf_Normal, tf_AltID, tf_AlphaTest);

  TRenderMode = (rm2D, rm3D);

  //General OpenGL handling
  TRenderSetup = class
  private
    h_DC: HDC;
    h_RC: HGLRC;
    fOpenGL_Vendor, fOpenGL_Renderer, fOpenGL_Version: AnsiString;
    fScreenX, fScreenY: Word;
  public
    constructor Create(RenderFrame: HWND; ScreenX,ScreenY: Integer; aVSync: Boolean);
    destructor Destroy; override;

    procedure SetRenderMode(aRenderMode: TRenderMode); //Switch between 2D and 3D perspectives

    function GenTexture(DestX, DestY: Word; const Data: TCardinalArray; Mode: TTexFormat):GLUint;

    property RendererVersion: AnsiString read fOpenGL_Version;
    procedure Resize(Width,Height: Integer);

    property ScreenX: Word read fScreenX;
    property ScreenY: Word read fScreenY;

    procedure BeginFrame;
    procedure EndFrame;
  end;


  var
    fRenderSetup: TRenderSetup;


implementation
uses KM_Log;


constructor TRenderSetup.Create(RenderFrame: HWND; ScreenX,ScreenY: Integer; aVSync: Boolean);
begin
  Inherited Create;

  SetRenderFrame(RenderFrame, h_DC, h_RC);
  SetRenderDefaults;
  glDisable(GL_LIGHTING); //We don't need it

  fOpenGL_Vendor   := glGetString(GL_VENDOR);   fLog.AddToLog('OpenGL Vendor: '   + String(fOpenGL_Vendor));
  fOpenGL_Renderer := glGetString(GL_RENDERER); fLog.AddToLog('OpenGL Renderer: ' + String(fOpenGL_Renderer));
  fOpenGL_Version  := glGetString(GL_VERSION);  fLog.AddToLog('OpenGL Version: '  + String(fOpenGL_Version));

  SetupVSync(aVSync);
  BuildFont(h_DC, 16, FW_BOLD);

  Resize(ScreenX, ScreenY);
end;


destructor TRenderSetup.Destroy;
begin
  {$IFDEF MSWindows}
  wglMakeCurrent(h_DC, 0);
  wglDeleteContext(h_RC);
  {$ENDIF}
  {$IFDEF Unix}
    //?
  {$ENDIF}
  inherited;
end;


procedure TRenderSetup.Resize(Width, Height: Integer);
begin
  fScreenX := max(Width, 1);
  fScreenY := max(Height, 1);
  glViewport(0, 0, fScreenX, fScreenY);
end;


procedure TRenderSetup.SetRenderMode(aRenderMode: TRenderMode);
begin
  glMatrixMode(GL_PROJECTION); //Change Matrix Mode to Projection
  glLoadIdentity; //Reset View
  case aRenderMode of
    rm2D: gluOrtho2D(0, fScreenX, fScreenY, 0);
    rm3D: gluPerspective(80, -fScreenX/fScreenY, 0.1, 5000.0);
  end;
  glMatrixMode(GL_MODELVIEW); //Return to the modelview matrix
  glLoadIdentity; //Reset View
end;


//Generate texture out of TCardinalArray
function TRenderSetup.GenTexture(DestX, DestY: Word; const Data: TCardinalArray; Mode: TTexFormat): GLUint;
begin
  Result := 0;

  DestX := MakePOT(DestX);
  DestY := MakePOT(DestY);
  if DestX*DestY = 0 then exit; //Do not generate zeroed textures

  Result := GenerateTextureCommon; //Should be called prior to glTexImage2D or gluBuild2DMipmaps

  //todo: @Krom: Make textures support an alpha channel for nice shadows. How does it work for houses on top of AlphaTest?
  case Mode of
    //Houses under construction
    tf_AlphaTest: glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA,    DestX, DestY, 0, GL_RGBA, GL_UNSIGNED_BYTE, Data);
    //Base layer
    tf_Normal:    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB5_A1, DestX, DestY, 0, GL_RGBA, GL_UNSIGNED_BYTE, Data);
    //Team color layer
    tf_AltID:     glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA2,   DestX, DestY, 0, GL_RGBA, GL_UNSIGNED_BYTE, Data);
  end;
end;


procedure TRenderSetup.BeginFrame;
begin
  glClear(GL_COLOR_BUFFER_BIT); //Clear The Screen, can save some FPS on this one

  //RC.Activate for OSX
end;


procedure TRenderSetup.EndFrame;
begin
  glFinish;
  {$IFDEF MSWindows}
  SwapBuffers(h_DC);
  {$ENDIF}
  {$IFDEF Unix}
  glXSwapBuffers(FDisplay, FDC);
  {$ENDIF}
end;


end.