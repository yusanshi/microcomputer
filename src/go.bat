@echo off
masm %1 
link %1 < dummy.txt
echo.
%1
