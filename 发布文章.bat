@echo off & rem 关闭显示命令
title Hexo & rem 设置
setlocal enabledelayedexpansion & REM 启用延迟环境变量扩展，从而可以使用类似 !var! 这样的低优先级变量，实现变量嵌套。
rem ===============
rem 这是一个用于 Hexo 的批处理。
rem 使用前请先把 Git 安装目录下的 "\bin" 目录 和 "\libexec\git-core" 目录加入环境变量使得在 CMD 命令行下可以使用 Git 命令。
rem 还需要复制 ~/.ssh 目录到 Git 的安装目录下（比如"C:\Program Files (x86)\Git"），使得 CMD 命令行可以访问 SSH密钥。
rem ===============
rem 选择操作开始
:Start
cls
echo.
echo.
echo ==============================================
echo =                                            =
echo =               请选择需要的操作             =
echo =        1.启动Hexo本地服务器                =
echo =        2.生成                              =
echo =        3.部署                              =
echo =        4.生成并部署                        =
echo =        5.清除临时文件                      =
echo =        6.新建文章                          =
echo =        7.新建草稿                          =
echo =        8.发布草稿                          =
echo =        9.退出                              =
echo =                                            =
echo =              BY:吕旭（lvxu1987@gmail.com） =
echo ==============================================
echo 请输入您的选择

set /p Choice=

if "%Choice%"=="1" goto server
if "%Choice%"=="2" goto generate
if "%Choice%"=="3" goto deploy
if "%Choice%"=="4" goto generate_deploy
if "%Choice%"=="5" goto clean
if "%Choice%"=="6" goto new
if "%Choice%"=="7" goto new_draft
if "%Choice%"=="8" goto publish_draft
if "%Choice%"=="9" goto end
goto Input_Error
rem 选择操作结束

rem 启动Hexo本地服务器开始
:server
cls
echo.
echo.
echo ==============================================
echo =                                            =
echo =       请选择服务器启动方式的操作           =
echo =        1.标准启动                          =
echo =        2.设置端口                          =
echo =        3.静态启动（只显示public文件夹）    =
echo =        4.包括草稿                          =
echo =        5.返回                              =
echo =                                            =
echo =                                            =
echo =                                            =
echo =                                            =
echo =                                            =
echo =              BY:吕旭（lvxu1987@gmail.com） =
echo ==============================================
echo 请选择

set /p Choice=
if "%Choice%"=="1" hexo server
if "%Choice%"=="2" goto Server_Port
if "%Choice%"=="3" hexo server -s
if "%Choice%"=="4" hexo server --drafts
if "%Choice%"=="5" goto Start
goto server
rem 启动Hexo本地服务器结束

rem 启动非4000端口服务器
:Server_Port
set /p port=请输入端口号：
hexo server -p %port%
goto server

rem 生成静态文件开始
:generate
hexo generate
pause
goto Start
rem 生成静态文件结束

rem 部署到服务器开始
:deploy
hexo deploy
pause
goto Start
rem 部署到服务器结束

rem 生成并部署开始
:generate_deploy
hexo generate --deploy
pause
goto Start
rem 生成并部署结束

rem 清除临时文件开始
:clean
hexo clean
pause
goto Start
rem 清除临时文件结束

rem 生成新文章开始
:new
echo 请输入新文章的标题
set /p post_title=
hexo new post "%post_title%"
pause
goto Start
rem 生成新文章结束

rem 生成新草稿开始
:new_draft
echo 请输入新草稿的标题
set /p draft_title=
hexo new draft "%draft_title%"
pause
goto Start
rem 生成新草稿结束

rem 发布新草稿开始
:publish_draft
dir "source\_drafts" /b > list_exp _exp & rem 输出草稿文件夹中的所有草稿的文件名到 list_exp 里（包含扩展名）
cd. >list & rem 清空 list 文件的内容，防止存在 list 文件导致错误（直接删除的话如果不存在list文件会出错）
for /f "delims=" %%i in (list_exp) do (echo.%%i>>list) & rem 将 list_exp 中非空行的内容输出到 list文件里
set /a sequence=1 & rem 设置顺序代号变量为 1
for /f %%i in (list) do call :echo_list %%i & rem 为list 中的每一行内容调用 echo_list 函数
echo 您希望发布哪篇草稿？
set /p Choice= & rem 选择要发布的草稿
for /l %%i in (1,1,%sequence%-1) do (
if "%Choice%"=="%%i" set draft_name=!draft_name%%i!
) & rem 将被选中的草稿的文件名赋值给 "draft_name" 参数
echo 您希望提交的草稿是：%draft_name%
call :no_ext %draft_name% & rem 删除草稿文件名的后缀名
del list & rem 删除临时文件
del list_exp & rem 删除临时文件
hexo publish post "%draft_name_no_ext%" & rem 发布草稿
pause
goto Start
rem 发布新草稿结束

rem 输入错误时回到菜单
:Input_Error
echo 输入错误，请重新选择
goto Start

rem 退出批处理
:end
pause

rem "no_ext" 函数的作用是去除文件名中的扩展名，因为经测试必须不包括扩展名时 "hexo publish post" 命令才会生效
:no_ext
set draft_name_no_ext=%~n1
goto :eof & rem 函数结束标志

rem 该函数的作用是输出 list 文件夹里每一个文件名并将其编号
:echo_list
echo 草稿%sequence% : %1 & rem 显示草稿序号和文件名
set draft_name%sequence%=%1 & rem 将文件名赋值给 draft_name+序列号
set /a sequence=%sequence%+1 & rem 序列号+1
goto :eof & rem 函数结束标志