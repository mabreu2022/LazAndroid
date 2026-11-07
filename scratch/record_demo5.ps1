param([string]$Device = "RQ8R70BFZEJ", [string]$OutDir = "C:\Users\HOT\.gemini\antigravity\brain\08f8dc26-a454-4dbd-97dd-4d65397e85a4")
$adb = "C:\Users\HOT\AppData\Local\Android\Sdk\platform-tools\adb.exe"
$d = $Device
function Tap($x, $y, $wait = 1.2) { & $adb -s $d shell input tap ([int]$x) ([int]$y); Start-Sleep -Milliseconds ([int]($wait * 1000)) }
function Shot($n) { & $adb -s $d shell screencap -p /sdcard/s.png; & $adb -s $d pull /sdcard/s.png "$OutDir\$n.png" | Out-Null }
# teclado (coordenadas da captura 900px -> fisico x1.2)
$keys = @{}
$r1 = "q","w","e","r","t","y","u","i","o","p"; $x1 = 55,143,231,318,405,493,580,668,755,843
for ($i=0;$i -lt 10;$i++) { $keys[$r1[$i]] = @($x1[$i], 1432) }
$r2 = "a","s","d","f","g","h","j","k","l"; $x2 = 100,187,275,363,450,537,625,712,800
for ($i=0;$i -lt 9;$i++) { $keys[$r2[$i]] = @($x2[$i], 1555) }
$r3 = "z","x","c","v","b","n","m"; $x3 = 187,275,363,450,537,625,712
for ($i=0;$i -lt 7;$i++) { $keys[$r3[$i]] = @($x3[$i], 1680) }
$keys[" "] = @(450, 1805)
$nums = "1","2","3","4","5","6","7","8","9","0"
for ($i=0;$i -lt 10;$i++) { $keys[$nums[$i]] = @($x1[$i], 1315) }
function Type($txt) { foreach ($c in $txt.ToCharArray()) { $k = $keys["$c"]; if ($k) { Tap ($k[0]*1.2) ($k[1]*1.2) 0.25 } } }
function HideKb { Tap 846 2328 0.8 }

& $adb -s $d shell input keyevent KEYCODE_WAKEUP
& $adb -s $d shell am force-stop com.lazarus.android.demo
& $adb -s $d shell rm -f /sdcard/demo5_lazdroid.mp4
$rec = Start-Process -FilePath $adb -ArgumentList "-s $d shell screenrecord --time-limit 70 --bit-rate 6000000 /sdcard/demo5_lazdroid.mp4" -PassThru -WindowStyle Hidden
Start-Sleep -Seconds 2
& $adb -s $d shell am start -n com.lazarus.android.demo/com.pascal.lclproject.LCLActivity | Out-Null
Start-Sleep -Seconds 4
Shot "step1_login"
Tap 540 855 3            # Entrar
Shot "step2_clientes_list"
Tap 96 186 2             # menu hamburguer
Shot "step3_drawer_menu"
Tap 468 2144 1.5         # Fechar menu lateral
Tap 966 364 2            # + Novo
Tap 540 612 1            # campo Nome
Type "mercado azul"
Tap 540 878 0.8          # CPF/CNPJ
Type "11222333"
Tap 540 1146 0.8         # Telefone
Type "19999887766"
Shot "step4_cliente_crud_form"
HideKb
Shot "step4b_form_preenchido"
Tap 332 1950 3           # Salvar
Shot "step5_cliente_salvo"
Tap 540 580 2.5          # editar primeiro cliente
Shot "step6_editar_cliente"
Tap 840 1950 2           # Voltar (ou Excluir/Voltar conforme layout)
Shot "step7_voltou_lista"
Start-Sleep -Seconds 2
& $adb -s $d shell pkill -2 screenrecord
Start-Sleep -Seconds 3
& $adb -s $d pull /sdcard/demo5_lazdroid.mp4 "$OutDir\demo5_lazdroid.mp4"
& $adb -s $d shell pidof com.lazarus.android.demo

