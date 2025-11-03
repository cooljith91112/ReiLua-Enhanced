#include "main.h"
#include "state.h"
#include "splash.h"

#ifdef EMBED_LOGO
	#include "embedded_logo.h"
#endif

#define FADE_IN_TIME 0.8f
#define DISPLAY_TIME 2.5f
#define FADE_OUT_TIME 0.8f
#define SPLASH_TOTAL_TIME (FADE_IN_TIME + DISPLAY_TIME + FADE_OUT_TIME)

typedef enum {
	SPLASH_INDRAJITH,
	SPLASH_MADE_WITH,
	SPLASH_DONE
} SplashState;

static SplashState currentSplash = SPLASH_INDRAJITH;
static float splashTimer = 0.0f;
static Texture2D raylibLogo = { 0 };
static Texture2D reiluaLogo = { 0 };
static bool logosLoaded = false;

static float getSplashAlpha( float timer ) {
	if ( timer < FADE_IN_TIME ) {
		return timer / FADE_IN_TIME;
	}
	else if ( timer < FADE_IN_TIME + DISPLAY_TIME ) {
		return 1.0f;
	}
	else {
		float fadeOut = timer - FADE_IN_TIME - DISPLAY_TIME;
		return 1.0f - ( fadeOut / FADE_OUT_TIME );
	}
}

static void loadSplashLogos() {
	if ( logosLoaded ) return;
	
#ifdef EMBED_LOGO
	/* Load from embedded data */
	Image raylib_img = LoadImageFromMemory( ".png", embedded_raylib_logo, embedded_raylib_logo_size );
	raylibLogo = LoadTextureFromImage( raylib_img );
	UnloadImage( raylib_img );
	
	Image reilua_img = LoadImageFromMemory( ".png", embedded_reilua_logo, embedded_reilua_logo_size );
	reiluaLogo = LoadTextureFromImage( reilua_img );
	UnloadImage( reilua_img );
#else
	/* Load from files (development mode) */
	if ( FileExists( "logo/raylib_logo.png" ) ) {
		raylibLogo = LoadTexture( "logo/raylib_logo.png" );
	}
	if ( FileExists( "logo/reilua_logo.png" ) ) {
		reiluaLogo = LoadTexture( "logo/reilua_logo.png" );
	}
#endif
	
	logosLoaded = true;
}

static void unloadSplashLogos() {
	if ( !logosLoaded ) return;
	
	UnloadTexture( raylibLogo );
	UnloadTexture( reiluaLogo );
	logosLoaded = false;
}

static void drawIndrajithSplash( float alpha ) {
	int screenWidth = GetScreenWidth();
	int screenHeight = GetScreenHeight();
	
	ClearBackground( (Color){ 230, 41, 55, 255 } ); // Raylib red
	
	const char* text = "INDRAJITH MAKES GAMES";
	int fontSize = 48;
	float spacing = 2.0f;
	
	Color textColor = WHITE;
	textColor.a = (unsigned char)(255 * alpha);
	
	/* Draw text with slight expansion effect during fade in */
	float scale = 0.95f + (alpha * 0.05f); // Subtle scale from 0.95 to 1.0
	
	/* Measure text with proper spacing for accurate centering */
	Vector2 textSize = MeasureTextEx( state->defaultFont, text, fontSize * scale, spacing );
	
	/* Calculate centered position */
	Vector2 position = {
		(float)(screenWidth / 2) - (textSize.x / 2),
		(float)(screenHeight / 2) - (textSize.y / 2)
	};
	
	/* Draw with proper kerning */
	DrawTextEx( state->defaultFont, text, position, fontSize * scale, spacing, textColor );
}

static void drawMadeWithSplash( float alpha ) {
	int screenWidth = GetScreenWidth();
	int screenHeight = GetScreenHeight();
	
	ClearBackground( BLACK );
	
	/* "Made using" text at top */
	const char* madeText = "Made using";
	int madeSize = 32;
	int madeWidth = MeasureText( madeText, madeSize );
	
	Color textColor = WHITE;
	textColor.a = (unsigned char)(255 * alpha);
	
	int textY = screenHeight / 2 - 100;
	DrawText( madeText, screenWidth / 2 - madeWidth / 2, textY, madeSize, textColor );
	
	/* Calculate logo sizes and positions - scale down if too large */
	int maxLogoSize = 200;
	float raylibScale = 1.0f;
	float reiluaScale = 1.0f;
	
	if ( raylibLogo.id > 0 && raylibLogo.width > maxLogoSize ) {
		raylibScale = (float)maxLogoSize / (float)raylibLogo.width;
	}
	if ( reiluaLogo.id > 0 && reiluaLogo.width > maxLogoSize ) {
		reiluaScale = (float)maxLogoSize / (float)reiluaLogo.width;
	}
	
	int raylibWidth = (int)(raylibLogo.width * raylibScale);
	int raylibHeight = (int)(raylibLogo.height * raylibScale);
	int reiluaWidth = (int)(reiluaLogo.width * reiluaScale);
	int reiluaHeight = (int)(reiluaLogo.height * reiluaScale);
	
	/* Position logos side by side with spacing */
	int spacing = 40;
	int totalWidth = raylibWidth + spacing + reiluaWidth;
	int startX = screenWidth / 2 - totalWidth / 2;
	int logoY = screenHeight / 2 - 20;
	
	Color tint = WHITE;
	tint.a = (unsigned char)(255 * alpha);
	
	/* Draw Raylib logo */
	if ( raylibLogo.id > 0 ) {
		Rectangle source = { 0, 0, (float)raylibLogo.width, (float)raylibLogo.height };
		Rectangle dest = { (float)startX, (float)logoY, (float)raylibWidth, (float)raylibHeight };
		DrawTexturePro( raylibLogo, source, dest, (Vector2){ 0, 0 }, 0.0f, tint );
	}
	
	/* Draw ReiLua logo */
	if ( reiluaLogo.id > 0 ) {
		int reiluaX = startX + raylibWidth + spacing;
		Rectangle source = { 0, 0, (float)reiluaLogo.width, (float)reiluaLogo.height };
		Rectangle dest = { (float)reiluaX, (float)logoY, (float)reiluaWidth, (float)reiluaHeight };
		DrawTexturePro( reiluaLogo, source, dest, (Vector2){ 0, 0 }, 0.0f, tint );
	}
}

void splashInit() {
	loadSplashLogos();
	currentSplash = SPLASH_INDRAJITH;
	splashTimer = 0.0f;
}

bool splashUpdate( float delta ) {
	splashTimer += delta;
	
	if ( splashTimer >= SPLASH_TOTAL_TIME ) {
		splashTimer = 0.0f;
		currentSplash++;
	}
	
	return currentSplash >= SPLASH_DONE;
}

void splashDraw() {
	float alpha = getSplashAlpha( splashTimer );
	
	BeginDrawing();
	
	switch ( currentSplash ) {
		case SPLASH_INDRAJITH:
			drawIndrajithSplash( alpha );
			break;
		case SPLASH_MADE_WITH:
			drawMadeWithSplash( alpha );
			break;
		default:
			break;
	}
	
	EndDrawing();
}

void splashCleanup() {
	unloadSplashLogos();
}
