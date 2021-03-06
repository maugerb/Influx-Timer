#include <sourcemod>

#include <influx/core>
#include <influx/hud>

#include <msharedutil/misc>


#undef REQUIRE_PLUGIN
#include <influx/help>
#include <influx/recording>
#include <influx/strafes>
#include <influx/jumps>
#include <influx/pause>
#include <influx/practise>
//#include <influx/strfsync>
#include <influx/truevel>
#include <influx/zones_stage>
#include <influx/zones_checkpoint>
#include <influx/maprankings>
#include <influx/style_tas>


//#define DEBUG


// LIBRARIES
bool g_bLib_Strafes;
bool g_bLib_Jumps;
bool g_bLib_Pause;
bool g_bLib_Practise;
bool g_bLib_Recording;
//bool g_bLib_StrfSync;
bool g_bLib_Truevel;
bool g_bLib_Stage;
bool g_bLib_CP;
bool g_bLib_MapRanks;
bool g_bLib_Style_Tas;


public Plugin myinfo =
{
    author = INF_AUTHOR,
    url = INF_URL,
    name = INF_NAME..." - HUD | Draw CS:GO",
    description = "Displays info on player's screen.",
    version = INF_VERSION
};

public APLRes AskPluginLoad2( Handle hPlugin, bool late, char[] szError, int error_len )
{
    if ( GetEngineVersion() != Engine_CSGO )
    {
        FormatEx( szError, error_len, "Bad engine version!" );
        
        return APLRes_Failure;
    }
    
    return APLRes_Success;
}

public void OnPluginStart()
{
    // LIBRARIES
    g_bLib_Strafes = LibraryExists( INFLUX_LIB_STRAFES );
    g_bLib_Jumps = LibraryExists( INFLUX_LIB_JUMPS );
    g_bLib_Pause = LibraryExists( INFLUX_LIB_PAUSE );
    g_bLib_Practise = LibraryExists( INFLUX_LIB_PRACTISE );
    g_bLib_Recording = LibraryExists( INFLUX_LIB_RECORDING );
    //g_bLib_StrfSync = LibraryExists( INFLUX_LIB_STRFSYNC );
    g_bLib_Truevel = LibraryExists( INFLUX_LIB_TRUEVEL );
    g_bLib_Stage = LibraryExists( INFLUX_LIB_ZONES_STAGE );
    g_bLib_CP = LibraryExists( INFLUX_LIB_ZONES_CP );
    g_bLib_MapRanks = LibraryExists( INFLUX_LIB_MAPRANKS );
    g_bLib_Style_Tas = LibraryExists( INFLUX_LIB_STYLE_TAS );
}

public void OnLibraryAdded( const char[] lib )
{
    if ( StrEqual( lib, INFLUX_LIB_STRAFES ) ) g_bLib_Strafes = true;
    if ( StrEqual( lib, INFLUX_LIB_JUMPS ) ) g_bLib_Jumps = true;
    if ( StrEqual( lib, INFLUX_LIB_PAUSE ) ) g_bLib_Pause = true;
    if ( StrEqual( lib, INFLUX_LIB_PRACTISE ) ) g_bLib_Practise = true;
    if ( StrEqual( lib, INFLUX_LIB_RECORDING ) ) g_bLib_Recording = true;
    if ( StrEqual( lib, INFLUX_LIB_TRUEVEL ) ) g_bLib_Truevel = true;
    if ( StrEqual( lib, INFLUX_LIB_ZONES_STAGE ) ) g_bLib_Stage = true;
    if ( StrEqual( lib, INFLUX_LIB_ZONES_CP ) ) g_bLib_CP = true;
    if ( StrEqual( lib, INFLUX_LIB_MAPRANKS ) ) g_bLib_MapRanks = true;
    if ( StrEqual( lib, INFLUX_LIB_STYLE_TAS ) ) g_bLib_Style_Tas = true;
}

public void OnLibraryRemoved( const char[] lib )
{
    if ( StrEqual( lib, INFLUX_LIB_STRAFES ) ) g_bLib_Strafes = false;
    if ( StrEqual( lib, INFLUX_LIB_JUMPS ) ) g_bLib_Jumps = false;
    if ( StrEqual( lib, INFLUX_LIB_PAUSE ) ) g_bLib_Pause = false;
    if ( StrEqual( lib, INFLUX_LIB_PRACTISE ) ) g_bLib_Practise = false;
    if ( StrEqual( lib, INFLUX_LIB_RECORDING ) ) g_bLib_Recording = false;
    //if ( StrEqual( lib, INFLUX_LIB_STRFSYNC ) ) g_bLib_StrfSync = false;
    if ( StrEqual( lib, INFLUX_LIB_TRUEVEL ) ) g_bLib_Truevel = false;
    if ( StrEqual( lib, INFLUX_LIB_ZONES_STAGE ) ) g_bLib_Stage = false;
    if ( StrEqual( lib, INFLUX_LIB_ZONES_CP ) ) g_bLib_CP = false;
    if ( StrEqual( lib, INFLUX_LIB_MAPRANKS ) ) g_bLib_MapRanks = false;
    if ( StrEqual( lib, INFLUX_LIB_STYLE_TAS ) ) g_bLib_Style_Tas = false;
}

