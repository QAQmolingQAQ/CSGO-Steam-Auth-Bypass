


[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Bypass CS:GO (Legacy) IP validation for servers behind NAT/FRP using SourceMod memory patching.



---

## 📖  Introduction

When a CS:GO (Legacy) server **lacks a public IP** and is exposed via NAT or tunneling tools like FRP/NPS, clients may be rejected with the error `STEAM validation rejected` in the server console.

This occurs because the Valve engine validates that the client's reported IP address matches the actual connection IP. Tunneling causes a mismatch, triggering the rejection.

This project uses **memory patching** to modify the validation function inside `engine.dll`, forcing it to always return success.

> ⚠️ **Warning**: This project is **intended for community servers only**. Do NOT use on any VAC-secured official server, as it may result in a ban.

---

## 🔧  How It Works

When a client connects, the CS:GO server validates the client's IP address with Steam. Behind FRP/NAT, the IP seen by the server differs from the actual client IP, causing Steam to return `Failure code 10`, and the server actively disconnects the client.

This plugin modifies the Steam authentication callback logic in `engine.dll` by changing the conditional jump (`jz`) on the authentication failure branch to an unconditional jump (`jmp`). This forces the server to follow the success path even when authentication fails, effectively bypassing the disconnect.

Linux `engine.so` gamedata offsets were provided by **f05tN1ko**. The Linux patch neutralizes the jump to the failure handler by replacing it with NOPs, allowing execution to fall through and continue along the success path.

```assembly
mov eax, 1    ; Return 1 (success) immediately
retn
```
## Technical Details

| Item | Value |
| :--- | :--- |
| Target File | `engine.dll` |
| Target Function | `ValidateAuthTicketResponse_t` callback |
| Function Signature | `\x55\x8B\xEC\x83\xE4\xF8\x81\xEC\x24\x02\x00\x00\x53\x56\x8B\xF1\x57` |
| Patch Offset | `+0x8D` |
| Original Bytes | `74` (`jz`) |
| Patch Bytes | `EB` (`jmp`) |

## Installation

1. Place `ip_fix.games.txt` into `csgo/addons/sourcemod/gamedata/`
2. Place `ip_fix.sp` into `csgo/addons/sourcemod/scripting/`
3. Compile the plugin:
   Drag `ip_fix.sp` onto `csgo\addons\sourcemod\scripting\compile.exe`.
   The compiled `ip_fix.smx` will be generated in `csgo\addons\sourcemod\scripting\compiled`.
   Move it to `csgo\addons\sourcemod\plugins`.

---

## 🧠  Reverse Engineering Methodology

If you need to reproduce this method on other versions or bypass different validation logic, follow this approach:

1. **Locate failure log**: Load `engine.dll` in IDA Pro and search for the string `"STEAM validation rejected"`.
2. **Trace call chain**: Use cross-references (Ctrl+X) to find the function referencing this string—typically a failure dispatch handler (e.g., `sub_101BEDD0`).
3. **Trace upwards**: Find cross-references to that failure handler and locate its caller. Look for a pattern where a `call` to a validation function is immediately followed by `test al, al` or `test eax, eax` and a conditional jump.
4. **Identify the core validation function**: The function being `call`ed in that pattern (in this case, `sub_101BEFA0`) is the patch target.
5. **Craft the patch**: Modify the function's prologue to immediately return success (`mov eax, 1; retn`).

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
