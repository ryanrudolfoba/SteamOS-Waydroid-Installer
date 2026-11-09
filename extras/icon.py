#!/usr/bin/env python3
import os
import re
import struct
import sys

ICON_PATH = "/usr/share/icons/hicolor/512x512/apps/waydroid.png"

def read_cstring(fp):
    chars = []
    while (c := fp.read(1)) and c != b'\x00':
        chars.append(c)
    return b''.join(chars).decode('utf-8', errors='replace')

def parse_binary_vdf(fp):
    stack = [{}]
    while True:
        t = fp.read(1)
        if not t:
            break
        if t == b'\x08':
            if len(stack) > 1:
                stack.pop()
            else:
                break
            continue
        key = read_cstring(fp)
        cur = stack[-1]
        if t == b'\x00':
            new = {}
            cur[key] = new
            stack.append(new)
        elif t == b'\x01':
            cur[key] = read_cstring(fp)
        elif t == b'\x02':
            cur[key] = struct.unpack('<i', fp.read(4))[0]
        elif t == b'\x03':
            cur[key] = struct.unpack('<f', fp.read(4))[0]
        elif t == b'\x07':
            cur[key] = struct.unpack('<Q', fp.read(8))[0]
        elif t == b'\x0A':
            cur[key] = struct.unpack('<q', fp.read(8))[0]
        else:
            raise ValueError(f"Unknown type byte {t} for key '{key}'")
    return stack[0]

def write_cstring(fp, s):
    fp.write(s.encode('utf-8') + b'\x00')

def write_binary_vdf(fp, d):
    for k, v in d.items():
        if isinstance(v, dict):
            fp.write(b'\x00')
            write_cstring(fp, k)
            write_binary_vdf(fp, v)
            fp.write(b'\x08')
        elif isinstance(v, str):
            fp.write(b'\x01')
            write_cstring(fp, k)
            write_cstring(fp, v)
        elif isinstance(v, int):
            fp.write(b'\x02')
            write_cstring(fp, k)
            fp.write(struct.pack('<i', v))
        elif isinstance(v, float):
            fp.write(b'\x03')
            write_cstring(fp, k)
            fp.write(struct.pack('<f', v))
        else:
            raise ValueError(f"Unsupported value type: {type(v)} for key {k}")

def get_steamid3():
    home = os.path.expanduser("~")
    login_paths = [
        os.path.join(home, ".steam", "root", "config", "loginusers.vdf"),
        os.path.join(home, ".local", "share", "Steam", "config", "loginusers.vdf"),
    ]
    print(f"ℹ Checking loginusers.vdf in: {login_paths}")
    vdf_login = next((p for p in login_paths if os.path.isfile(p)), None)
    if not vdf_login:
        print("Could not find loginusers.vdf")
        sys.exit(1)

    with open(vdf_login, "r", encoding="utf-8", errors="ignore") as f:
        content = f.read()

    matches = re.findall(r'"(\d{17})"\s*{([^}]+)}', content)
    best = {"steamid64": None, "timestamp": 0}
    for sid, blk in matches:
        ts_match = re.search(r'"Timestamp"\s+"(\d+)"', blk)
        ts = int(ts_match.group(1)) if ts_match else 0
        if re.search(r'"MostRecent"\s+"1"', blk) or ts > best["timestamp"]:
            best = {"steamid64": int(sid), "timestamp": ts}
    if not best["steamid64"]:
        print("No SteamID64 found")
        sys.exit(1)

    steamid3 = best["steamid64"] - 76561197960265728
    return steamid3

def update_icon(shortcuts_path, target_app="Waydroid", icon_path=ICON_PATH):
    print(f"ℹ Updating shortcuts.vdf: {shortcuts_path}")
    if not os.path.isfile(shortcuts_path):
        print(f"Missing shortcuts.vdf: {shortcuts_path}")
        sys.exit(1)

    # Check file permissions and owner
    st = os.stat(shortcuts_path)

    with open(shortcuts_path, "rb") as f:
        data = parse_binary_vdf(f)

    shortcuts = data.get("shortcuts", data)
    for idx, (key, sc) in enumerate(shortcuts.items()):
        if isinstance(sc, dict):
            icon = sc.get("icon", "<no Icon>")
            appname = sc.get("AppName", "<no AppName>")
            exe = sc.get("Exe", "<no Exe>")

    updated = False
    for key, sc in shortcuts.items():
        if isinstance(sc, dict) and sc.get("AppName") == target_app:
            old_icon = sc.get("icon", "<none>")
            sc["icon"] = icon_path
            print(f"   New Icon set to: {icon_path}")
            updated = True
            break

    if not updated:
        print(f"No matching shortcut found for '{target_app}'")
        return

    with open(shortcuts_path, "wb") as f:
        write_binary_vdf(f, data)
        f.write(b'\x08')
        f.flush()
        os.fsync(f.fileno())

    print("shortcuts.vdf successfully updated and saved.")

if __name__ == "__main__":
    steamid3 = get_steamid3()
    home = os.path.expanduser("~")
    shortcuts_vdf = os.path.join(home, f".steam/root/userdata/{steamid3}/config/shortcuts.vdf")
    update_icon(shortcuts_vdf)
