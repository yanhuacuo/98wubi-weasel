@echo off

REG ADD "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Fontlink\SystemLink" /v 98WB-0 /t REG_MULTI_SZ /d "MSYH.TTC,Microsoft YaHei UI,128,96"\0"MSYH.TTC,Microsoft YaHei UI"\0"MSYH.TTF,128,96"\0"MSYH.TTF"\0"SEGUISYM.TTF,Segoe UI Symbol"\0"SEGOEUI.TTF,Segoe UI,120,80"\0"SEGOEUI.TTF,Segoe UI"\0"SIMSUN.TTC,SimSun"\0"MSJH.TTC,Microsoft JhengHei,128,96"\0"MSJH.TTC,Microsoft JhengHei"\0"MEIRYO.TTC,Meiryo,128,85"\0"MEIRYO.TTC,Meiryo"\0"MALGUN.TTF,Malgun Gothic,128,96"\0"MALGUN.TTF,Malgun Gothic"\0"YUGOTHM.TTC,Yu Gothic UI,128,96"\0"YUGOTHM.TTC,Yu Gothic UI"\0"MSJH.TTC,Microsoft Jhenghei UI"\0"MEIRYO.TTC,Meiryo UI"\0"98WB-V.OTF,98WB-V"\0"98WB-U.OTF,98WB-U"\0"98WB-P0.OTF,98WB-P0"\0"98WB-P2.OTF,98WB-P2"\0"98WB-P3.OTF,98WB-P3"\0"98WB-P15.OTF,98WB-P15"\0 /f

set id=%USERNAME%

for /f "tokens=1,2,* " %%i in ('REG QUERY HKEY_CURRENT_USER\Software\Rime\Weasel /v RimeUserDir ^| find /i "RimeUserDir"') do set "UserDir=%%k"

if defined UserDir (
    echo ���� UserDir ��ֵ��Ϊ��
) else set UserDir="C:\Users\%id%\AppData\Roaming\Rime"

echo "�û�Ŀ¼Ϊ�� %UserDir%"

for /f "tokens=1,2,* " %%i in ('REG QUERY HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Rime\Weasel /v WeaselRoot ^| find /i "WeaselRoot"') do set "regvalue=%%k"

echo "��װ·��Ϊ�� %regvalue%"

set tables="%~dp0"

echo "��ʼ���㷨����"

start "" "%regvalue%\WeaselServer.exe"

echo "��ʱ 2 ��"

ping -n 2 127.0.0.1>nul

echo "�����㷨����"

TASKKILL /F /IM WeaselServer.exe

echo "��ʱ 2 ��"

ping -n 2 127.0.0.1>nul

echo "��ա��û�Ŀ¼������������²�����Ч"

cd %UserDir%

DEL /F /A /Q "*.*"

echo "��ʱ 2 ��"

ping -n 2 127.0.0.1>nul

DEL /F /A /Q "%UserDir%\build\*"

echo "����ա�build��"

for /f "delims=" %%a in ('dir/s/ad/b^|sort /r') do (
echo,rd /s /Q "%%a"&& rd /s /Q "%%a"
)


echo "1-�ɹ���ա��û�Ŀ¼��"

cd %tables%

echo "׼�����³���Ŀ¼��"

DEL /F /A /Q "%regvalue%\data\opencc\*"
echo "��ɾ��opencc"
ping -n 2 127.0.0.1>nul
DEL /F /A /Q "%regvalue%\data\preview\*"
echo "��ɾ��preview"
ping -n 2 127.0.0.1>nul
rd /s /q "%regvalue%\data\opencc"
echo "��ɾopencc"
ping -n 2 127.0.0.1>nul
rd /s /q "%regvalue%\data\preview"
echo "��ɾpreview"
ping -n 2 127.0.0.1>nul

echo "2-ɾ��DATA"
ping -n 3 127.0.0.1>nul

rd /s /q "%regvalue%\data"

echo "3-�����µ�DATA"

md "%regvalue%\data"

xcopy /S %tables%\patch\data "%regvalue%\data"

echo "5-����APPDATAĿ¼"

md "%UserDir%\build"

xcopy /S %tables%\patch\data\bin\*.bin "%UserDir%\build"

xcopy /S %tables%\patch\data\*.yaml "%UserDir%"

xcopy /S %tables%\patch\data\*.lua "%UserDir%"

echo "6-�ѷź������С����ļ��������������㷨����"

ping -n 5 127.0.0.1>nul

echo "�����㷨������Ԥ�����²���"

start "" "%regvalue%\WeaselServer.exe"

echo "��ʱ 2 ��"

ping -n 2 127.0.0.1>nul

echo "���²��𣬼����ָ�����"

"%regvalue%/WeaselDeployer.exe" /deploy
echo "���²���ɹ�"
"%regvalue%/WeaselServer.exe" /weaseldir
echo "����Ŀ¼�Ѵ�"
"%regvalue%/WeaselServer.exe" /userdir

echo "�û�Ŀ¼�Ѵ�"

pause