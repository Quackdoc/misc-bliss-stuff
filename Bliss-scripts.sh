#!/bin/bash
## immediately exit upon failure
set -e

# Define the usage function
function usage {
  echo "Usage: $0 Argument"
  echo ""
  echo "    [-r|--rotate]: Rotate the TTY console."
  echo "        Takes 0, 1, 2, 3 as arguments. rotates by 0, 90, 180, 270 respectively."
  echo "    [-c|--connectors]: Show availible connectors."
  echo "    [-b|--boot-config]: Edit the boot configuration."
  echo "        Takes in ""Refind"" or ""Grub"" as options."
  echo "        Only works if the name was left as ""ESP"" during config"
  echo "    [-h|--help]: Display this help message."
  #echo "Usage: $0 [-r|--rotate] [-c|--connectors] [-h|--help]"
  #echo "Usage: $0 [-r|--rotate] [-c|--connectors] [-h|--help]"
  exit 1
}

function rotate {
    echo $1 > /sys/class/graphics/fbcon/rotate_all
    echo "rotated display"
    exit 1
}

function showconnectors {
    connectors=$(ls /sys/class/drm/)

    # Loop through each connector and check if it's active
    for connector in $connectors; do
        if [ -f "/sys/class/drm/$connector/status" ]; then
            status=$(cat "/sys/class/drm/$connector/status")
            if [ "$status" = "connected" ]; then
                echo "$(echo "$connector" | sed 's/card[0-9]-//') is connected"
            fi
        fi
    done
    exit 1
}

function editboot {
    # don't care about case here
    shopt -s nocasematch
    if [ "$1" == "refind" ]; then
        disk=$(blkid | grep -i efi | head -n 1 | cut -d : -f 1)
        mkdir -p /mountesp
        mount $disk /mountesp
        vi /mountesp/efi/refind/android.cfg
        umount /mountesp
        rmdir /mountesp
        exit 1
    elif [ "$1" == "grub" ]; then
        disk=$(blkid | grep -i efi | head -n 1 | cut -d : -f 1)
        mkdir -p /mountesp
        mount $disk /mountesp
        echo "Do nothing for now since I don't know where grub is."
        #vi /mountesp/efi/refind/android.cfg
        umount /mountesp
        rmdir /mountesp
        exit 1
    else
        echo "Exiting as no bootloader was passed, Supports either ""refind"" or ""grub"""
        exit 1
    fi
}

# Parse the options
while [[ $# -gt 0 ]]
do
  key="$1"

  case $key in
    -r|--rotate)
      # Run the rotate command
      rotate
      shift
      ;;
    -c|--connectors)
      # Run the connectors command
      showconnectors
      shift
      ;;
      -b|--boot-config)
      # Run the connectors command
      editboot
      shift
      ;;
    -h|--help)
      # Display the usage function
      usage
      shift
      ;;
    *)
      # If an invalid option is passed, display the usage function
      usage
      shift
      ;;
  esac
done

# If no option is passed, execute the separate function
if [[ $# -eq 0 ]]
then
  usage
fi
