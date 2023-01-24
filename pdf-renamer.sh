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
	echo -e "\t-c: Creates the specified number of files in the current directory"
	echo -e "\t-a: Deletes all the pdf files in the current directory"
	echo -e "\t-b: Make backup of the files in the folder named PDF-Backup"
	echo -e "\t-r: Removes the previous backup"
	echo -e "\t-p: Set the dersired path"
	echo -e "\nExample: ./pdf-renamer.sh -b -p /Users/YOURUSER/Desktop\n"
	print_line
	exit 0
}

dependencies() {
	clear
	dependencies=(brew npm)
	print_line
	print_star
	echo -e "Checking programs..."
	sleep 2

	for program in "${dependencies[@]}"; do
		$program --version >/dev/null 2>&1

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
	if [[ $1 == "-f" ]]; then
		print_star
		echo "Folder named $folder_name has been removed"
		exit 0
	fi
}

remove_file() {
	for file in *.pdf; do
		if [[ $file == "*.pdf" ]]; then # In case there are no pdf files the $file is equal as in the for loop
			print_line
			print_star
			echo "There are no pdf files to remove"
			print_line
			exit 1
		else
			print_line
			rm -rf *.pdf
			print_star
			echo -e "All pdf tests have been removed"
			print_line
			exit 0
		fi
	done
}

make_backup() {
	delete_backup
	mkdir $folder_name
	for file in *.pdf; do
		cp $file $folder_name
	done
	print_star
	echo "The backup has been created in $folder_name"
}

rename_file() {
	let i+=1
	mv $file ${filename}_$i.pdf
	echo -e "\t\t- $file has been formated to ${filename}_$i.pdf"
}

format_file() {
	print_line
	# By now they are not needed
	#dependencies
	print_star
	let i=0
	echo -n "Formatting all .pdfs on "
	if [[ $(echo $given_path) != "" ]]; then
		echo "path [$(echo $given_path)]"
		sleep 1
		for file in $given_path.pdf; do
			rename_file $i
		done
	else
		echo "current path [$(pwd)]:"
		sleep 1
		echo -e -n "\t"
		print_star
		read -p "Give a filename: " filename
		for file in *.pdf; do
			rename_file $i
		done
	fi
	print_star
	echo "All files formated"
	sleep 1
	print_line
}

create_file() {
	print_line
	print_star
	read -p "Give the name of the file that you want to create: " filename
	print_star
	read -p "How many files do you want to create: " filenumber
	for ((i = 1; i < $filenumber; i++)); do
		touch ${filename}_$i.pdf
		echo -e "\t\t- ${filename}_$i.pdf has been created"
	done
	print_star
	echo "All files created"
	sleep 1
	print_line
	exit 0
}

# Main function:

# Checking wich parameters are given
declare -i parameter_counter=0
while getopts ":p:b:h:" arg; do
	case $arg in # Not sure if this works for "b" and "h"
	p)
		given_path=$OPTARG
		let parameter_counter+=1
		;;
	b)
		make_backup
		let parameter_counter+=1
		;;
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
	elif [[ $argument == "-c" ]]; then
		create_file
	elif [[ $argument == "-a" ]]; then # fix this and makeit into a function
		remove_file
	fi
done
if [[ $parameter_counter > 2 ]]; then
	help_panel
elif [[ $parameter_counter == 0 ]]; then
	format_file
fi
