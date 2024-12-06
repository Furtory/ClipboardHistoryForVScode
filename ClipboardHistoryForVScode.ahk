/*
本AHK由 黑钨重工 制作 免费开源
唯一教程视频发布地址https://space.bilibili.com/52593606
所有开源项目 https://github.com/Furtory
AHK正版官方论坛https://www.autohotkey.com/boards/viewforum.php?f=26
国内唯一完全免费开源AHK论坛请到QQ频道AutoHotKey12
本人所有教程和脚本严禁转载到此收费论坛以防被用于收费盈利 https://www.autoahk.com/
*/

管理员模式:
IfExist, %A_ScriptDir%\History.ini ;如果配置文件存在则读取
{
  IniRead, AdminMode, History.ini, Settings, 管理权限
  if (AdminMode=1)
  {
    ShellExecute := A_IsUnicode ? "shell32\ShellExecute":"shell32\ShellExecuteA"
    
    if not A_IsAdmin
    {
      If A_IsCompiled
        DllCall(ShellExecute, uint, 0, str, "RunAs", str, A_ScriptFullPath, str, params , str, A_WorkingDir, int, 1)
      Else
        DllCall(ShellExecute, uint, 0, str, "RunAs", str, A_AhkPath, str, """" . A_ScriptFullPath . """" . A_Space . params, str, A_WorkingDir, int, 1)
      ExitApp
    }
  }
}

SendMode, Event
Process, Priority, , Realtime
#MenuMaskKey vkE8
#WinActivateForce
#InstallKeybdHook
#InstallMouseHook
#Persistent
#NoEnv
#SingleInstance Force
#MaxHotkeysPerInterval 2000
#KeyHistory 2000
SetBatchLines -1
SetKeyDelay, 10, 10
CoordMode, Mouse, Screen
CoordMode, Menu, Screen

Menu, Tray, Icon, %A_ScriptDir%\LOGO.ico
Menu, Tray, NoStandard ;不显示默认的AHK右键菜单
Menu, Tray, Add, 使用教程, 使用教程 ;添加新的右键菜单
Menu, Tray, Add
Menu, Tray, Add, 管理权限, 管理权限 ;添加新的右键菜单
Menu, Tray, Add, 开机自启, 开机自启 ;添加新的右键菜单
Menu, Tray, Add
Menu, Tray, Add, 重启软件, 重启软件 ;添加新的右键菜单
Menu, Tray, Add, 退出软件, 退出软件 ;添加新的右键菜单

autostartLnk:=A_StartupCommon . "\ClipboardHistoryRecorder.lnk" ;开机启动文件的路径
IfExist, % autostartLnk ;检查开机启动的文件是否存在
{
  autostart:=1
  Menu, Tray, Check, 开机自启 ;右键菜单打勾
}
else
{
  autostart:=0
  Menu, Tray, UnCheck, 开机自启 ;右键菜单不打勾
}

; 定义全局变量用于存储剪贴板历史
clipboardHistory := []

; 读取剪贴板历史
IfExist, %A_ScriptDir%\History.ini
{
    IniRead, AdminMode, Settings.ini, 设置, 管理权限 ;从ini文件读取设置
    if (AdminMode=0)
    {
      Menu, Tray, UnCheck, 管理权限 ;右键菜单不打勾
    }
    else
    {
      Menu, Tray, Check, 管理权限 ;右键菜单打勾
    }

    IniRead, 顶置菜单数量, History.ini, Setting, 顶置菜单数量

    clipboardAlreadyRecorded:=1
    Loop, % 20 ; 这里应和下面的最大条目数量一致
    {
        IniRead, ReadHistory, History.ini, History, clipboardHistory%A_Index%
        ; ToolTip, ReadHistory`n%ReadHistory%
        ; Sleep, 1000
        if (ReadHistory="") Or (ReadHistory="ERROR") ; 如果该项不存在，则停止读取
        {
            if (A_Index=1) ; 如果第一次就是空不用添加历史记录数组为新条目到剪贴板历史GUI
                clipboardAlreadyRecorded:=0
            Break
        }
        clipboardHistory.InsertAt(1, StrReplace(ReadHistory, "``r``n", "`r`n")) ; 把之前记录为文本的CRLF重新转换回来
    }

    ; 添加历史记录数组为新条目到剪贴板历史GUI
    if (clipboardAlreadyRecorded=1)
    {
        Loop % clipboardHistory.MaxIndex()
        {
            ; Newclipboard:=clipboardHistory[clipboardHistory.MaxIndex()+1-A_Index] ;逆序
            Newclipboard:=clipboardHistory[A_Index] ;顺序
            ; ToolTip, Newclipboard`n%Newclipboard%
            ; Sleep, 1000
            if (StrLen(Newclipboard)>30) ;菜单名称限制字符串长度
                Newclipboard:=SubStr(StrReplace(Newclipboard, "`r`n", ""), 1, 30)
            Menu, clipboardHistoryMenu, Add, %Newclipboard%, ClipTheHistoryRecord, Radio

            if (A_Index<=顶置菜单数量)
                Menu, clipboardHistoryMenu, Check, %Newclipboard%
        }
    }
}
Else
{
    顶置菜单数量:=0
    IniWrite, %顶置菜单数量%, History.ini, Setting, 顶置菜单数量

    AdminMode:=0
    IniWrite, %AdminMode%, History.ini, Settings, 管理权限 ;写入设置到ini文件
    Menu, Tray, Check, 管理权限 ;右键菜单打勾
}

