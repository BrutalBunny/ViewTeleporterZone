class ViewTeleporterZone extends ZoneInfo;

var() bool bShouldDuck;

var() enum EViewDirectionTeleport
{
    LOOK_DOWN,
    LOOK_UP
} ViewDirectionTeleport;

var() int yDirectionTriggeringMinRange;

var() name TeleporterTag;
var Teleporter DestTeleporter;

struct PlayerInfo
{
    var PlayerPawn Player;        
    var bool bEnteredTeleportZone;
    var bool bIsTeleporting;
};
var PlayerInfo PInfo[32];

function PreBeginPlay()
{
    Super.PreBeginPlay();

    if ( TeleporterTag != '' )
        ForEach AllActors(class'Teleporter', DestTeleporter, TeleporterTag)
            break;
}

function tick(float DeltaTime) 
{
    local int i, yViewRotation;

    if( DestTeleporter == None ) return;

    for(i = 0; i < 32; i++) {
        if( PInfo[i].Player == None ) continue;
        if( !PInfo[i].bEnteredTeleportZone ) continue;
        if( PInfo[i].bIsTeleporting ) continue;
        if( bShouldDuck && !PInfo[i].Player.bIsCrouching ) continue;

        yViewRotation = PInfo[i].Player.ViewRotation.Pitch;

        if( ViewDirectionTeleport == LOOK_DOWN ){
            if( yViewRotation >= 49152 && yViewRotation < 65536 ){
                if( yViewRotation <= yDirectionTriggeringMinRange ){
                    PInfo[i].bIsTeleporting = true;

                    DestTeleporter.Touch(PInfo[i].Player);
                }
            }

        }

        if( ViewDirectionTeleport == LOOK_UP ){
            if( yViewRotation > 0 && yViewRotation <= 18000 ){
                if( yViewRotation >= yDirectionTriggeringMinRange ){
                    PInfo[i].bIsTeleporting = true;

                    DestTeleporter.Touch(PInfo[i].Player);
                }
            }
        }
    }
}

event ActorEntered( actor Other )
{
	local PlayerPawn PP;

	Log("ACTOR ENTERING");

    if( !Other.IsA('TournamentPlayer') && !Other.IsA('Bot') ) return;
    if( PlayerPawn(Other) == None ) return;

    PP = PlayerPawn(Other);

   	PInfo[PP.PlayerReplicationInfo.PlayerID].Player = PP;
    PInfo[PP.PlayerReplicationInfo.PlayerID].bEnteredTeleportZone = true;
}

event ActorLeaving( actor Other )
{
	local PlayerPawn PP;

	Super.ActorLeaving(Other);

	Log("ACTOR LEAVING");
    
    if( !Other.IsA('TournamentPlayer') && !Other.IsA('Bot') ) return;
    if( PlayerPawn(Other) == None ) return;

    PP = PlayerPawn(Other);

    PInfo[PP.PlayerReplicationInfo.PlayerID].Player = PP;
	PInfo[PP.PlayerReplicationInfo.PlayerID].bEnteredTeleportZone = false;
    PInfo[PP.PlayerReplicationInfo.PlayerID].bIsTeleporting = false;
}

defaultproperties {
	bStatic=False,
    bShouldDuck=True,
    ViewDirectionTeleport=LOOK_DOWN,
    yDirectionTriggeringMinRange=50000
}