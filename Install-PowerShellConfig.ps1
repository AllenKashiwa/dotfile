# PowerShell 跨平台配置安装脚本  

# 检查是否以管理员权限运行  
function Test-Administrator {  
    $user = [Security.Principal.WindowsIdentity]::GetCurrent()  
    $principal = New-Object Security.Principal.WindowsPrincipal $user  
    return $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)  
}  

if (-not (Test-Administrator)) {  
    Write-Host "请以管理员身份运行此脚本！" -ForegroundColor Red  
    Start-Sleep -Seconds 3  
    exit  
}  

# 设置执行策略  
Set-ExecutionPolicy Bypass -Scope Process -Force  

# 安装 Chocolatey  
Write-Host "正在安装 Chocolatey..." -ForegroundColor Cyan  
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))  

# 安装必要的软件包  
Write-Host "正在安装必要的软件包..." -ForegroundColor Cyan  
choco install -y git  
choco install -y microsoft-windows-terminal  
choco install -y oh-my-posh  
choco install -y vscode  

# 安装 PowerShell 模块  
Write-Host "正在安装 PowerShell 模块..." -ForegroundColor Cyan  
Install-Module -Name PSReadLine -Scope CurrentUser -Force -SkipPublisherCheck  
Install-Module -Name posh-git -Scope CurrentUser -Force  

# 创建或更新 PowerShell 配置文件  
Write-Host "正在配置 PowerShell 配置文件..." -ForegroundColor Cyan  
$profileContent = @'  
# Git 相关别名  
function gs { git status }  
function gc { git commit }  
function gp { git push }  
function gd { git diff }  
function gl { git log --oneline --graph --decorate }  
function gb { git branch }  
function gco { git checkout }  
function gst { git stash }  
function gpl { git pull }  

# 目录导航  
function .. { Set-Location .. }  
function ... { Set-Location ..\.. }  
function .... { Set-Location ..\..\.. }  
function ~ { Set-Location $HOME }  

# 系统信息显示  
function sysinfo {  
    Write-Host "系统信息：" -ForegroundColor Green  
    Get-ComputerInfo | Select-Object WindowsProductName, OsVersion, OsArchitecture, CsProcessors, CsNumberOfLogicalProcessors, CsNumberOfProcessors  
}  

# 快速打开常用目录  
function docs { Set-Location $HOME\Documents }  
function downloads { Set-Location $HOME\Downloads }  
function desktop { Set-Location $HOME\Desktop }  

# 进程管理  
function killport($port) {  
    Get-Process -Id (Get-NetTCPConnection -LocalPort $port).OwningProcess | Stop-Process -Force  
}  

# 加载PSReadLine模块  
Import-Module PSReadLine  

# PSReadLine 配置  
Set-PSReadLineOption -PredictionSource History  
Set-PSReadLineOption -PredictionViewStyle ListView  
Set-PSReadLineOption -EditMode Windows  
Set-PSReadLineOption -BellStyle None  

# 按键绑定  
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete  
Set-PSReadLineKeyHandler -Key 'Shift+Tab' -Function MenuComplete  
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward  
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward  
Set-PSReadLineKeyHandler -Key Ctrl+Spacebar -Function Complete  

# 历史记录设置  
Set-PSReadLineOption -HistorySearchCursorMovesToEnd  
Set-PSReadLineOption -HistorySaveStyle SaveIncrementally  
Set-PSReadLineOption -MaximumHistoryCount 10000  

# 导入 Chocolatey Profile  
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"  
if (Test-Path($ChocolateyProfile)) {  
    Import-Module "$ChocolateyProfile"  
}  

# 设置 Oh-My-Posh 主题  
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/gruvbox.omp.json" | Invoke-Expression  

# 设置环境变量  
$env:EDITOR = "code"  
$env:VISUAL = "code"  

# 设置 PowerShell 窗口标题  
$Host.UI.RawUI.WindowTitle = "PowerShell - $env:USERNAME@$env:COMPUTERNAME"  

# 设置控制台颜色  
$Host.UI.RawUI.BackgroundColor = "Black"  
$Host.UI.RawUI.ForegroundColor = "White"  

# 欢迎信息  
Write-Host "`n欢迎使用 PowerShell！" -ForegroundColor Green  
Write-Host "当前时间: $(Get-Date)" -ForegroundColor Cyan  
Write-Host "系统信息: $([Environment]::OSVersion.VersionString)" -ForegroundColor Cyan  
Write-Host "`n"  
'@  

# 创建配置文件目录（如果不存在）  
if (!(Test-Path (Split-Path $Profile -Parent))) {  
    New-Item -Path (Split-Path $Profile -Parent) -ItemType Directory -Force | Out-Null  
}  

# 写入配置文件  
Set-Content -Path $Profile -Value $profileContent -Force  

# 安装字体（Nerd Font）  
Write-Host "正在安装 Meslo Nerd Font..." -ForegroundColor Cyan  
oh-my-posh font install Meslo  

# 提示用户完成剩余配置  
Write-Host "`n配置完成！请完成以下步骤：" -ForegroundColor Green  
Write-Host "1. 打开 Windows Terminal" -ForegroundColor Yellow  
Write-Host "2. 在设置中选择 'PowerShell' 配置文件" -ForegroundColor Yellow  
Write-Host "3. 将字体设置为 'MesloLGS NF'" -ForegroundColor Yellow  
Write-Host "4. 重启 Windows Terminal" -ForegroundColor Yellow  