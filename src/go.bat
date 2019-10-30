@echo off
masm %1 < dummy.txt
link %1 < dummy.txt
echo.
%1
echo.
echo.