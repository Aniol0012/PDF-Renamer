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
    echo -e -n "\nThis program helps you to rename pdfs"
    echo -e ", by default will do it on the current path\n"
    echo -e "List of parameters:\n"
    echo -e "\t-h: Shows this help panel"
    echo -e "\t-c: Creates the specified number of pdf files"
    echo -e "\t-a: Deletes all the pdf files in the current directory"
    echo -e "\t-b: Make backup of the files in the folder named PDF-Backup"
    echo -e "\t-r: Removes the previous backup"
    echo -e "\t-l: Lists all the pdf files"
    echo -e "\t-d: Checks if you have all the dependencies you need, if not, it installs it"
    echo -e "\nExample: ./pdf-renamer.sh -b -a"
    print_line
    exit 0
}

# Checks if you have all the dependencies you need, if not, it installs it

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

# Creates the amount of pdf files are required

create_file() {
    print_line
    print_star
    read -p "Give the name of the file that you want to create: " filename
    print_star
    read -p "How many files do you want to create: " filenumber

    if [[ $(expr "$filenumber" : ^[0-9]) != 1 ]]; then
        print_star
        echo "You need to give a number"
        exit 1
    fi

    if [[ $filenumber > 1 ]]; then
        for ((i = 1; i <= $filenumber; i++)); do
            touch ${filename}_$i.pdf
            echo -e "\t\t- ${filename}_$i.pdf has been created"
        done
        print_star
        echo "All files created"
    elif [[ $filenumber == 1 ]]; then
        touch ${filename}.pdf
        echo -e "\t\t- ${filename}.pdf has been created"
    else
        print_star
        echo "You have to create at least 1 file"
        exit 1
    fi
    print_line
    exit 0
}

# Removes all the pdf files in the current directory

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
            find . -type f ! -name "*.*" -exec rm -f {} \; # Removes all the files that dont have file extension
            print_star
            echo -e "All pdf tests have been removed"
            print_line
            exit 0
        fi
    done
}

# Lists all the pdf files, same as ls *.pdf

list_pdfs() {
    print_line
    if ls -1 *.pdf >/dev/null 2>&1; then
        print_star
        echo "The list of pdfs is:"
        echo -e "$(ls -1 *.pdf)"
        print_line
    else
        print_star
        echo "There are no pdf files to list"
        print_line
        exit 1
    fi
    exit 0
}

# Deletes the backup of files

delete_backup() {
    rm -rf $folder_name
    if [[ $1 == "-f" ]]; then
        print_line
        print_star
        echo "Folder named $folder_name has been removed"
        print_line
        exit 0
    fi
}

# Makes a simple security backup just in case

make_backup() {
    print_line
    delete_backup
    mkdir $folder_name
    for file in *.pdf; do
        cp -f $file $folder_name
    done
    print_star
    echo "The backup has been created in $folder_name"
}

# Renaming files by the given name

rename_file_final() {
    let i+=1
    mv $file ${filename}_$i.pdf
    echo -e "\t\t- $file has been renamed to ${filename}_$i.pdf"
}

rename_file() {
    print_line
    print_star
    let i=0
    echo "Renaming all .pdfs on current path [$(pwd)]:"
    sleep 1
    if ls -1 *.pdf >/dev/null 2>&1; then # Doesent work the other way
        echo -n ""
    else
        print_star
        echo "There are no pdf files to rename"
        print_line
        print_star
        read -p "Do you want to create one? [y/n]: " answer
        if [[ $answer == "yes" || $answer == "y" ]]; then
            create_file
        else
            print_line
            exit 1
        fi
    fi
    echo -e -n "\t"
    print_star
    read -p "Give a filename: " filename
    for file in *.pdf; do
        rename_file_final $i
    done
    print_star
    echo "All files renamed"
    print_line
}

# Main function:

# Checking wich parameters are given
for argument in $@; do
    if [[ $argument == "-h" ]]; then
        help_panel
    elif [[ $argument == "-c" ]]; then
        create_file
    elif [[ $argument == "-b" ]]; then
        make_backup
    elif [[ $argument == "-r" ]]; then
        delete_backup -f
    elif [[ $argument == "-l" ]]; then
        list_pdfs
    elif [[ $argument == "-a" ]]; then
        remove_file
    elif [[ $argument == "-d" ]]; then
        dependencies
    fi
done
rename_file
