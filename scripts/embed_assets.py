#!/usr/bin/env python3
"""
Embed asset files (images, sounds, fonts, etc.) into a C header file.
Usage: python embed_assets.py <output.h> <file1.png> [file2.wav] [file3.ttf] ...

Embeds all specified asset files into a C header for inclusion in the executable.
"""
import sys
import os

def sanitize_name(filename):
    """Convert filename to valid C identifier"""
    name = os.path.basename(filename)
    # Remove or replace all non-alphanumeric characters (except underscore)
    valid_chars = []
    for char in name:
        if char.isalnum() or char == '_':
            valid_chars.append(char)
        else:
            valid_chars.append('_')
    name = ''.join(valid_chars)
    # Ensure it doesn't start with a digit
    if name and name[0].isdigit():
        name = '_' + name
    return name

def get_file_extension(filename):
    """Get the file extension"""
    return os.path.splitext(filename)[1].lower()

def embed_files(output_file, input_files):
    with open(output_file, 'w') as f:
        f.write('#ifndef EMBEDDED_ASSETS_H\n')
        f.write('#define EMBEDDED_ASSETS_H\n\n')
        f.write('/* Auto-generated file - do not edit manually */\n\n')
        
        # Embed each file as a separate array
        for idx, input_file in enumerate(input_files):
            with open(input_file, 'rb') as inf:
                data = inf.read()
            
            var_name = sanitize_name(input_file)
            # Extract relative path from 'assets/' onwards if present
            if 'assets' in input_file.replace('\\', '/'):
                parts = input_file.replace('\\', '/').split('assets/')
                if len(parts) > 1:
                    relative_name = 'assets/' + parts[-1]
                else:
                    relative_name = os.path.basename(input_file)
            else:
                relative_name = os.path.basename(input_file)
            
            f.write(f'/* Embedded asset: {input_file} ({len(data)} bytes) */\n')
            f.write(f'static const unsigned char embedded_asset_{idx}_{var_name}[] = {{\n')
            
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
            f.write(f'static const unsigned int embedded_asset_{idx}_{var_name}_len = {len(data)};\n\n')
        
        # Create the asset table
        f.write('/* Asset table for virtual filesystem */\n')
        f.write('typedef struct {\n')
        f.write('    const char* name;\n')
        f.write('    const unsigned char* data;\n')
        f.write('    unsigned int size;\n')
        f.write('} EmbeddedAsset;\n\n')
        
        f.write('static const EmbeddedAsset embedded_assets[] = {\n')
        for idx, input_file in enumerate(input_files):
            var_name = sanitize_name(input_file)
            # Extract relative path from 'assets/' onwards if present
            if 'assets' in input_file.replace('\\', '/'):
                parts = input_file.replace('\\', '/').split('assets/')
                if len(parts) > 1:
                    relative_name = 'assets/' + parts[-1]
                else:
                    relative_name = os.path.basename(input_file)
            else:
                relative_name = os.path.basename(input_file)
            f.write(f'    {{ "{relative_name}", embedded_asset_{idx}_{var_name}, embedded_asset_{idx}_{var_name}_len }},\n')
        f.write('};\n\n')
        
        f.write(f'static const int embedded_asset_count = {len(input_files)};\n\n')
        f.write('#endif /* EMBEDDED_ASSETS_H */\n')

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print('Usage: python embed_assets.py <output.h> <asset1> [asset2] ...')
        print('  Embeds images, sounds, fonts, and other asset files into a C header.')
        print('  Supported: .png, .jpg, .wav, .ogg, .mp3, .ttf, .otf, etc.')
        sys.exit(1)
    
    output_file = sys.argv[1]
    input_files = sys.argv[2:]
    
    # Check all input files exist
    for f in input_files:
        if not os.path.exists(f):
            print(f'Error: File not found: {f}')
            sys.exit(1)
    
    embed_files(output_file, input_files)
    print(f'Embedded {len(input_files)} asset file(s) into {output_file}')
    for f in input_files:
        size = os.path.getsize(f)
        print(f'  - {f} ({size} bytes)')
