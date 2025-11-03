#include "main.h"
#include "state.h"
#include "lua_core.h"
#include "splash.h"

#ifdef _WIN32
// Forward declarations for Windows console functions
extern __declspec(dllimport) int __stdcall AllocConsole(void);
extern __declspec(dllimport) int __stdcall FreeConsole(void);
extern __declspec(dllimport) void* __stdcall GetStdHandle(unsigned long nStdHandle);
extern __declspec(dllimport) int __stdcall SetStdHandle(unsigned long nStdHandle, void* hHandle);
#endif

static inline void printVersion() {
	if ( VERSION_DEV ) {
		TraceLog( LOG_INFO, "ReiLua %d.%d.%d-Dev", VERSION_MAJOR, VERSION_MINOR, VERSION_PATCH );
	}
	else {
		TraceLog( LOG_INFO, "ReiLua %d.%d.%d", VERSION_MAJOR, VERSION_MINOR, VERSION_PATCH );
	}

#ifdef LUA_VERSION
	TraceLog( LOG_INFO, "%s", LUA_VERSION );
#endif

#ifdef LUAJIT_VERSION
	TraceLog( LOG_INFO, "%s", LUAJIT_VERSION );
#endif
}

int main( int argn, const char** argc ) {
	char basePath[ STRING_LEN ] = { '\0' };
	bool interpret_mode = false;
	bool show_console = false;
	bool skip_splash = false;

#ifdef _WIN32
	/* Check for --log and --no-logo arguments */
	for ( int i = 1; i < argn; i++ ) {
		if ( strcmp( argc[i], "--log" ) == 0 ) {
			show_console = true;
		}
		if ( strcmp( argc[i], "--no-logo" ) == 0 ) {
			skip_splash = true;
		}
	}

	/* Show or hide console based on --log argument */
	if ( show_console ) {
		/* Allocate a console if we don't have one */
		if ( AllocConsole() ) {
			freopen( "CONOUT$", "w", stdout );
			freopen( "CONOUT$", "w", stderr );
			freopen( "CONIN$", "r", stdin );
		}
	}
	else {
		/* Hide console window */
		FreeConsole();
	}
#else
	/* Check for --no-logo on non-Windows platforms */
	for ( int i = 1; i < argn; i++ ) {
		if ( strcmp( argc[i], "--no-logo" ) == 0 ) {
			skip_splash = true;
			break;
		}
	}
#endif

	if ( 1 < argn ) {
		/* Skip --log and --no-logo flags to find the actual command */
		int arg_index = 1;
		while ( arg_index < argn && ( strcmp( argc[arg_index], "--log" ) == 0 || strcmp( argc[arg_index], "--no-logo" ) == 0 ) ) {
			arg_index++;
		}
		
		if ( arg_index < argn && ( strcmp( argc[arg_index], "--version" ) == 0 || strcmp( argc[arg_index], "-v" ) == 0 ) ) {
			printVersion();
			return 1;
		}
		else if ( arg_index < argn && ( strcmp( argc[arg_index], "--help" ) == 0 || strcmp( argc[arg_index], "-h" ) == 0 ) ) {
			printf( "Usage: ReiLua [Options] [Directory to main.lua or main]\nOptions:\n-h --help\tThis help\n-v --version\tShow ReiLua version\n-i --interpret\tInterpret mode [File name]\n--log\t\tShow console for logging\n--no-logo\tSkip splash screens (development)\n" );
			return 1;
		}
		else if ( arg_index < argn && ( strcmp( argc[arg_index], "--interpret" ) == 0 || strcmp( argc[arg_index], "-i" ) == 0 ) ) {
			interpret_mode = true;

			if ( arg_index + 1 < argn ) {
				sprintf( basePath, "%s/%s", GetWorkingDirectory(), argc[arg_index + 1] );
			}
		}
		else if ( arg_index < argn ) {
			sprintf( basePath, "%s/%s", GetWorkingDirectory(), argc[arg_index] );
		}
		else {
			/* Only flags were provided, use default path search */
			char testPath[ STRING_LEN ] = { '\0' };
			sprintf( testPath, "%s/main.lua", GetWorkingDirectory() );
			
			if ( FileExists( testPath ) ) {
				sprintf( basePath, "%s", GetWorkingDirectory() );
			}
			else {
				sprintf( basePath, "%s", GetApplicationDirectory() );
			}
		}
	}
	/* If no argument given, check current directory first, then exe directory. */
	else {
		char testPath[ STRING_LEN ] = { '\0' };
		sprintf( testPath, "%s/main.lua", GetWorkingDirectory() );
		
		if ( FileExists( testPath ) ) {
			sprintf( basePath, "%s", GetWorkingDirectory() );
		}
		else {
			sprintf( basePath, "%s", GetApplicationDirectory() );
		}
	}

	if ( interpret_mode ) {
		stateInitInterpret( argn, argc );

		lua_State* L = state->luaState;
		lua_pushcfunction( L, luaTraceback );
		int tracebackidx = lua_gettop( L );

		luaL_loadfile( L, basePath );

		if ( lua_pcall( L, 0, 0, tracebackidx ) != 0 ) {
			TraceLog( LOG_ERROR, "Lua error: %s", lua_tostring( L, -1 ) );
			return false;
		}
	}
	else {
		printVersion();
		stateInit( argn, argc, basePath );
		
		/* Show splash screens if not skipped */
		if ( !skip_splash ) {
			splashInit();
			bool splashDone = false;
			
			while ( !splashDone && !WindowShouldClose() ) {
				float delta = GetFrameTime();
				splashDone = splashUpdate( delta );
				splashDraw();
			}
			
			splashCleanup();
		}
		
		/* Now run the main Lua program */
		state->run = luaCallMain();

		while ( state->run ) {
			if ( WindowShouldClose() ) {
				state->run = false;
			}
			luaCallUpdate();
			luaCallDraw();
		}
		luaCallExit();
	}
	stateFree();

	return 0;
}