; 软件初始运行时记录当前的剪贴板内容
OldclipboardHistory := A_Clipboard
Return

使用教程:
MsgBox, , 剪贴板历史记录, 剪贴板历史记录会保存在本地的History.ini内`n即使重启电脑也不会丢失剪贴板历史记录`n按下Alt+V打开剪贴板历史记录菜单`n按下Ctrl + Shift + D 清除剪贴板历史记录`n按住Ctrl点击可以顶置剪贴板历史记录`n`nVS code专属功能`n按下Ctrl+D可以根据按下次数复制选中的内容`n你可以添加白名单让其他软件也可以使用`n`n黑钨重工出品 免费开源`n更多免费软件请到QQ频道AutoHotKey12
return

管理权限: ;模式切换
Critical, On
if (AdminMode=1)
{
  AdminMode:=0
  IniWrite, %AdminMode%, History.ini, Settings, 管理权限 ;写入设置到ini文件
  Menu, Tray, UnCheck, 管理权限 ;右键菜单不打勾
  Critical, Off
  Reload
}
else
{
  AdminMode:=1
  IniWrite, %AdminMode%, History.ini, Settings, 管理权限 ;写入设置到ini文件
  Menu, Tray, Check, 管理权限 ;右键菜单打勾
  Critical, Off
  Reload
}
return

开机自启: ;模式切换
Critical, On
if (autostart=1) ;关闭开机自启动
{
  IfExist, % autostartLnk ;如果开机启动的文件存在
  {
    FileDelete, %autostartLnk% ;删除开机启动的文件
  }
  
  autostart:=0
  Menu, Tray, UnCheck, 开机自启 ;右键菜单不打勾
}
else ;开启开机自启动
{
  IfExist, % autostartLnk ;如果开机启动的文件存在
  {
    FileGetShortcut, %autostartLnk%, lnkTarget ;获取开机启动文件的信息
    if (lnkTarget!=A_ScriptFullPath) ;如果启动文件执行的路径和当前脚本的完整路径不一致
    {
      FileCreateShortcut, %A_ScriptFullPath%, %autostartLnk%, %A_WorkingDir% ;将启动文件执行的路径改成和当前脚本的完整路径一致
    }
  }
  else ;如果开机启动的文件不存在
  {
    FileCreateShortcut, %A_ScriptFullPath%, %autostartLnk%, %A_WorkingDir% ;创建和当前脚本的完整路径一致的启动文件
  }
  
  autostart:=1
  Menu, Tray, Check, 开机自启 ;右键菜单打勾
}
Critical, Off
return

重启软件:
Reload
Return

退出软件:
ExitApp
Return

; 为什么不用OnClipboardChange:文本操作都是用剪贴板实现的 我们只记录快捷键产生的剪贴板内容

; 监听 Ctrl+C 或 Ctrl+X 事件以保存剪贴板内容
~^c::
~^x::
; 确保不是空内容
ClipWait 1
if (ErrorLevel || Clipboard = "")
    return

; 等待新内容复制进来
ClipboardGetTickCount:=A_TickCount
Loop
{
    if (A_Clipboard!=OldclipboardHistory) ; 新内容和旧内容不一样
        Break
    Else if (A_TickCount-ClipboardGetTickCount>1000) ; 超时
        Return

    Sleep, 30
}
OldclipboardHistory := A_Clipboard ; 此处需要更新记录用于下次对比

; 检查是否已经存在相同的条目，避免重复添加
for index, entry in clipboardHistory
    if (entry = Clipboard)
        return

; 限制历史记录大小为20个条目
if (clipboardHistory.MaxIndex() = 20)
    clipboardHistory.RemoveAt(20)

; 添加新的剪贴板条目到历史记录数组
clipboardHistory.InsertAt(顶置菜单数量+1, Clipboard)

; 剪贴板记录保存到本地ini配置文件内 注意应当把换行CR-LF给替换为不换行文本储存 需要逆序
Loop, % clipboardHistory.MaxIndex()
    IniWrite, % StrReplace(clipboardHistory[clipboardHistory.MaxIndex()+1-A_Index], "`r`n", "``r``n"), History.ini, History, clipboardHistory%A_Index%

; 如果有记录则先清空旧条目再生成新条目
if (clipboardAlreadyRecorded=1)
  Menu, clipboardHistoryMenu, DeleteAll

; 添加历史记录数组为新条目到剪贴板历史GUI
Loop % clipboardHistory.MaxIndex()
{
    ; Newclipboard:=clipboardHistory[clipboardHistory.MaxIndex()+1-A_Index] ;逆序
    Newclipboard:=clipboardHistory[A_Index] ;顺序
    if (StrLen(Newclipboard)>30) ;菜单名称限制字符串长度
        Newclipboard:=SubStr(Newclipboard, 1, 30)
    Menu, clipboardHistoryMenu, Add, %Newclipboard%, ClipTheHistoryRecord, Radio

    if (A_Index<=顶置菜单数量)
        Menu, clipboardHistoryMenu, Check, %Newclipboard%
}
clipboardAlreadyRecorded:=1
return

; 显示剪贴板历史供用户选择
!v:: ; 使用 Alt+V 键作为触发显示剪贴板历史的快捷键
; 记录菜单显示位置
MouseGetPos, MouseInScreenX, MouseInScreenY
; ToolTip, MouseInScreenX%MouseInScreenX%`nMouseInScreenY%MouseInScreenY%
if (clipboardAlreadyRecorded=1)
    Menu, clipboardHistoryMenu, Show