public Action Influx_OnDrawHUD( int client, int target, HudType_t hudtype )
{
    static char szMsg[256];
    szMsg[0] = '\0';
    
    decl String:szTemp[32];
    decl String:szTemp2[32];
    decl String:szSecFormat[12];
    
    
    int hideflags = Influx_GetClientHideFlags( client );
    
    
    if ( hudtype == HUDTYPE_HINT )
    {
        Influx_GetSecondsFormat_Timer( szSecFormat, sizeof( szSecFormat ) );
        
        
        RunState_t state = Influx_GetClientState( target );
        
        if ( !(hideflags & HIDEFLAG_TIME) && state >= STATE_RUNNING )
        {
            float cptime = INVALID_RUN_TIME;
            
            if (g_bLib_CP
            &&  (GetEngineTime() - Influx_GetClientLastCPTouch( target )) < 2.0)
            {
                cptime = Influx_GetClientLastCPSRTime( target );
                
                // Fallback to best time if no SR time is found.
                if ( cptime == INVALID_RUN_TIME ) cptime = Influx_GetClientLastCPBestTime( target );
            }
            
            
            if ( state == STATE_FINISHED )
            {
                Inf_FormatSeconds( Influx_GetClientFinishedTime( target ), szTemp, sizeof( szTemp ), "%05.2f" );
                FormatEx( szMsg, sizeof( szMsg ), "Time: %s", szTemp );
            }
            else if ( g_bLib_Pause && Influx_IsClientPaused( target ) )
            {
                Inf_FormatSeconds( Influx_GetClientPausedTime( target ), szTemp, sizeof( szTemp ), "%05.2f" );
                FormatEx( szMsg, sizeof( szMsg ), "Time: %s", szTemp );
            }
            else if ( cptime != INVALID_RUN_TIME )
            {
                float time = Influx_GetClientLastCPTime( target );
                
                decl c;
                
                Inf_FormatSeconds( Inf_GetTimeDif( time, cptime, c ), szTemp2, sizeof( szTemp2 ), szSecFormat );
                
                
                FormatEx( szMsg, sizeof( szMsg ), "CP: <font color=\"#42f4a1\">%c%s</font>", c, szTemp2 );
            }
            else if ( g_bLib_Style_Tas && Influx_GetClientStyle( target ) == STYLE_TAS )
            {
                Inf_FormatSeconds( Influx_GetClientTASTime( target ), szTemp, sizeof( szTemp ), szSecFormat );
                FormatEx( szMsg, sizeof( szMsg ), "Time: %s", szTemp );
            }
            else
            {
                Inf_FormatSeconds( Influx_GetClientTime( target ), szTemp, sizeof( szTemp ), szSecFormat );
                FormatEx( szMsg, sizeof( szMsg ), "Time: <font color=\"#42f4a1\">%s</font>", szTemp );
            }
        }
        else if ( state == STATE_START )
        {
            Influx_GetRunName( Influx_GetClientRunId( target ), szTemp, sizeof( szTemp ) );
            FormatEx( szMsg, sizeof( szMsg ), "<font color=\"#4286f4\">In %s Start</font>", szTemp );
        }
        
        if ( !(hideflags & HIDEFLAG_SPEED) )
        {
            Format( szMsg, sizeof( szMsg ), "%s\n<font color=\"#4286f4\">Speed: %03.0f</font>",
                szMsg,
                GetSpeed( target ) );
        }
        
        
        bool bprac = ( g_bLib_Practise && !(hideflags & HIDEFLAG_PRACMODE) && Influx_IsClientPractising( target ) );
        
        bool bpause = ( g_bLib_Pause && !(hideflags & HIDEFLAG_PAUSEMODE) && Influx_IsClientPaused( target ) );
        
        if ( bprac || bpause )
        {
            Format( szMsg, sizeof( szMsg ), "%s%s<font color=\"#ff0000\">", szMsg, NEWLINE_CHECK( szMsg ) );
            
            
            if ( bprac )
            {
                Format( szMsg, sizeof( szMsg ), "%sPractising", szMsg );
            }
            
            if ( bpause )
            {
                Format( szMsg, sizeof( szMsg ), "%s%sPaused", szMsg, bprac ? "/" : "" );
            }
            
            
            Format( szMsg, sizeof( szMsg ), "%s</font>", szMsg );
        }
        

        
        
        if ( szMsg[0] != '\0' )
        {
            PrintHintText( client, szMsg );
        }
    }
    else if ( hudtype == HUDTYPE_MENU_CSGO )
    {
        Influx_GetSecondsFormat_Sidebar( szSecFormat, sizeof( szSecFormat ) );
        
        
        // Disable for bots.
        if ( IsFakeClient( target ) )
        {
            // Draw recording bot info.
            if ( g_bLib_Recording && Influx_GetReplayBot() == target )
            {
                float time = Influx_GetReplayTime();
                if ( time == INVALID_RUN_TIME ) return Plugin_Stop;
                
                
                decl String:szTime[12];
                
                
                
                Influx_GetModeName( Influx_GetReplayMode(), szTemp, sizeof( szTemp ), true );
                Influx_GetStyleName( Influx_GetReplayStyle(), szTemp2, sizeof( szTemp2 ), true );
                
                
                Inf_FormatSeconds( time, szTime, sizeof( szTime ), szSecFormat );
                
                
                decl String:szName[16];
                Influx_GetReplayName( szName, sizeof( szName ) );
                
                FormatEx( szMsg, sizeof( szMsg ), "%s%s%s\n \nTime: %s\nName: %s",
                    szTemp2, // Style
                    ( szTemp2[0] != '\0' ) ? " " : "",
                    szTemp, // Mode
                    szTime,
                    szName );
                
                
                ShowPanel( client, szMsg );
            }
            
            return Plugin_Stop;
        }
        
        
        if ( g_bLib_Stage && Influx_ShouldDisplayStages( client ) )
        {
            int stages = Influx_GetClientStageCount( target );
            
            if ( stages < 2 )
            {
                strcopy( szTemp2, sizeof( szTemp2 ), "Linear" );
            }
            else
            {
                FormatEx( szTemp2, sizeof( szTemp2 ), "%i/%i", Influx_GetClientStage( target ), stages );
            }
            
            FormatEx( szMsg, sizeof( szMsg ), "Stage: %s", szTemp2 );
        }
        
        if ( g_bLib_MapRanks )
        {
            int rank = Influx_GetClientCurrentMapRank( target );
            int numrecs = Influx_GetClientCurrentMapRankCount( target );
            
            if ( numrecs > 0 )
            {
                if ( rank > 0 )
                {
                    Format( szMsg, sizeof( szMsg ), "%s%sRank: %i/%i", szMsg, NEWLINE_CHECK( szMsg ), rank, numrecs );
                }
                else
                {
                    Format( szMsg, sizeof( szMsg ), "%s%sRank: ?/%i", szMsg, NEWLINE_CHECK( szMsg ), numrecs );
                }
            }
        }
        
        
        if ( !(hideflags & HIDEFLAG_PB_TIME) && Influx_IsClientCached( target ) )
        {
            float time = Influx_GetClientCurrentPB( target );
            
            if ( time > INVALID_RUN_TIME )
            {
                Inf_FormatSeconds( time, szTemp2, sizeof( szTemp2 ), szSecFormat );
                FormatEx( szTemp, sizeof( szTemp ), "PB: %s", szTemp2 );
            }
            else
            {
                strcopy( szTemp, sizeof( szTemp ), "PB: N/A" );
            }
            
            Format( szMsg, sizeof( szMsg ), "%s%s%s", szMsg, NEWLINE_CHECK( szMsg ), szTemp );
        }
        
        if ( !(hideflags & HIDEFLAG_WR_TIME) )
        {
            float time = Influx_GetClientCurrentBestTime( target );
            
            if ( time > INVALID_RUN_TIME )
            {
                decl String:szTemp3[32];
                
                Inf_FormatSeconds( time, szTemp2, sizeof( szTemp2 ), szSecFormat );
                Influx_GetClientCurrentBestName( target, szTemp3, sizeof( szTemp3 ) );
                
                LimitString( szTemp3, sizeof( szTemp3 ), 8 );
                
                
                FormatEx( szTemp, sizeof( szTemp ), "SR: %s (%s)", szTemp2, szTemp3 );
            }
            else
            {
                strcopy( szTemp, sizeof( szTemp ), "SR: N/A" );
            }
            
            Format( szMsg, sizeof( szMsg ), "%s%s%s",
                szMsg,
                NEWLINE_CHECK( szMsg ),
                szTemp );
        }
        
        
        ADD_SEPARATOR( szMsg, "\n " );
        
        
        RunState_t state = Influx_GetClientState( target );
        
        if ( g_bLib_Strafes && state >= STATE_RUNNING )
        {
            Format( szMsg, sizeof( szMsg ), "%s%sStrafes: %i",
                szMsg,
                NEWLINE_CHECK( szMsg ),
                Influx_GetClientStrafeCount( target ) );
        }
        
        if ( g_bLib_Jumps && state >= STATE_RUNNING )
        {
            Format( szMsg, sizeof( szMsg ), "%s%sJumps: %i",
                szMsg,
                NEWLINE_CHECK( szMsg ),
                Influx_GetClientJumpCount( target ) );
        }
        
        ShowPanel( client, szMsg );
    }
    
    return Plugin_Stop;
}

// Check if they want truevel.
stock float GetSpeed( int client )
{
    return ( g_bLib_Truevel && Influx_IsClientUsingTruevel( client ) ) ? GetEntityTrueSpeed( client ) : GetEntitySpeed( client );
}

stock void ShowPanel( int client, const char[] msg )
{
    Panel panel = new Panel();
    panel.SetTitle( msg );
    panel.Send( client, Hndlr_Panel_Empty, 3 );
    
    delete panel;
}

public int Hndlr_Panel_Empty( Menu menu, MenuAction action, int client, int param2 ) {}