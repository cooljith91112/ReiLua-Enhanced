#!/usr/bin/env python3
"""ReiLua Documentation Generator"""
import os, re
from pathlib import Path

HTML_TEMPLATE = '''<!DOCTYPE HTML><html><head><title>{title}</title>
<link rel="stylesheet" href="style.css"><meta charset="utf-8"></head><body>
<div class="container"><div class="navigation">
<a href="index.html">home</a> &middot; <a href="manual.html">manual</a> &middot; <a href="reference.html">reference</a>
</div>{content}<div class="footer"><p>ReiLua Enhanced &middot; <a href="https://indrajith.dev">indrajith.dev</a></p></div></div></body></html>'''

def fix_links(t):
    t=re.sub(r'\(([^)]+)\.md\)',r'(manual.html)',t)
    t=re.sub(r'\(docs/[^)]+\.md\)',r'(manual.html)',t)
    t=re.sub(r'\(\.\.\/docs\/[^)]+\.md\)',r'(manual.html)',t)
    return t

def md2html(md):
    h=fix_links(md)
    
    # Protect code blocks by replacing them with placeholders
    code_blocks = []
    def save_code(m):
        code_blocks.append(m.group(0))
        return f'___CODE_BLOCK_{len(code_blocks)-1}___'
    h=re.sub(r'```[^\n]*\n.*?```',save_code,h,flags=re.DOTALL)
    
    # Now process markdown (code is protected)
    # Headers - MUST be before bold/italic to avoid conflicts
    h=re.sub(r'^#### (.+)$',r'<h4>\1</h4>',h,flags=re.MULTILINE)
    h=re.sub(r'^### (.+)$',r'<h3>\1</h3>',h,flags=re.MULTILINE)
    h=re.sub(r'^## (.+)$',r'<h2>\1</h2>',h,flags=re.MULTILINE)
    h=re.sub(r'^# (.+)$',r'<h1>\1</h1>',h,flags=re.MULTILINE)
    
    # Links
    h=re.sub(r'\[([^\]]+)\]\(([^\)]+)\)',r'<a href="\2">\1</a>',h)
    
    # Bold/italic (after headers to avoid **text:** becoming headings)
    h=re.sub(r'\*\*([^\*]+)\*\*',r'<strong>\1</strong>',h)
    h=re.sub(r'\*([^\*\n]+)\*',r'<em>\1</em>',h)
    
    # Inline code
    h=re.sub(r'`([^`]+)`',r'<code>\1</code>',h)
    
    # Restore code blocks
    for i, block in enumerate(code_blocks):
        content = re.search(r'```[^\n]*\n(.*?)```', block, re.DOTALL).group(1)
        h = h.replace(f'___CODE_BLOCK_{i}___', f'<pre><code>{content}</code></pre>')
    
    # Process line by line for paragraphs and lists
    lines=h.split('\n')
    result=[]
    in_ul=False
    in_pre=False
    para_buffer=[]
    
    def flush_para():
        if para_buffer:
            result.append('<p>' + ' '.join(para_buffer) + '</p>')
            para_buffer.clear()
    
    for line in lines:
        s=line.strip()
        
        # Track pre blocks
        if '<pre>' in line:
            flush_para()
            in_pre=True
            result.append(line)
            continue
        if '</pre>' in line:
            in_pre=False
            result.append(line)
            continue
        if in_pre:
            result.append(line)
            continue
        
        # Handle list items
        if s.startswith(('- ','* ')):
            flush_para()
            if not in_ul:
                result.append('<ul>')
                in_ul=True
            item=re.sub(r'^[\-\*]\s+','',s)
            result.append(f'<li>{item}</li>')
            continue
        
        # End list if needed
        if in_ul and not s.startswith(('- ','* ')):
            result.append('</ul>')
            in_ul=False
        
        # Handle block elements
        if s.startswith('<h') or s.startswith('<div') or s.startswith('<hr'):
            flush_para()
            result.append(line)
            continue
        
        # Empty line = paragraph break
        if not s:
            flush_para()
            continue
        
        # Accumulate paragraph text
        if s and not s.startswith('<'):
            para_buffer.append(s)
        else:
            flush_para()
            result.append(line)
    
    # Flush remaining
    flush_para()
    if in_ul:
        result.append('</ul>')
    
    return '\n'.join(result)

