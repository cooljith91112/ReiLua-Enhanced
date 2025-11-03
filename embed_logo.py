#!/usr/bin/env python3
"""
Embed logo image files into C header for splash screens.
Usage: python embed_logo.py <output.h> <raylib_logo.png> <reilua_logo.png>
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
    if len(sys.argv) != 4:
        print("Usage: python embed_logo.py <output.h> <raylib_logo.png> <reilua_logo.png>")
        sys.exit(1)
    
    output_file = sys.argv[1]
    raylib_logo = sys.argv[2]
    reilua_logo = sys.argv[3]
    
    # Check if files exist
    if not os.path.exists(raylib_logo):
        print(f"Error: {raylib_logo} not found!")
        sys.exit(1)
    
    if not os.path.exists(reilua_logo):
        print(f"Error: {reilua_logo} not found!")
        sys.exit(1)
    
    # Generate header content
    header_content = "/* Auto-generated embedded logo files */\n"
    header_content += "#pragma once\n\n"
    
    # Embed both logo files
    header_content += embed_file(raylib_logo, "embedded_raylib_logo")
    header_content += embed_file(reilua_logo, "embedded_reilua_logo")
    
    # Write to output file
    with open(output_file, 'w') as f:
        f.write(header_content)
    
    print(f"Generated {output_file}")
    print(f"  - Embedded {raylib_logo} ({os.path.getsize(raylib_logo)} bytes)")
    print(f"  - Embedded {reilua_logo} ({os.path.getsize(reilua_logo)} bytes)")

if __name__ == "__main__":
    main()
