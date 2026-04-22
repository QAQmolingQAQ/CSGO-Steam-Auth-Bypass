


[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Bypass CS:GO (Legacy) IP validation for servers behind NAT/FRP using SourceMod memory patching.



---

## 📖  Introduction

When a CS:GO (Legacy) server **lacks a public IP** and is exposed via NAT or tunneling tools like FRP/NPS, clients may be rejected with the error `STEAM validation rejected` in the server console.

This occurs because the Valve engine validates that the client's reported IP address matches the actual connection IP. Tunneling causes a mismatch, triggering the rejection.

This project uses **memory patching** to modify the validation function inside `engine.dll`, forcing it to always return success, thereby bypassing the IP check.

> ⚠️ **Warning**: This project is **intended for community servers only**. Do NOT use on any VAC-secured official server, as it may result in a ban.

---

## 🔧  How It Works



Through reverse engineering, the core validation function `sub_101BEFA0` inside `engine.dll` was located. This function performs a series of checks (including IP consistency) and returns a boolean (1 = success, 0 = failure).

This project uses a SourceMod plugin to dynamically replace the function's prologue with:

```assembly
mov eax, 1    ; Return 1 (success) immediately
retn
```

This completely bypasses the internal IP check logic.

---

## 🧠  Reverse Engineering Methodology

If you need to reproduce this method on other versions or bypass different validation logic, follow this approach:

1. **Locate failure log**: Load `engine.dll` in IDA Pro and search for the string `"STEAM validation rejected"`.
2. **Trace call chain**: Use cross-references (Ctrl+X) to find the function referencing this string—typically a failure dispatch handler (e.g., `sub_101BEDD0`).
3. **Trace upwards**: Find cross-references to that failure handler and locate its caller. Look for a pattern where a `call` to a validation function is immediately followed by `test al, al` or `test eax, eax` and a conditional jump.
4. **Identify the core validation function**: The function being `call`ed in that pattern (in this case, `sub_101BEFA0`) is the patch target.
5. **Craft the patch**: Modify the function's prologue to immediately return success (`mov eax, 1; retn`).

---


## 🚀 安装与使用 / Installation & Usage

### Requirements

- SourceMod 1.10  or higher
-  Only for **CS:GO (Legacy version)**

###  Steps

1.  *Place `ip_fix.smx` into the server's `csgo/addons/sourcemod/plugins/` directory.*

2. *Place `ip_fix.games.txt` into the server's `csgo/addons/sourcemod/gamedata/` directory.*

3. *Restart the server, or run `sm plugins load ip_fix` in the console.*

### Verification

- *Run `sm plugins list` in the server console; `ip_fix.smx` should show as **Loaded**.*

- *Check server logs—no `STEAM validation rejected` errors should appear.*

- *Have a friend behind NAT/FRP try to connect; they should succeed.*

---

## ⚠️  Disclaimer

This project is for educational and research purposes only, intended to address technical limitations of community servers behind NAT/tunneling. **Do NOT use on Valve official servers**. Users assume all responsibility for any consequences resulting from improper use.

---

## 📄  License


This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.

---

## 🙇  Acknowledgments

 Special thanks to the following projects for inspiration:

- [NoLobbyReservation](https://github.com/vanz666/NoLobbyReservation)
- [csgo-sv-fix-engine](https://github.com/eonexdev/csgo-sv-fix-engine)

---

 This project was primarily generated with the assistance of DeepSeek.*
```
