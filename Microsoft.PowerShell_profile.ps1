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