set( CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake )
include( CMakeDependentOption )
include( EnumOption )

cmake_minimum_required( VERSION 3.9 )

# Try to read custom project name from project.info
set( PROJECT_NAME_VAR "ReiLua" )
if( EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/project.info" )
	file( STRINGS "${CMAKE_CURRENT_SOURCE_DIR}/project.info" PROJECT_INFO_LINES )
	foreach( LINE ${PROJECT_INFO_LINES} )
		if( LINE MATCHES "^EXECUTABLE_NAME=(.+)$" )
			set( PROJECT_NAME_VAR "${CMAKE_MATCH_1}" )
			message( STATUS "Using custom executable name: ${PROJECT_NAME_VAR}" )
		endif()
	endforeach()
endif()

project( ${PROJECT_NAME_VAR} )

# Find Python interpreter (python3 or python)
find_package(Python3 COMPONENTS Interpreter)
if(Python3_FOUND)
	set(PYTHON_EXECUTABLE ${Python3_EXECUTABLE})
else()
	find_program(PYTHON_EXECUTABLE NAMES python3 python)
	if(NOT PYTHON_EXECUTABLE)
		message(FATAL_ERROR "Python not found. Please install Python 3.")
	endif()
endif()

# To make web build
# cmake .. -DCMAKE_TOOLCHAIN_FILE=<YOUR PATH HERE>/emsdk/upstream/emscripten/cmake/Modules/Platform/Emscripten.cmake -DPLATFORM=Web

set( CMAKE_C_STANDARD 99 ) # Requires C99 standard

option( SHARED "Build using dynamic libraries." off )
option( LUAJIT "Use LuaJIT." off )
option( LUA_EVENTS "Enable Lua event callbacks (RL.event)." off )
option( DYNAMIC_SYMBOLS "Expose all dynamic symbols with rdynamic." off )
option( EXPOSE_API_SYMBOLS "Expose dynamic symbols only for get and push functions of variable types." off )
option( EMBED_MAIN "Embed all Lua files from build directory into executable." off )
option( EMBED_ASSETS "Embed all files from assets folder into executable." off )

enum_option( PLATFORM "Desktop;Desktop_SDL2;Desktop_SDL3;Web" "Platform to build for." )

if( NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES )
	set( CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build." FORCE )
	set_property( CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo" )
endif()

# Set compiler flags for Release builds
if( CMAKE_BUILD_TYPE STREQUAL "Release" )
	add_definitions( -DNDEBUG )
	message( STATUS "Release build - logging disabled by default" )
endif()

file( GLOB SOURCES src/*.c )

# Always embed logo files for splash screens
set( LOGO_FILES 
	"${CMAKE_SOURCE_DIR}/logo/raylib_logo.png"
	"${CMAKE_SOURCE_DIR}/logo/reilua_logo.png"
)

add_custom_command(
	OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/embedded_logo.h
	COMMAND ${PYTHON_EXECUTABLE} ${CMAKE_SOURCE_DIR}/scripts/embed_logo.py 
		${CMAKE_CURRENT_BINARY_DIR}/embedded_logo.h 
		${CMAKE_SOURCE_DIR}/logo/raylib_logo.png 
		${CMAKE_SOURCE_DIR}/logo/reilua_logo.png
	DEPENDS ${LOGO_FILES}
	COMMENT "Embedding logo files for splash screens..."
)
list( APPEND SOURCES ${CMAKE_CURRENT_BINARY_DIR}/embedded_logo.h )
set( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DEMBED_LOGO" )

# Always embed font file
set( FONT_FILE "${CMAKE_SOURCE_DIR}/fonts/Oleaguid.ttf" )

add_custom_command(
	OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/embedded_font.h
	COMMAND ${PYTHON_EXECUTABLE} ${CMAKE_SOURCE_DIR}/scripts/embed_font.py 
		${CMAKE_CURRENT_BINARY_DIR}/embedded_font.h 
		${CMAKE_SOURCE_DIR}/fonts/Oleaguid.ttf
	DEPENDS ${FONT_FILE}
	COMMENT "Embedding font file..."
)
list( APPEND SOURCES ${CMAKE_CURRENT_BINARY_DIR}/embedded_font.h )
set( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DEMBED_FONT" )

include_directories( ${CMAKE_CURRENT_BINARY_DIR} )
include_directories( include )

# Add Windows resource file for icon and exe details
if( WIN32 )
	list( APPEND SOURCES ${CMAKE_SOURCE_DIR}/resources.rc )
endif()

# Embed Lua files if EMBED_MAIN is ON (recursively from all subdirectories)
if( EMBED_MAIN )
	file( GLOB_RECURSE LUA_FILES "${CMAKE_CURRENT_BINARY_DIR}/*.lua" )
	if( LUA_FILES )
		add_custom_command(
			OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/embedded_main.h
			COMMAND ${PYTHON_EXECUTABLE} ${CMAKE_SOURCE_DIR}/scripts/embed_lua.py ${CMAKE_CURRENT_BINARY_DIR}/embedded_main.h ${LUA_FILES}
			DEPENDS ${LUA_FILES}
			COMMENT "Embedding Lua files from all subdirectories into executable..."
		)
		list( APPEND SOURCES ${CMAKE_CURRENT_BINARY_DIR}/embedded_main.h )
		set( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DEMBED_MAIN" )
	else()
		message( WARNING "EMBED_MAIN is ON but no .lua files found in build directory!" )
	endif()
endif()

# Embed all non-Lua data files if EMBED_ASSETS is ON (from all subdirectories except CMake dirs)
# Always create embedded_assets.h to prevent compilation errors
if( EMBED_ASSETS )
	# Find all non-Lua files recursively, excluding build system files
	file( GLOB_RECURSE ALL_DATA_FILES 
		"${CMAKE_CURRENT_BINARY_DIR}/*"
	)
	# Filter out unwanted files
	set( ASSET_FILES "" )
	foreach( FILE_PATH ${ALL_DATA_FILES} )
		# Exclude: .lua files (handled separately), build artifacts, and CMake files
		if( NOT FILE_PATH MATCHES "\\.lua$" 
			AND NOT FILE_PATH MATCHES "CMakeFiles" 
			AND NOT FILE_PATH MATCHES "\\.cmake$"
			AND NOT FILE_PATH MATCHES "CMakeCache"
			AND NOT FILE_PATH MATCHES "Makefile$"
			AND NOT FILE_PATH MATCHES "\\.a$"
			AND NOT FILE_PATH MATCHES "\\.o$"
			AND NOT FILE_PATH MATCHES "embedded_.*\\.h$"
			AND NOT FILE_PATH MATCHES "\\.exe$"
			AND NOT FILE_PATH MATCHES "ReiLua$" )
			list( APPEND ASSET_FILES ${FILE_PATH} )
		endif()
	endforeach()
	
	if( ASSET_FILES )
		add_custom_command(
			OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/embedded_assets.h
			COMMAND ${PYTHON_EXECUTABLE} ${CMAKE_SOURCE_DIR}/scripts/embed_assets.py ${CMAKE_CURRENT_BINARY_DIR}/embedded_assets.h ${ASSET_FILES}
			DEPENDS ${ASSET_FILES}
			COMMENT "Embedding data files from all subdirectories into executable..."
		)
		set( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DEMBED_ASSETS" )
		message( STATUS "Embedding ${CMAKE_CURRENT_BINARY_DIR}/embedded_assets.h with asset files" )
	else()
		# Create empty embedded_assets.h to prevent compilation errors
		message( STATUS "EMBED_ASSETS is ON but no data files found, creating empty embedded_assets.h" )
		add_custom_command(
			OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/embedded_assets.h
			COMMAND ${PYTHON_EXECUTABLE} ${CMAKE_SOURCE_DIR}/scripts/create_empty_assets.py ${CMAKE_CURRENT_BINARY_DIR}/embedded_assets.h
			COMMENT "Creating empty embedded_assets.h (no data files to embed)"
		)
		set( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DEMBED_ASSETS" )
	endif()
	list( APPEND SOURCES ${CMAKE_CURRENT_BINARY_DIR}/embedded_assets.h )
else()
	# EMBED_ASSETS is OFF - create empty header for compatibility
	message( STATUS "EMBED_ASSETS is OFF, creating empty embedded_assets.h" )
	add_custom_command(
		OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/embedded_assets.h
		COMMAND ${PYTHON_EXECUTABLE} ${CMAKE_SOURCE_DIR}/scripts/create_empty_assets.py ${CMAKE_CURRENT_BINARY_DIR}/embedded_assets.h
		COMMENT "Creating empty embedded_assets.h (EMBED_ASSETS is OFF)"
	)
	list( APPEND SOURCES ${CMAKE_CURRENT_BINARY_DIR}/embedded_assets.h )
endif()

add_executable( ${PROJECT_NAME} ${SOURCES} )

if( PLATFORM STREQUAL "Desktop" )
	set( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DPLATFORM_DESKTOP" )
elseif( PLATFORM STREQUAL "Desktop_SDL2" )
	set( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DPLATFORM_DESKTOP_SDL2" )
elseif( PLATFORM STREQUAL "Desktop_SDL3" )
	set( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DPLATFORM_DESKTOP_SDL3" )
elseif( PLATFORM STREQUAL "Web" )
	set( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DPLATFORM_WEB" )
endif()

if( LUA_EVENTS )
	set( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DLUA_EVENTS" )
endif()

if( DYNAMIC_SYMBOLS )
	set( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -rdynamic" )
endif()

if( PLATFORM STREQUAL "Web" )
	target_link_libraries( ${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/lib/web/libraylib.a )
	target_link_libraries( ${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/lib/web/liblua.a )

	# Try "-s USE_PTHREADS" if not getting pixel perfect rendering.
	set( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -s USE_GLFW=3 -s ASSERTIONS=1 -s WASM=1 -s ASYNCIFY" )
	# set( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -s USE_GLFW=3 -s ASSERTIONS=1 -s WASM=1 -s ASYNCIFY -s FORCE_FILESYSTEM=1" )
	set( CMAKE_EXECUTABLE_SUFFIX ".html" ) # This line is used to set your executable to build with the emscripten html template so that you can directly open it.
	set( resources_dir "resources@/" ) # Sets resources as root for the virtual file system.
	set_target_properties( ${PROJECT_NAME} PROPERTIES LINK_FLAGS "--preload-file ${resources_dir}" )
else() # Desktop
	if( APPLE )
		# macOS: Try static libraries first, fall back to Homebrew if not available
		if( EXISTS "${CMAKE_SOURCE_DIR}/lib/macos/libraylib.a" AND EXISTS "${CMAKE_SOURCE_DIR}/lib/macos/liblua.a" )
			# Static libraries available - use them for single-file distribution
			message( "macOS - Using static libraries (single-file distribution)" )
			set( CMAKE_C_COMPILER "clang" )
			set( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fobjc-arc" )
			
			target_link_libraries( ${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/lib/macos/libraylib.a )
			target_link_libraries( ${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/lib/macos/liblua.a )
			
			# macOS frameworks required for raylib
			target_link_libraries( ${PROJECT_NAME} "-framework IOKit" )
			target_link_libraries( ${PROJECT_NAME} "-framework Cocoa" )
			target_link_libraries( ${PROJECT_NAME} "-framework OpenGL" )
			target_link_libraries( ${PROJECT_NAME} "-framework CoreFoundation" )
		else()
			# Use Homebrew shared libraries (for development)
			message( "macOS - Using Homebrew shared libraries (development mode)" )
			message( "    To build for distribution, run: ./scripts/macos/build_static_libs.sh" )
			
			set( CMAKE_C_COMPILER "clang" )
			set( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DSHARED -fobjc-arc" )
			
			# Find and link Raylib
			find_package(PkgConfig REQUIRED)
			pkg_check_modules(RAYLIB REQUIRED raylib)
			include_directories(${RAYLIB_INCLUDE_DIRS})
			target_link_libraries(${PROJECT_NAME} ${RAYLIB_LIBRARIES})
			
			# Find and link Lua
			pkg_check_modules(LUA REQUIRED lua)
			include_directories(${LUA_INCLUDE_DIRS})
			target_link_libraries(${PROJECT_NAME} ${LUA_LIBRARIES})
			
			# Find and link GLFW
			pkg_check_modules(GLFW REQUIRED glfw3)
			include_directories(${GLFW_INCLUDE_DIRS})
			target_link_libraries(${PROJECT_NAME} ${GLFW_LIBRARIES})

			# macOS frameworks
			target_link_libraries( ${PROJECT_NAME} "-framework IOKit" )
			target_link_libraries( ${PROJECT_NAME} "-framework Cocoa" )
			target_link_libraries( ${PROJECT_NAME} "-framework OpenGL" )
			target_link_libraries( ${PROJECT_NAME} "-framework CoreFoundation" )
		endif()
	elseif( SHARED )
		# Linux/Windows with shared libraries
		message( Shared )
		set( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DSHARED" )
		# find_package( raylib 5.0 REQUIRED ) # Requires at least version 5.0
		target_link_libraries( ${PROJECT_NAME} raylib )

		if( LUAJIT )
			set( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DLUAJIT" )
			target_link_libraries( ${PROJECT_NAME} luajit )
		else()
			target_link_libraries( ${PROJECT_NAME} lua )
		endif()
	else()
		# Static linking (Windows/Linux)
		message( Static )
		target_link_libraries( ${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/lib/libraylib.a )

		if( LUAJIT )
			set( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DLUAJIT" )
			target_link_libraries( ${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/lib/libluajit.a )
		else()
			target_link_libraries( ${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/lib/liblua.a )
		endif()
	endif()

	if( UNIX AND NOT APPLE )
		set( CMAKE_C_COMPILER "gcc" )

		if( EXPOSE_API_SYMBOLS )
			set( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DEXPOSE_LUA_API_SYMBOLS -rdynamic -fvisibility=hidden" )
		endif()

		if ( PLATFORM MATCHES "Desktop_SDL2" )
			include( FindPkgConfig )
			pkg_search_module( SDL2 REQUIRED sdl2 )
			include_directories( ${SDL2_INCLUDE_DIRS} )
			target_link_libraries( ${PROJECT_NAME} ${SDL2_LIBRARIES} )
		elseif ( PLATFORM MATCHES "Desktop_SDL3" )
			include( FindPkgConfig )
			pkg_search_module( SDL3 REQUIRED sdl3 )
			include_directories( ${SDL3_INCLUDE_DIRS} )
			target_link_libraries( ${PROJECT_NAME} ${SDL3_LIBRARIES} )
		endif()

		if( DRM ) # For Raspberry Pi.
			# target_link_libraries( ${PROJECT_NAME} GLESv2 EGL drm gbm rt bcm_host m dl pthread )
			# target_link_libraries( ${PROJECT_NAME} GLESv2 EGL drm gbm pthread rt m dl )
			target_link_libraries( ${PROJECT_NAME} raylib GLESv2 EGL pthread rt m gbm drm dl atomic )
		else()
			# target_link_libraries( ${PROJECT_NAME} m dl pthread )
			if( NOT APPLE )
				target_link_libraries( ${PROJECT_NAME} m dl pthread glfw )
			endif()
		endif()
	elseif( WIN32 )
		if( EXPOSE_API_SYMBOLS )
			set( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DEXPOSE_LUA_API_SYMBOLS" )
		endif()

		if ( PLATFORM MATCHES "Desktop_SDL2" )
			find_package( SDL2 REQUIRED )
			include_directories( ${SDL2_INCLUDE_DIRS} )
			target_link_libraries( ${PROJECT_NAME} ${SDL2MAIN_LIBRARIES} )
			target_link_libraries( ${PROJECT_NAME} ${SDL2_LIBRARIES} )
		elseif ( PLATFORM MATCHES "Desktop_SDL3" )
			find_package( SDL3 REQUIRED )
			include_directories( ${SDL3_INCLUDE_DIRS} )
			target_link_libraries( ${PROJECT_NAME} ${SDL3MAIN_LIBRARIES} )
			target_link_libraries( ${PROJECT_NAME} ${SDL3_LIBRARIES} )
		endif()
		# Remove this to get console. //TODO Could be build option.
		set( CMAKE_C_FLAGS ${CMAKE_C_FLAGS} "-mwindows" )
		target_link_libraries( ${PROJECT_NAME} mingw32 opengl32 gdi32 winmm )
	endif()
endif()
