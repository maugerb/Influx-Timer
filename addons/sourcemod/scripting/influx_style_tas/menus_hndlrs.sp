public int Hndlr_TasMenu( Menu menu, MenuAction action, int client, int index )
{
    MENU_HANDLE( menu, action )
    
    
    if ( Influx_GetClientStyle( client ) != STYLE_TAS ) return 0;
    
    
    char szInfo[2];
    if ( !GetMenuItem( menu, index, szInfo, sizeof( szInfo ) ) ) return 0;
    
    
    switch ( szInfo[0] )
    {
        case 'a' :
        {
            SetFrame( client, g_iStoppedFrame[client] + 1, false, true );
            
            g_iPlayback[client] = 0;
        }
        case 'b' :
        {
            SetFrame( client, g_iStoppedFrame[client] - 1, false, true );
            
            g_iPlayback[client] = 0;
        }
        case 'c' :
        {
            ContinueOrStop( client );
        }
        case 'd' :
        {
            if ( ValidFrames( client ) )
            {
                StopClient( client );
                IncreasePlayback( client );
            }
        }
        case 'e' :
        {
            if ( ValidFrames( client ) )
            {
                StopClient( client );
                DecreasePlayback( client );
            }
        }
        case 'f' :
        {
            OpenSettingsMenu( client );
            return 0;
        }
    }
    
    OpenMenu( client );
    
    return 0;
}

public int Hndlr_Settings( Menu menu, MenuAction action, int client, int index )
{
    MENU_HANDLE( menu, action )
    
    
    if ( Influx_GetClientStyle( client ) != STYLE_TAS ) return 0;
    
    
    char szInfo[2];
    if ( !GetMenuItem( menu, index, szInfo, sizeof( szInfo ) ) ) return 0;
    
    
    switch ( szInfo[0] )
    {
        case 'a' :
        {
            if ( g_flTimescale[client] >= 1.0 )
            {
                SetTimescale( client, 0.25 );
            }
            else
            {
                IncreaseTimescale( client );
            }
        }
        case 'b' :
        {
            ChangeAutoStrafe( client );
        }
        case 'c' :
        {
            OpenCmdListMenu( client );
            return 0;
        }
        case 'd' :
        {
            OpenMenu( client );
            return 0;
        }
        case 'e' :
        {
            OpenLoadMenu( client );
            return 0;
        }
        case 'f' :
        {
            OpenSaveMenu( client );
            return 0;
        }
    }
    
    OpenSettingsMenu( client );
    
    return 0;
}

public int Hndlr_ListCmds( Menu menu, MenuAction action, int client, int index )
{
    MENU_HANDLE( menu, action )
    
    char szInfo[2];
    if ( !GetMenuItem( menu, index, szInfo, sizeof( szInfo ) ) ) return 0;
    
    
    switch ( szInfo[0] )
    {
        case 'a' :
        {
            OpenMenu( client );
            return 0;
        }
    }
    
    return 0;
}

public int Hndlr_TasLoad( Menu menu, MenuAction action, int client, int index )
{
    MENU_HANDLE( menu, action )
    
    if ( !CanUserLoadSaveTas( client ) ) return 0;
    
    char szInfo[32];
    if ( !GetMenuItem( menu, index, szInfo, sizeof( szInfo ) ) ) return 0;
    
    
    char bufs[3][12];
    if ( ExplodeString( szInfo, "_", bufs, sizeof( bufs ), sizeof( bufs[] ) ) < sizeof( bufs ) )
    {
        return 0;
    }
    
    int runid = StringToInt( bufs[0] );
    if ( Influx_GetClientRunId( client ) != runid ) return 0;
    
    
    int mode = StringToInt( bufs[1] );
    int style = StringToInt( bufs[2] );
    
    if (LoadFrames( client, g_hFrames[client], runid, mode, style )
    &&  Influx_SetClientMode( client, mode )
    &&  Influx_SetClientStyle( client, STYLE_TAS ))
    {
        SetFrame( client, g_hFrames[client].Length - 1, false, true );
        
        Influx_SetClientState( client, STATE_RUNNING );
        Influx_SetClientStartTick( client, GetGameTickCount() - (g_iStoppedFrame[client] + 1) );
        
        
        Influx_PrintToChat( _, client, "Loaded {MAINCLR1}%i{CHATCLR} frames from disk.", g_hFrames[client].Length );
    }
    
    return 0;
}

public int Hndlr_TasSave_Confirm( Menu menu, MenuAction action, int client, int index )
{
    MENU_HANDLE( menu, action )
    
    if ( !CanUserLoadSaveTas( client ) ) return 0;
    
    if ( index != 0 ) return 0;
    
    
    SaveFramesMsg( client );
    
    return 0;
}