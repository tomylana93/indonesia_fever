#!/usr/bin/env python3
"""Run Lua industry checks against installed TF2 resources; never start or edit the game."""
import argparse
import ctypes
import ctypes.util
import json
import os
import re
from zipfile import ZipFile
from pathlib import Path

root = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--game-res', type=Path, default=Path.home() / 'snap/steam/common/.local/share/Steam/steamapps/common/Transport Fever 2/res')
args = parser.parse_args()
base = args.game_res.resolve()
if not (base / 'scripts/industryutil.lua').is_file():
    parser.error('--game-res must contain the installed game scripts/industryutil.lua')
library = ctypes.util.find_library('lua5.4') or ctypes.util.find_library('lua5.3')
if not library:
    parser.error('Install a Lua 5.3/5.4 shared library to run these offline checks')
lua = ctypes.CDLL(library)
lua.luaL_newstate.restype = ctypes.c_void_p
lua.luaL_openlibs.argtypes = [ctypes.c_void_p]
lua.luaL_loadstring.argtypes = [ctypes.c_void_p, ctypes.c_char_p]
lua.lua_pcallk.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_ssize_t, ctypes.c_void_p]
lua.lua_tolstring.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.POINTER(ctypes.c_size_t)]
lua.lua_tolstring.restype = ctypes.c_char_p
lua.lua_close.argtypes = [ctypes.c_void_p]
os.chdir(root)
state = lua.luaL_newstate()
lua.luaL_openlibs(state)
quote = lambda s: json.dumps(str(s))
# TF2 ships stock models/materials/textures in archives. Treat these exactly as
# read-only resources; Workshop is deliberately excluded to catch dependencies.
resources = set()
for archive in base.rglob('*.zip'):
    with ZipFile(archive) as bundle:
        prefix = archive.parent.relative_to(base)
        resources.update((prefix / name).as_posix() for name in bundle.namelist() if not name.endswith('/'))
for folder in (root / 'res', base):
    resources.update(p.relative_to(folder).as_posix() for p in folder.rglob('*') if p.is_file())
asset_errors = []
reference_count = 0
prefixes = {'.mdl': 'models/model/', '.mtl': 'models/material/', '.msh': 'models/mesh/', '.dds': 'textures/', '.tga': 'textures/'}
asset_sources = list(Path('res/construction/industry').rglob('*.con')) + list(Path('res/models').rglob('*')) + list(Path('res/config/cargo_types').glob('*.lua')) + list(Path('res/config/ground_texture').rglob('*.lua')) + list(Path('res/config/terrain_material').rglob('*.lua'))
for path in asset_sources:
    if path.suffix not in {'.con', '.mdl', '.mtl', '.lua'}:
        continue
    source = re.sub(r'--\[(=*)\[.*?\]\1\]', '', path.read_text(errors='replace'), flags=re.S)
    source = re.sub(r'--[^\n]*', '', source)
    for name in re.findall(r'"([^"\n]+\.(?:mdl|mtl|msh|dds|tga))"', source):
        reference_count += 1
        resource = name[4:] if name.startswith('res/') else prefixes[Path(name).suffix] + name
        if resource not in resources:
            asset_errors.append(f'{path}: {resource}')
print(f'Asset references: {reference_count}; missing: {len(set(asset_errors))}', flush=True)
if asset_errors:
    raise SystemExit('\n'.join(sorted(set(asset_errors))))
files = sorted(p.as_posix() for p in Path('res/construction/industry').glob('*.con'))
syntax = sorted(p.as_posix() for p in Path('.').rglob('*') if p.is_file() and p.suffix in {'.lua', '.con', '.mdl', '.mtl', '.gtex', '.gen'})
source = '\n'.join([
    'GAME_RES = ' + quote(base),
    'INDUSTRY_FILES = {' + ','.join(map(quote, files)) + '}',
    'CARGO_FILES = {' + ','.join(map(quote, sorted(Path('res/config/cargo_types').glob('*.lua')))) + '}',
    'SYNTAX_FILES = {' + ','.join(map(quote, syntax)) + '}',
    'dofile("tests/industries.lua")',
]).encode()
try:
    code = lua.luaL_loadstring(state, source) or lua.lua_pcallk(state, 0, 0, 0, 0, None)
    if code:
        raise SystemExit(lua.lua_tolstring(state, -1, None).decode())
finally:
    lua.lua_close(state)
