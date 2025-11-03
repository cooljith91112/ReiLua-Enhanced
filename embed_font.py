#!/usr/bin/env python3
"""
Embed font file into C header.
Usage: python embed_font.py <output.h> <font.ttf>
"""

import sys
import os

def embed_file(file_path, var_name):
    """Convert a file to a C byte array"""
    with open(file_path, 'rb') as f:
        data = f.read()
    
    output = f"/* {os.path.basename(file_path)} */\n"
    output += f"static const unsigned char {var_name}[] = {{\n"
    
    # Write bytes in rows of 16
    for i in range(0, len(data), 16):
        chunk = data[i:i+16]
        hex_values = ', '.join(f'0x{b:02x}' for b in chunk)
        output += f"    {hex_values},\n"
    
    output += "};\n"
    output += f"static const unsigned int {var_name}_size = {len(data)};\n\n"
    
    return output

def main():
    if len(sys.argv) != 3:
        print("Usage: python embed_font.py <output.h> <font.ttf>")
        sys.exit(1)
    
    output_file = sys.argv[1]
    font_file = sys.argv[2]
    
    # Check if file exists
    if not os.path.exists(font_file):
        print(f"Error: {font_file} not found!")
        sys.exit(1)
    
    # Generate header content
    header_content = "/* Auto-generated embedded font file */\n"
    header_content += "#pragma once\n\n"
    
    # Embed font file
    header_content += embed_file(font_file, "embedded_font_data")
    
    # Write to output file
    with open(output_file, 'w') as f:
        f.write(header_content)
    
    print(f"Generated {output_file}")
    print(f"  - Embedded {font_file} ({os.path.getsize(font_file)} bytes)")

if __name__ == "__main__":
    main()
