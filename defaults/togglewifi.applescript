set status to do shell script "networksetup -getairportpower en0"
if status ends with "On" then
  do shell script "networksetup -setairportpower en0 off"
else
  do shell script "networksetup -setairportpower en0 on"
end if
