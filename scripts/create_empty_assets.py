#!/usr/bin/env python3
"""
Create an empty embedded_assets.h file for compatibility.
Usage: python create_empty_assets.py <output.h>
"""
import sys

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print('Usage: python create_empty_assets.py <output.h>')
        sys.exit(1)
    
    output_file = sys.argv[1]
    
    with open(output_file, 'w') as f:
        f.write('#ifndef EMBEDDED_ASSETS_H\n')
        f.write('#define EMBEDDED_ASSETS_H\n')
        f.write('/* No assets to embed */\n')
        f.write('typedef struct { const char* name; const unsigned char* data; unsigned int size; } EmbeddedAsset;\n')
        f.write('static const EmbeddedAsset embedded_assets[] = {};\n')
        f.write('static const int embedded_asset_count = 0;\n')
        f.write('#endif\n')
    
    print(f'Created empty {output_file}')