return
ToolTip
; 当用户从菜单选择一项时黏贴剪贴板内容
ClipTheHistoryRecord:
If GetKeyState("Ctrl", "P")
{
    If (A_ThisMenuItemPos<=顶置菜单数量) ;是顶置菜单
    {
        If (顶置菜单数量>=1)
            顶置菜单数量 := 顶置菜单数量-1
        IniWrite, %顶置菜单数量%, History.ini, Setting, 顶置菜单数量

        ; 获取菜单内容
        Topclipboard := clipboardHistory[A_ThisMenuItemPos]
        ; 删除
        clipboardHistory.RemoveAt(A_ThisMenuItemPos)
        ; 添加到顶部
        clipboardHistory.InsertAt(顶置菜单数量+1, Topclipboard)
    }
    Else ;不是顶置菜单 添加到新的
    {
        if (顶置菜单数量<clipboardHistory.MaxIndex())
            顶置菜单数量 := 顶置菜单数量+1
        IniWrite, %顶置菜单数量%, History.ini, Setting, 顶置菜单数量

        ; 获取菜单内容
        Topclipboard := clipboardHistory[A_ThisMenuItemPos]
        ; 删除
        clipboardHistory.RemoveAt(A_ThisMenuItemPos)
        ; 添加到顶部
        clipboardHistory.InsertAt(1, Topclipboard)
    }

    ; 剪贴板记录保存到本地ini配置文件内 注意应当把换行CR-LF给替换为不换行文本储存 需要逆序
    Loop, % clipboardHistory.MaxIndex()
        IniWrite, % StrReplace(clipboardHistory[clipboardHistory.MaxIndex()+1-A_Index], "`r`n", "``r``n"), History.ini, History, clipboardHistory%A_Index%

    ; 删除GUI菜单
    Menu, clipboardHistoryMenu, DeleteAll

    ; 重新加载菜单
    Loop % clipboardHistory.MaxIndex()
    {
        ; Newclipboard:=clipboardHistory[clipboardHistory.MaxIndex()+1-A_Index] ;逆序
        Newclipboard:=clipboardHistory[A_Index] ;顺序
        if (StrLen(Newclipboard)>30) ;菜单名称限制字符串长度
            Newclipboard:=SubStr(Newclipboard, 1, 30)
        Menu, clipboardHistoryMenu, Add, %Newclipboard%, ClipTheHistoryRecord, Radio

        if (A_Index<=顶置菜单数量)
            Menu, clipboardHistoryMenu, Check, %Newclipboard%
    }

    ; 在上次显示菜单位置显示
    Menu, clipboardHistoryMenu, Show, %MouseInScreenX%, %MouseInScreenY%
}
Else
{
    ; clipboard := clipboardHistory[clipboardHistory.MaxIndex()+1-A_ThisMenuItemPos] ;逆序
    clipboard := clipboardHistory[A_ThisMenuItemPos] ;顺序
    BlockInput, On
    Send ^v ; 自动粘贴选中的历史项
    BlockInput, Off
}
return

