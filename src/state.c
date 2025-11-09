#include "main.h"
#include "state.h"
#include "lua_core.h"
#include "textures.h"
#include "models.h"

#ifdef EMBED_FONT
	#include "embedded_font.h"
#endif

State* state;

bool stateInit( int argn, const char** argc, const char* basePath, bool enable_logging ) {
	state = malloc( sizeof( State ) );

	state->basePath = malloc( STRING_LEN * sizeof( char ) );
	strncpy( state->basePath, basePath, STRING_LEN - 1 );

	/* Ensure basePath ends with a slash */
	size_t len = strlen( state->basePath );
	if ( len > 0 && state->basePath[len - 1] != '/' && state->basePath[len - 1] != '\\' ) {
		if ( len < STRING_LEN - 2 ) {
			state->basePath[len] = '/';
			state->basePath[len + 1] = '\0';
		}
	}

	state->hasWindow = true;
	state->run = true;
	state->resolution = (Vector2){ 800, 600 };
	state->luaState = NULL;
	state->logLevelInvalid = LOG_ERROR;
	state->gcUnload = true;
	state->lineSpacing = 15;
	state->mouseOffset = (Vector2){ 0, 0 };
	state->mouseScale = (Vector2){ 1, 1 };
	state->customFontLoaded = false;

	/* Set log level based on build type and --log flag */
#ifdef NDEBUG
	/* Release build - only show warnings/errors unless --log is specified */
	if ( enable_logging ) {
		SetTraceLogLevel( LOG_INFO );
	}
	else {
		SetTraceLogLevel( LOG_WARNING );
	}
#else
	/* Debug/Dev build - always show all logs */
	SetTraceLogLevel( LOG_INFO );
#endif

	InitWindow( state->resolution.x, state->resolution.y, "ReiLua" );

	if ( !IsWindowReady() ) {
		state->hasWindow = false;
		state->run = false;
	}
	if ( state->run ) {
		state->run = luaInit( argn, argc );
	}

	/* Load custom default font */
#ifdef EMBED_FONT
	/* Load from embedded data */
	state->defaultFont = LoadFontFromMemory( ".ttf", embedded_font_data, embedded_font_data_size, 48, NULL, 0 );
	SetTextureFilter( state->defaultFont.texture, TEXTURE_FILTER_POINT );
	state->customFontLoaded = true;
#else
	/* Load from file (development mode) - try both executable directory and working directory */
	char fontPath[STRING_LEN];
	bool fontFound = false;
	
	/* Try executable directory first */
	snprintf( fontPath, STRING_LEN, "%s/fonts/Oleaguid.ttf", GetApplicationDirectory() );
	if ( FileExists( fontPath ) ) {
		fontFound = true;
	}
	else {
		/* Try working directory */
		snprintf( fontPath, STRING_LEN, "%s/fonts/Oleaguid.ttf", GetWorkingDirectory() );
		if ( FileExists( fontPath ) ) {
			fontFound = true;
		}
	}

	if ( fontFound ) {
		state->defaultFont = LoadFontEx( fontPath, 48, NULL, 0 );
		SetTextureFilter( state->defaultFont.texture, TEXTURE_FILTER_POINT );
		state->customFontLoaded = true;
		TraceLog( LOG_INFO, "Loaded custom font: %s", fontPath );
	}
	else {
		TraceLog( LOG_WARNING, "Custom font not found, using Raylib default font" );
		state->defaultFont = GetFontDefault();
		state->customFontLoaded = false;
	}
#endif

	state->guiFont = GuiGetFont();
	state->defaultMaterial = LoadMaterialDefault();
	state->defaultTexture = (Texture){ 1, 1, 1, 1, 7 };
	state->shapesTexture = (Texture){ 1, 1, 1, 1, 7 };
	state->RLGLcurrentShaderLocs = malloc( RL_MAX_SHADER_LOCATIONS * sizeof( int ) );
	int* defaultShaderLocs = rlGetShaderLocsDefault();

	for ( int i = 0; i < RL_MAX_SHADER_LOCATIONS; i++ ) {
		state->RLGLcurrentShaderLocs[i] = defaultShaderLocs[i];
	}
#if defined PLATFORM_DESKTOP_SDL2 || defined PLATFORM_DESKTOP_SDL3
	state->SDL_eventQueue = malloc( PLATFORM_SDL_EVENT_QUEUE_LEN * sizeof( SDL_Event ) );
	state->SDL_eventQueueLen = 0;
#endif

	return state->run;
}

/* Init after InitWindow. (When there is OpenGL context.) */
void stateContextInit() {
	/* This function is no longer needed as initialization is done in stateInit */
}

void stateInitInterpret( int argn, const char** argc ) {
	state = malloc( sizeof( State ) );
	luaInit( argn, argc );
}

void stateFree() {
	if ( IsAudioDeviceReady() ) {
		CloseAudioDevice();
	}
	if ( state->luaState != NULL ) {
		lua_close( state->luaState );
		state->luaState = NULL;
	}
	/* Unload custom font if it was loaded - must be done before CloseWindow */
	if ( state->hasWindow && state->customFontLoaded ) {
		UnloadFont( state->defaultFont );
	}
	if ( state->hasWindow ) {
		CloseWindow();
	}
#ifdef PLATFORM_DESKTOP_SDL
	free( state->SDL_eventQueue );
#endif
	free( state->basePath );
	free( state->RLGLcurrentShaderLocs );
	free( state );
}
