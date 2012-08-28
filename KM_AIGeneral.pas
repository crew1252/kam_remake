unit KM_AIGeneral;
{$I KaM_Remake.inc}
interface
uses
  Classes, KromUtils, Math, SysUtils,
  KM_Defaults, KM_CommonClasses, KM_Points, KM_AISetup;


type
  TKMGeneral = class
  private
    //fOwner: TPlayerIndex;
    //fSetup: TKMPlayerAISetup;

    procedure CheckDefences;
  public
    constructor Create(aPlayer: TPlayerIndex; aSetup: TKMPlayerAISetup);
    destructor Destroy; override;

    procedure AfterMissionInit;
    procedure OwnerUpdate(aPlayer: TPlayerIndex);

    procedure UpdateState;
    procedure Save(SaveStream: TKMemoryStream);
    procedure Load(LoadStream: TKMemoryStream);
  end;


implementation
uses KM_Game, KM_Houses, KM_PlayersCollection, KM_Player, KM_Terrain, KM_Resource, KM_Utils;


{ TKMGeneral }
constructor TKMGeneral.Create(aPlayer: TPlayerIndex; aSetup: TKMPlayerAISetup);
begin

end;

destructor TKMGeneral.Destroy;
begin

  inherited;
end;

procedure TKMGeneral.AfterMissionInit;
begin

end;

procedure TKMGeneral.Load(LoadStream: TKMemoryStream);
begin

end;

procedure TKMGeneral.OwnerUpdate(aPlayer: TPlayerIndex);
begin

end;

procedure TKMGeneral.Save(SaveStream: TKMemoryStream);
begin

end;


procedure TKMGeneral.CheckDefences;
begin
  //Get defence outline with weights representing how important each segment is

  //Compare existing defence positions with the sample
    //Get the ratio between sample and existing troops
    //Check all segments to have proportional troops count
    //Add or remove defence positions
end;


procedure TKMGeneral.UpdateState;
begin
  //Manage defence positions
  CheckDefences;
end;

end.