; 清除剪贴板历史
^+d:: ; Ctrl + Shift + D 用于清除历史记录
; 清除数组
clipboardHistory := []

; 清除GUI菜单
if (clipboardAlreadyRecorded=1)
    Menu, clipboardHistoryMenu, DeleteAll

; 清除ini文件
Loop, 20
    IniWrite, "", History.ini, History, clipboardHistory%A_Index%

; 清除顶置菜单配置
顶置菜单数量:=0
IniWrite, %顶置菜单数量%, History.ini, Setting, 顶置菜单数量

Loop, 30
{
    ToolTip, 剪贴板历史已清除
    Sleep, 30
}
ToolTip
return

; 如果你需要添加白名单请复制下面这行代码填入对应的进程名
#IfWinActive, ahk_exe Code.exe ; 以下代码只在指定软件内运行
`;::Send {Text};
+`;::Send {Text}:

^d::
; 确保不是空内容
BlockInput, On
Send, {Ctrl Up}
Send ^c ; 复制选择的内容
ClipWait 1
if (ErrorLevel || Clipboard = "")
    return

; 等待新内容复制进来
ClipboardGetTickCount:=A_TickCount
Loop
{
    if (A_Clipboard!=OldclipboardHistory) ; clipboardChoosed
        Break
    Else if (A_TickCount-ClipboardGetTickCount>100) ; 超时
        Break

    Sleep, 10
}

