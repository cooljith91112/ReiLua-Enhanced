#!/usr/bin/env python3
"""
Embed multiple Lua files into a C header file for inclusion in the executable.
Usage: python embed_lua.py <output.h> <file1.lua> [file2.lua] [file3.lua] ...

Embeds all specified Lua files into a C header with a virtual filesystem.
The first file is treated as main.lua (entry point).
"""
import sys
import os

def sanitize_name(filename):
    """Convert filename to valid C identifier"""
    name = os.path.basename(filename)
    name = name.replace('.', '_').replace('-', '_').replace('/', '_').replace('\\', '_')
    return name

def embed_files(output_file, input_files):
    with open(output_file, 'w') as f:
        f.write('#ifndef EMBEDDED_MAIN_H\n')
        f.write('#define EMBEDDED_MAIN_H\n\n')
        f.write('/* Auto-generated file - do not edit manually */\n\n')
        
        # Embed each file as a separate array
        for idx, input_file in enumerate(input_files):
            with open(input_file, 'rb') as inf:
                data = inf.read()
            
            var_name = sanitize_name(input_file)
            # Get relative path for better module loading
            # Try to extract path relative to common directories
            relative_name = input_file
            for prefix in ['build/', 'build\\']:
                if prefix in input_file:
                    parts = input_file.split(prefix, 1)
                    if len(parts) > 1:
                        relative_name = parts[1]
                        break
            
            f.write(f'/* Embedded file: {relative_name} */\n')
            f.write(f'static const unsigned char embedded_lua_{idx}_{var_name}[] = {{\n')
            
            for i, byte in enumerate(data):
                if i % 12 == 0:
                    f.write('    ')
                f.write(f'0x{byte:02x}')
                if i < len(data) - 1:
                    f.write(',')
                    if (i + 1) % 12 == 0:
                        f.write('\n')
                    else:
                        f.write(' ')
            
            f.write('\n};\n')
            f.write(f'static const unsigned int embedded_lua_{idx}_{var_name}_len = {len(data)};\n\n')
        
        # Create the file table
        f.write('/* File table for virtual filesystem */\n')
        f.write('typedef struct {\n')
        f.write('    const char* name;\n')
        f.write('    const unsigned char* data;\n')
        f.write('    unsigned int size;\n')
        f.write('} EmbeddedLuaFile;\n\n')
        
        f.write('static const EmbeddedLuaFile embedded_lua_files[] = {\n')
        for idx, input_file in enumerate(input_files):
            var_name = sanitize_name(input_file)
            # Store relative path for proper require() support
            relative_name = input_file
            for prefix in ['build/', 'build\\']:
                if prefix in input_file:
                    parts = input_file.split(prefix, 1)
                    if len(parts) > 1:
                        relative_name = parts[1]
                        break
            # Normalize path separators
            relative_name = relative_name.replace('\\', '/')
            f.write(f'    {{ "{relative_name}", embedded_lua_{idx}_{var_name}, embedded_lua_{idx}_{var_name}_len }},\n')
        f.write('};\n\n')
        
        f.write(f'static const int embedded_lua_file_count = {len(input_files)};\n\n')
        
        # Main entry point (first file with 'main.lua' in name, or first file)
        main_idx = 0
        for idx, input_file in enumerate(input_files):
            if 'main.lua' in input_file.lower():
                main_idx = idx
                break
        
        var_name = sanitize_name(input_files[main_idx])
        f.write('/* Main entry point */\n')
        f.write(f'#define embedded_main_lua embedded_lua_{main_idx}_{var_name}\n')
        f.write(f'#define embedded_main_lua_len embedded_lua_{main_idx}_{var_name}_len\n\n')
        
        f.write('#endif /* EMBEDDED_MAIN_H */\n')

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print('Usage: python embed_lua.py <output.h> <file1.lua> [file2.lua] ...')
        print('  The first Lua file is treated as the main entry point.')
        sys.exit(1)
    
    output_file = sys.argv[1]
    input_files = sys.argv[2:]
    
    # Check all input files exist
    for f in input_files:
        if not os.path.exists(f):
            print(f'Error: File not found: {f}')
            sys.exit(1)
    
    embed_files(output_file, input_files)
    print(f'Embedded {len(input_files)} file(s) into {output_file}')
    for f in input_files:
        print(f'  - {f}')

