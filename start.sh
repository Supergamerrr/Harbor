clear -x
echo "----WIN7--------------------------------------------"
echo "Напишите любую из списка команд. Что-бы начать запуск Windows 7 просто нажмите Enter."
echo "reinstall - Сбросить все настройки и переустановить Windows 7. Потребуется 4~ гб."
echo "---------------------------------------------------"
read -p "> " test
if [ "$test" == "reinstall" ]; then
clear -x
echo "----Установка--------------------------------------"
echo "Это займёт некоторое время!"
echo "Учтите, что это займёт пару минут."
echo "---------------------------------------------------"
sleep 3
echo "Обновляем все пакеты..."
apk update
apk upgrade
echo "Устанавливаем необходимые пакеты..."
apk add qemu qemu-img qemu-system-x86_64 qemu-ui-gtk
echo "Подготовка ngrok..."
wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz
echo "Распаковываем ngrok..."
tar xvzf ngrok-v3-stable-linux-amd64.tgz &> /dev/null
echo "Удаление архива ngrok..."
rm ngrok-v3-stable-linux-amd64.tgz
echo "Устанавливаем образ системы..."
wget -O w7x64.img https://bit.ly/akuhnetw7X64
echo "Введите ваш Token для ngrok"
read -p "> " ngrok
echo "ngrok=$ngrok">> windows.ini
fi
clear -x
echo "Запускаем..."
while read -r var value; do
FULL="$var=$value"
  export $var
done < windows.ini
./ngrok config add-authtoken $ngrok
nohup ./ngrok tcp 3388 &>/dev/null &
sleep 4
echo "Ваша виртуальная машина уже запускается! Откройте пуск, введите 'Подключение к удалённому столу', и введите этот IP:"
curl --silent --show-error http://127.0.0.1:4040/api/tunnels | sed -nE 's/.*public_url":"tcp:..([^"]*).*/\1/p'
read -p "> "
qemu-system-x86_64 -hda w7x64.img -m 2048M -smp cores=2,threads=2 -net user,hostfwd=tcp::3388-:3389 -net nic -object rng-random,id=rng0,filename=/dev/urandom -device virtio-rng-pci,rng=rng0 -vga vmware -nographic
exit