clipboardChoosed:=A_Clipboard
; ToolTip, %A_Clipboard%
if (InStr(clipboardChoosed, "`r`n")<=0) ;没有换行
{
    if (InStr(clipboardChoosed, "(")=1) and (StrLen(clipboardChoosed)>1) and (InStr(clipboardChoosed, ")", , 0)=StrLen(clipboardChoosed))
    {
        send {End 2}
        send {Shift Down}
        send {Home 2}
        send {Shift Up}
        Send ^c ; 复制选择的内容
        NewclipboardStar := SubStr(A_Clipboard, 1, InStr(A_Clipboard, clipboardChoosed)+StrLen(clipboardChoosed)-1)
        NewclipboardEnd := SubStr(A_Clipboard, InStr(A_Clipboard, clipboardChoosed)+StrLen(clipboardChoosed))
        Newclipboard := NewclipboardStar

        复制数量:=1
        CopyCount:=A_TickCount
        loop
        {
            ToolTip, 复制数量%复制数量%
            if GetKeyState("D", "P")
            {
                if (A_Index>1)
                  复制数量+=1
                loop
                {
                    ToolTip, 复制数量%复制数量%
                    if !GetKeyState("D", "P")
                    {
                        CopyCount:=A_TickCount
                        Break
                    }
                    sleep 30
                }
            }
            Else if (A_TickCount-CopyCount>700)
                Break
            sleep 30
        }

        loop %复制数量%
        {
            if (InStr(A_Clipboard, ") or (")!=0) or (InStr(A_Clipboard, ")or(")!=0) or (InStr(A_Clipboard, ")or (")!=0) or (InStr(A_Clipboard, ") or(")!=0)
                Newclipboard .= " or "
            Else
                Newclipboard .= " and "
            Newclipboard .= clipboardChoosed
        }
        
        Newclipboard .= NewclipboardEnd
        BlockInput, off
        clipboard := Newclipboard
        ; (Start) or (Test) or (End)
        ; (Start) and (Test) and (End)
        Sleep, 100
        Send ^v ; clipboardChoosed

        loop 30
        {
            ToolTip, 复制数量%复制数量%
            Sleep, 30
        }
        ToolTip
    }
    Else
    {    
        clipboard .= clipboardChoosed
        Sleep, 100
        Send ^v ; clipboardChoosed
    }
    ; ToolTip 没有换行
}
Else
{
    CRLFcount := 0
    pos := 1
    while pos <= StrLen(A_Clipboard) {
        foundPos := InStr(A_Clipboard, "`r`n", , pos)
        if (foundPos = 0)
            break ; 没有更多匹配项时退出循环
        CRLFcount += 1
        pos := foundPos + 2 ; 更新位置以避免重复计数，并跳过已计数的CR-LF序列
    }
    ; FirstCRLF:=InStr(clipboardChoosed, "`r`n")
    ; ToolTip, CRLFcount%CRLFcount%`nFirstCRLF%FirstCRLF%
    if (CRLFcount=1)
    {
        ; ToolTip % InStr(clipboardChoosed, "`r`n")
        if (InStr(clipboardChoosed, "`r`n")=1)
        {
            Send, {End}
            Sleep, 50
        }
        Send, {Shift Down}
        Send, {Alt Down}
        Sleep, 50
        Send, {Down}
        Send, {Shift up}
        Send, {Alt up}
    }
    Else if (CRLFcount>1)
    {
        FirstCRLF:=InStr(clipboardChoosed, "`r`n")
        if (FirstCRLF=1)
        {
            Send, +{Right}
            Sleep, 50
        }
        Send, {Shift Down}
        Send, {Alt Down}
        Sleep, 50
        Send, {Down}
        Send, {Shift up}
        Send, {Alt up}
    }
}
Sleep, 100
clipboard:=OldclipboardHistory
BlockInput, Off
KeyWait, Ctrl
Send, {Ctrl Up}
Return

$Enter::
EnterDown:=A_TickCount
BlockInput, On
loop
{
    if !GetKeyState("Enter", "P")
    {
        Send, {Enter}
        Break
    }
    if (A_TickCount-EnterDown>300)
    {
        Send, {Shift Down}
        Sleep, 50
        Send, {End}
        Send, {Shift up}
        KeyWait, Enter
        Send, {Enter}
        Break
    }
}
BlockInput, Off
Return