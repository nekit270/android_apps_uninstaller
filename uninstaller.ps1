Clear-Host
Add-Type -AssemblyName System.Windows.Forms

if(-not (Test-Path ".\adb")){
    Try{
        iwr "http://f0615718.xsph.ru/files/adb.zip" -OutFile "adb.zip"
        Expand-Archive "adb.zip" -DestinationPath ".\adb"
        Remove-Item "adb.zip" -Force
    }Catch{
        [System.Windows.Forms.MessageBox]::Show("Ошибка: Не удалось скачать данные`nСправка: http://cutt.ly/yaauhelp", "Android Apps Uninstaller", 0, 16) | Out-Null
        exit
    }
}

if(-not (adb\adb devices) -contains "device"){
    [System.Windows.Forms.MessageBox]::Show("Ошибка подключения Android-устройства`nСправка: http://cutt.ly/yaauhelp", "Android Apps Uninstaller", 0, 16) | Out-Null
    exit
}

$pkglist = (adb\adb shell pm list packages) -replace "package:", ""

$form = New-Object System.Windows.Forms.Form
$form.Text = "Android Apps Uninstaller"
$form.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 14)
$form.Width = 500
$form.Height = 300

$lbl = New-Object System.Windows.Forms.Label
$lbl.Location = New-Object System.Drawing.Point(30, 30)
$lbl.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 18)
$lbl.Text = "Выберите пакет:"
$lbl.Height = 40
$lbl.Width = 470

$cb = New-Object System.Windows.Forms.ComboBox
$cb.Location = New-Object System.Drawing.Point(30, 90)
$cb.Height = 30
$cb.Width = 410
$cb.DataSource = ("---Пусто---", [String]$pkglist -split " ")
$items = ("---Пусто---", [String]$pkglist -split " ")

$btn = New-Object System.Windows.Forms.Button
$btn.Location = New-Object System.Drawing.Point(5, 150)
$btn.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 22)
$btn.Text = "Удалить"
$btn.Height = 80
$btn.Width = 470 
$btn.Add_Click({
    if($cb.SelectedItem -eq "---Пусто---" -or ($items.IndexOf($cb.SelectedItem) -lt 0) -or ([System.Windows.Forms.MessageBox]::Show("Вы точно хотите удалить пакет `"" + $cb.SelectedItem + "`"?", "Android Apps Uninstaller", 4, 32)) -eq "No") { return }
    adb\adb shell pm uninstall -k --user 0 $cb.SelectedItem
    [System.Windows.Forms.MessageBox]::Show("Пакет `"" + $cb.SelectedItem + "`" удалён.", "Android Apps Uninstaller", 0, 64) | Out-Null

    $Global:pkglist = (adb\adb shell pm list packages) -replace "package:", ""
    $Global:cb.DataSource = ("---Пусто---", [String]$pkglist -split " ")
})

$form.Controls.AddRange(($lbl, $cb, $btn))
$form.ShowDialog() | Out-Null