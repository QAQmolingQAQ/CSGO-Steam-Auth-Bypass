#pragma semicolon 1
#include <sourcemod>
#pragma newdecls required

public Plugin myinfo = 
{
    name = "IP Validation Bypass",
    author = "QAQmolingQAQ",
    version = "1.0"
};

// 内存补丁结构体，完全照搬 nolobbyreservation 的实现
enum struct mem_patch
{
    Address addr;
    int len;
    char patch[256];
    char orig[256];

    bool Init(GameData conf, const char[] key, Address baseAddr)
    {
        int offset = conf.GetOffset(key);
        if (offset == -1) {
            return false;
        }
        
        char bytes[512];
        if (!conf.GetKeyValue(key, bytes, sizeof(bytes))) {
            return false;
        }
        
        // 这里不需要 baseAddr，因为我们要 Patch 的是 engine.dll 的绝对地址
        this.addr = view_as<Address>(offset);
        
        int pos, curPos;
        char byteStr[16];
        StrCat(bytes, sizeof(bytes), " ");
        
        while ((pos = SplitString(bytes[curPos], " ", byteStr, sizeof(byteStr))) != -1) {
            curPos += pos;
            TrimString(byteStr);
            if (byteStr[0]) {
                this.patch[this.len] = StringToInt(byteStr, 16);
                this.orig[this.len] = LoadFromAddress(this.addr + view_as<Address>(this.len), NumberType_Int8);
                this.len++;
            }
        }
        return true;
    }
    
    void Apply() {
        for (int i = 0; i < this.len; i++)
            StoreToAddress(this.addr + view_as<Address>(i), this.patch[i], NumberType_Int8);
    }
    
    void Restore() {
        for (int i = 0; i < this.len; i++)
            StoreToAddress(this.addr + view_as<Address>(i), this.orig[i], NumberType_Int8);
    }
}

mem_patch g_ipPatch;

public void OnPluginStart()
{
    GameData conf = new GameData("ip_fix.games");
    if (!conf) SetFailState("Failed to load ip_fix gamedata");
    
    // 直接使用我们找到的绝对地址（需要你确认）
    Address patchAddr = view_as<Address>(0x101BEFA0);
    
    if (!g_ipPatch.Init(conf, "IPValidationBypass_Patch", patchAddr))
        SetFailState("Failed to initialize IP patch");
    
    g_ipPatch.Apply();
    LogMessage("IP 验证绕过补丁已应用");
    
    delete conf;
}

public void OnPluginEnd()
{
    g_ipPatch.Restore();
}