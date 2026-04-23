# CS:GO Steam Auth Bypass

绕过 CS:GO 服务器的 Steam 认证失败断开连接检测。适用于通过 FRP/NAT 穿透的社区服务器。

## 适用场景

- 使用 FRP/ngrok 等内网穿透工具搭建的 CS:GO 服务器
- 客户端通过公网连接时被服务器踢出，提示 `Client dropped by server`
- 服务器日志出现 `STEAMAUTH: Client ... received failure code 10`

## 原理

CS:GO 服务器在客户端连接时，会向 Steam 验证客户端的 IP 地址。当通过 FRP 等工具穿透时，服务器看到的客户端 IP 与实际 IP 不一致，导致 Steam 返回 `Failure code 10`，服务器主动断开连接。

本插件通过修改 `engine.dll` 中的 Steam 认证回调逻辑，将认证失败分支的 `jz`（条件跳转）改为 `jmp`（无条件跳转），使认证失败时仍然走成功分支，从而绕过断开连接。

## 技术细节

| 项目 | 值 |
| :--- | :--- |
| 目标文件 | `engine.dll` |
| 目标函数 | `ValidateAuthTicketResponse_t` 回调 |
| 函数特征码 | `\x55\x8B\xEC\x83\xE4\xF8\x81\xEC\x24\x02\x00\x00\x53\x56\x8B\xF1\x57` |
| 修改偏移 | `+0x8D` |
| 原始字节 | `74`（`jz`） |
| 补丁字节 | `EB`（`jmp`） |

## 安装

1. 将 `ip_fix.games.txt` 放入 `csgo/addons/sourcemod/gamedata/`
2. 将 `ip_fix.sp` 放入 `csgo/addons/sourcemod/scripting/`
3. 编译插件：
   ```bash
   cd csgo/addons/sourcemod/scripting
   spcomp ip_fix.sp -o ../plugins/ip_fix.smx
## ⚠️ 免责声明

本项目仅供学习交流使用，旨在解决社区服务器在内网穿透环境下的技术限制。**请勿在 Valve 官方服务器上使用**。使用者需自行承担因违反相关规定而导致的一切后果。

## 📄 许可证

本项目采用 [MIT 许可证](LICENSE)。

## 🙇‍ 致谢
感谢以下项目提供思路
https://github.com/vanz666/NoLobbyReservation
https://github.com/eonexdev/csgo-sv-fix-engine

本项目主要使用deepseek生成。
