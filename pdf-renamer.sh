#!/bin/bash

# Decorative fuctions

print_line() {
	for i in {1..80}; do
			echo -n "-" #-n
		done
	echo ""
}

print_star() {
	echo -n "[*] "
}
# Auxiliar functions

folder_name="PDF-Backup"

help_panel() {
	print_line
	echo -e -n "\nThis program helps you to format pdfs"
	echo -e ", by default will do it on the current path\n"
	echo "List of parameters:"
	echo -e "\t-h: Show this help panel"
	echo -e "\t-a: Delete all the pdf files in the current directory"
	echo -e "\t-b: Make backup of the files in the folder named PDF-Backup"
	echo -e "\t-r: Remove the folder of the previous backup"
	echo -e "\t-p: Set the dersired path"
	echo -e "\nExample: ./pdf-renamer.sh -b -p /Users/YOURUSER/Desktop\n"
	print_line
	exit 0
}

dependencies() {
	clear; dependencies=(brew npm)
	print_line
	print_star
	echo -e "Checking programs..."
	sleep 2

	for program in "${dependencies[@]}"; do
		$program --version > /dev/null 2>&1

		if [[ "$(echo $?)" == 0 ]]; then
			echo -e -n "\t$program is installed\n"
		else
			echo "$program is not installed"
			echo "Installing $program..."
			sleep 2
			apt-get install $program -y 2>&1
		fi
	done
	print_line
	echo ""
}

delete_backup() {
	rm -rf $folder_name
	if [[ $1 == "-f" ]];then
		print_star; echo "Folder named $folder_name has been removed"
		exit 0 # We need to exit, if not progam would still be running
	fi
}

make_backup() {
	delete_backup
	mkdir $folder_name
	for file in *.pdf; do
		cp $file $folder_name
	done
	print_star; echo "The backup has been created in $folder_name"
	sleep 1
}

format_file_file() { # Not working
	# extract the year and semester from the file name
	year=${file:0:4};echo "$year"
	semester=${file:5:1}

	# remove the spaces and special characters from the file name
	new_file=${file//[ -º]/_}

	# rename the file
	#mv "$file" "$year-${semester}_$new_file/Solucion"
}

format_file() {
	print_line
	# By now they are not needed
	#dependencies 
	print_star
	echo -n "Formatting all .pdfs on "
	if [[ $(echo $given_path) != "" ]]; then
		echo "path [$(echo $given_path)]"
		sleep 1
		for file in $given_path.pdf; do
			format_file_file $file
			echo -e "\t- $file has been formated"
		done
	else
		echo "current path [$(pwd)]:"
		sleep 1
		for file in *.pdf; do
			format_file_file
			echo -e "\t- $file has been formated"
		done
	fi
	print_star; echo "All files formated"; sleep 1; print_line
}

# Main function:

# Checking wich parameters are given
declare -i parameter_counter=0
while getopts ":p:b:h:" arg; do
	case $arg in # Not sure if this works for "b" and "h"
		p) given_path=$OPTARG; let parameter_counter+=1 ;;
		b) make_backup; let parameter_counter+=1 ;;
		h) help_panel ;;
	esac
done
	for argument in $@; do

		if [[ $argument == "-h" ]]; then
			help_panel
		elif [[ $argument == "-b" ]]; then
			make_backup
		elif [[ $argument == "-r" ]]; then
			delete_backup -f
		elif [[ $argument == "-a" ]]; then
			for file in *.pdf; do
				if [[ $file == "*.pdf" ]]; then # In case there are no pdf files the $file is equal as in the for loop
					print_line;print_star;echo "There are no pdf files to remove";print_line
					exit 1
				else
					rm -rf $file
					print_line; echo -e "\t- $file has been removed"
					print_star; echo "All pdf files have been removed"
					print_line
					exit 0
				fi
			done
		fi
	done
if [[ $parameter_counter > 2 ]]; then
	help_panel
elif [[ $parameter_counter == 0 ]]; then
	format_file
fi