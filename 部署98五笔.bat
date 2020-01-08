@echo off

REG ADD "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Fontlink\SystemLink" /v 98WB-0 /t REG_MULTI_SZ /d "MSYH.TTC,Microsoft YaHei UI,128,96"\0"MSYH.TTC,Microsoft YaHei UI"\0"MSYH.TTF,128,96"\0"MSYH.TTF"\0"SEGUISYM.TTF,Segoe UI Symbol"\0"SEGOEUI.TTF,Segoe UI,120,80"\0"SEGOEUI.TTF,Segoe UI"\0"SIMSUN.TTC,SimSun"\0"MSJH.TTC,Microsoft JhengHei,128,96"\0"MSJH.TTC,Microsoft JhengHei"\0"MEIRYO.TTC,Meiryo,128,85"\0"MEIRYO.TTC,Meiryo"\0"MALGUN.TTF,Malgun Gothic,128,96"\0"MALGUN.TTF,Malgun Gothic"\0"YUGOTHM.TTC,Yu Gothic UI,128,96"\0"YUGOTHM.TTC,Yu Gothic UI"\0"MSJH.TTC,Microsoft Jhenghei UI"\0"MEIRYO.TTC,Meiryo UI"\0"98WB-V.OTF,98WB-V"\0"98WB-U.OTF,98WB-U"\0"98WB-P0.OTF,98WB-P0"\0"98WB-P2.OTF,98WB-P2"\0"98WB-P3.OTF,98WB-P3"\0"98WB-P15.OTF,98WB-P15"\0 /f

set id=%USERNAME%

for /f "tokens=1,2,* " %%i in ('REG QUERY HKEY_CURRENT_USER\Software\Rime\Weasel /v RimeUserDir ^| find /i "RimeUserDir"') do set "UserDir=%%k"

if defined UserDir (
    echo 变量 UserDir 的值不为空
) else set UserDir="C:\Users\%id%\AppData\Roaming\Rime"

echo "用户目录为： %UserDir%"

for /f "tokens=1,2,* " %%i in ('REG QUERY HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Rime\Weasel /v WeaselRoot ^| find /i "WeaselRoot"') do set "regvalue=%%k"

echo "安装路径为： %regvalue%"

set tables="%~dp0"

echo "初始化算法服务"

start "" "%regvalue%\WeaselServer.exe"

echo "延时 2 秒"

ping -n 2 127.0.0.1>nul

echo "结束算法服务"

TASKKILL /F /IM WeaselServer.exe

echo "延时 2 秒"

ping -n 2 127.0.0.1>nul

echo "清空「用户目录」，免其干扰新参数生效"

cd %UserDir%

DEL /F /A /Q "*.*"

echo "延时 2 秒"

ping -n 2 127.0.0.1>nul

DEL /F /A /Q "%UserDir%\build\*"

echo "已清空「build」"

for /f "delims=" %%a in ('dir/s/ad/b^|sort /r') do (
echo,rd /s /Q "%%a"&& rd /s /Q "%%a"
)


echo "1-成功清空「用户目录」"

cd %tables%

echo "准备更新程序目录了"

DEL /F /A /Q "%regvalue%\data\opencc\*"
echo "已删空opencc"
ping -n 2 127.0.0.1>nul
DEL /F /A /Q "%regvalue%\data\preview\*"
echo "已删空preview"
ping -n 2 127.0.0.1>nul
rd /s /q "%regvalue%\data\opencc"
echo "已删opencc"
ping -n 2 127.0.0.1>nul
rd /s /q "%regvalue%\data\preview"
echo "已删preview"
ping -n 2 127.0.0.1>nul

echo "2-删除DATA"
ping -n 3 127.0.0.1>nul

rd /s /q "%regvalue%\data"

echo "3-放入新的DATA"

md "%regvalue%\data"

xcopy /S %tables%\patch\data "%regvalue%\data"

echo "5-更新APPDATA目录"

xcopy /S %tables%\patch\data\wubi98_*.extended.dict.yaml "%UserDir%"
xcopy /S %tables%\patch\data\*.custom.yaml "%UserDir%"
xcopy /S %tables%\patch\data\wubi98_*.schema.yaml "%UserDir%"
xcopy /S %tables%\patch\data\weasel.yaml "%UserDir%"
xcopy /S %tables%\patch\data\*.lua "%UserDir%"

echo "6-已放好了所有「新文件」，即将唤醒算法服务"

ping -n 5 127.0.0.1>nul

echo "唤醒算法服服，预备重新部署"

start "" "%regvalue%\WeaselServer.exe"

echo "延时 2 秒"

ping -n 2 127.0.0.1>nul

echo "重新部署，即将恢复正常"

"%regvalue%/WeaselDeployer.exe" /deploy
echo "重新布署成功"
"%regvalue%/WeaselServer.exe" /weaseldir
echo "程序目录已打开"
"%regvalue%/WeaselServer.exe" /userdir

echo "用户目录已打开"

pause