def parse_api(f):
    with open(f,'r',encoding='utf-8') as fp: c=fp.read()
    secs=[]; cur=None; lines=c.split('\n'); i=0
    while i<len(lines):
        l=lines[i]; s=l.strip()
        if s.startswith('## ') and not s.startswith('###'):
            if cur and cur.get('items'): secs.append(cur)
            cur={'title':s.replace('##','').strip(),'items':[]}; i+=1; continue
        if s.startswith('>'):
            if not cur: cur={'title':'Definitions','items':[]}
            d=s.replace('>','').strip(); desc=[]; i+=1
            while i<len(lines):
                n=lines[i]; ns=n.strip()
                if ns.startswith('>') or (ns.startswith('##') and not ns.startswith('###')): break
                if ns=='---': i+=1; break
                desc.append(n); i+=1
            cur['items'].append({'definition':d,'description':'\n'.join(desc).strip()}); continue
        i+=1
    if cur and cur.get('items'): secs.append(cur)
    return secs

out=Path(__file__).parent
(out/'index.html').write_text(HTML_TEMPLATE.format(title='ReiLua',content='<h1>ReiLua Enhanced</h1><p>Lua binding for Raylib.</p><h2>Documentation</h2><ul><li><a href="manual.html">Manual</a></li><li><a href="reference.html">API Reference</a></li></ul><h2>Quick Start</h2><p>Create <code>main.lua</code>:</p><pre><code>function RL.init()\n  RL.SetWindowTitle("Hello")\nend\n\nfunction RL.update(dt)\nend\n\nfunction RL.draw()\n  RL.ClearBackground(RL.RAYWHITE)\n  RL.DrawText("Hello!",190,200,20,RL.BLACK)\nend</code></pre><p>Run: <code>ReiLua.exe</code></p>'),encoding='utf-8')
print('✓ index.html')

parts=['<h1>ReiLua Manual</h1>']
readme=Path('../README.md')
if readme.exists():
    parts.append(md2html(re.sub(r'!\[.*?\]\(.*?\)','',readme.read_text(encoding='utf-8'))))
    parts.append('<hr>')
for fp,t in [('../docs/EMBEDDING.md','Embedding'),('../docs/ASSET_LOADING.md','Asset Loading'),('../docs/SPLASH_SCREENS.md','Splash Screens'),('../docs/BUILD_SCRIPTS.md','Build Scripts'),('../docs/CUSTOMIZATION.md','Customization'),('../docs/ZED_EDITOR_SETUP.md','Editor Setup')]:
    p=Path(fp)
    if p.exists():
        a=t.lower().replace(' ','-')
        parts.append(f'<h2 id="{a}">{t}</h2>')
        parts.append(md2html(p.read_text(encoding='utf-8')))
        parts.append('<hr>')
(out/'manual.html').write_text(HTML_TEMPLATE.format(title='Manual',content='\n'.join(parts)),encoding='utf-8')
print('✓ manual.html')

secs=parse_api(Path('../docs/API.md'))
parts=['<h1>ReiLua API Reference</h1><p>Complete function reference.</p><h2>Contents</h2><ul>']
for s in secs:
    a=s['title'].lower().replace(' ','-').replace('/','').replace('.','')
    parts.append(f'<li><a href="#{a}">{s["title"]}</a> ({len(s["items"])} items)</li>')
parts.append('</ul>')
for s in secs:
    a=s['title'].lower().replace(' ','-').replace('/','').replace('.','')
    parts.append(f'<h2 id="{a}">{s["title"]}</h2>')
    for i in s['items']:
        parts.append(f'<div class="apii"><code>{i["definition"]}</code></div>')
        if i['description']:
            parts.append(f'<div class="apidesc">{md2html(i["description"])}</div>')
(out/'reference.html').write_text(HTML_TEMPLATE.format(title='API Reference',content='\n'.join(parts)),encoding='utf-8')
print(f'✓ reference.html ({sum(len(s["items"]) for s in secs)} items)')
print('Complete!')
