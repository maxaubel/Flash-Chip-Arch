#!/bin/bash

setup_enviroment() { \
	echo -e "\n Setting up environment"
	sudo pacman -Syy
	while IFS=, read -r program comment; do
		n=$((n+1))
		if [ $n -gt 1 ]; then
		 echo -e "\n Installing [$program]"
		 echo -e "\n [$program] $comment \n"
		 sudo pacman --noconfirm --needed -S --color=auto "$program"
			if ! pacman -Qs $program > /dev/null ; then
			  echo "Failed to install [$program] exiting"
			  exit 0
			fi
		fi
	done < programs.csv ;}

setup_usergroups(){
	echo -e "\n Adding current user to dialout group"
	sudo usermod -a -G dialout $(logname)

	echo -e "\n Adding current user to plugdev group"
	sudo usermod -a -G plugdev $(logname)
}

setup_allwinner_udevrules(){
	echo -e "\n Adding udev rule for Allwinner devices"
	echo -e 'SUBSYSTEM=="usb", ATTRS{idVendor}=="1f3a", ATTRS{idProduct}=="efe8", GROUP="plugdev", MODE="0660" SYMLINK+="usb-chip"
	SUBSYSTEM=="usb", ATTRS{idVendor}=="18d1", ATTRS{idProduct}=="1010", GROUP="plugdev", MODE="0660" SYMLINK+="usb-chip-fastboot"
	SUBSYSTEM=="usb", ATTRS{idVendor}=="1f3a", ATTRS{idProduct}=="1010", GROUP="plugdev", MODE="0660" SYMLINK+="usb-chip-fastboot"
	SUBSYSTEM=="usb", ATTRS{idVendor}=="067b", ATTRS{idProduct}=="2303", GROUP="plugdev", MODE="0660" SYMLINK+="usb-serial-adapter"
	' | sudo tee /etc/udev/rules.d/99-allwinner.rules
	sudo udevadm control --reload-rules
}

install_chip_tools(){
	echo -e "\n Installing CHIP-tools"
	if [ -d CHIP-tools ]; then
	 cd CHIP-tools 
	 git pull 
	 elif [ ! -d CHIP-tools ]; then
	 git clone https://github.com/Project-chip-crumbs/CHIP-tools.git
	 cd  CHIP-tools 
	 FEL='sudo sunxi-fel' FASTBOOT='sudo fastboot' SNIB=false ./chip-update-firmware.sh -$flavour
	fi
}

flash_chip(){
	 cd  CHIP-tools
	 FEL='sudo sunxi-fel' FASTBOOT='sudo fastboot' SNIB=false ./chip-update-firmware.sh -"$1"
}

  echo ""
  echo ""
  echo "   #  #  #"
  echo "  #########"
  echo "###       ###"
  echo "  # {#}   #"
  echo "###  '\######"
  echo "  #       #"
  echo "###       ###"
  echo "  ########"
  echo "   #  #  #"
  echo ""
  echo ""


echo " Welcome to the C.H.I.P Flashing Tool "
echo ""
echo " Instuctions"
echo " ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ "
echo " 1. Remove the C.H.I.P from its case (in case you have a Pocket "
echo "    C.H.I.P)."
echo " 2. Connect the FEL and a GND(Ground) pin of the C.H.I.P with a "
echo "    wire or paperclip."
echo " 3. Connect the C.H.I.P micro USB port to a USB port of your "
echo "    ArchLinux machine."
echo " 5. Make sure that the LEDs beside the micro USB port of the "
echo "    C.H.I.P have turned on"
echo ""
echo " Choose your flavour "
echo " ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ "
echo " 'p' for the Pocket CHIP image "
echo " 's' for the headless server image "
echo " 'g' for the desktop image "
echo " 'b' for the Buildroot image "
echo " 'x' to exit "
echo ""
echo " IMPORTANT NOTICE "
echo " ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ "
echo " If your CHIP is suffering from POWER ISSUES add an 'n' to your "
echo " choice of flavour. "
echo " Example: 'gn' for the No-Limit desktop Image "
echo ""
echo " Additional options "
echo " ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ "
echo " 'f' for Force Clean "
echo ""
echo " ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ "
echo " Then press [enter] to start the process"
echo " [enter] to start the process"

read flavour 

if [ -z "$flavour" ]
then
	echo "No input. Exiting"
	exit 0
fi

setup_enviroment
setup_usergroups
setup_allwinner_udevrules
flash_chip "$flavour"

