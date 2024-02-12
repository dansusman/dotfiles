echo "$(date)" > ~/temporary/logs
echo "----------------" >> ~/temporary/logs
(cd ~/work/staging/Notability && git pull) >> ~/temporary/logs

