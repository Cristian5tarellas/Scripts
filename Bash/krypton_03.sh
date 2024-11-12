#!/bin/bash
# Name script: krypton_03.sh
# Name author: Cristian Estarellas
# Year: 2023
# Explanation script:
# This script will figure out the password for level 4 of krypton wargame in Overthewire
# https://overthewire.org/wargames/
# The level contains three files, the frequency of letters in these files is the key to 
# know the key that will decrypt the code save in the file krypton4

#######################################################################################
# COLOUR VARIABLES
#######################################################################################

greenColour="\e[0;32m\033[1m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"
endColour="\033[0m\e[0m"

#######################################################################################
# FUNCTIONS
#######################################################################################

# Function Exit ctrl+c
function ctrl_c(){
  echo -e "\n\n${redColour}[+] Closing program ...${endColour}\n"
  tput cnorm; exit 1
}
trap ctrl_c INT

# Function Help: Information of how to use the script
function help_panel(){
  echo -e "${purpleColour}Help Panel:${endColour}"
  echo -e "${grayColour}The script $0 will determine the key for decrypting the password of the level krypton 4 in Overthewire. The script shows the steps of the process.\nThe process take into account to hints:${endColour}"
  echo -e "\t${redColour}[!]${endColour} ${grayColour}Some letters are more prevalent in English than others.${endColour}"
  echo -e "\t${redColour}[!]${endColour} ${grayColour}\"Frequency Analysis\" is your friend.${endColour}"
  echo -e "\n${grayColour}For avoiding errors, you need to run this script in the same folder that you have the files of the level:${endColour}"
  echo -e "\t${blueColour}[+]${endColour}${grayColour} found1${endColour}"
  echo -e "\t${blueColour}[+]${endColour}${grayColour} found2${endColour}"
  echo -e "\t${blueColour}[+]${endColour}${grayColour} found3${endColour}"
  echo -e "\t${blueColour}[+]${endColour}${grayColour} krypton4${endColour}"
}

#######################################################################################
# MAIN PROGRAM
#######################################################################################

#Panel of information
while getopts "h" arg; do
  # Cada parámetro es un caso
  case $arg in
    h) help_panel; exit 0;;
  esac
done

declare -A file
declare -A list_f

# Reading the files needed
file[found1]=$(cat found1)
if [ "$?" != 0 ];then
  echo -e "\n ${redColour}[!] There is an error. Probably you don't have the file needed.\n Check${endColour} ${grayColour}$0 -h${endColour} ${redColour}for help${endColour}"
  exit 1
fi
file[found2]=$(cat found2)
if [ "$?" != 0 ];then
  echo -e "\n ${redColour}[!] There is an error. Probably you don't have the file needed.\n Check${endColour} ${grayColour}$0 -h${endColour} ${redColour}for help${endColour}"
  exit 1
fi
file[found3]=$(cat found3)
if [ "$?" != 0 ];then
  echo -e "\n ${redColour}[!] There is an error. Probably you don't have the file needed.\n Check${endColour} ${grayColour}$0 -h${endColour} ${redColour}for help${endColour}"
  exit 1
fi


echo -e "\n${yellowColour}Information of the files:${endColour}"
# Frequency analysis: Letters
for key in ${!file[@]}; do
  # List of different letters and their frequency in the text
  list_f[$key]=$(echo "${file[$key]}" | tr -d ' ' | grep -o . | sort |uniq -c | sort -nr)
  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}The letters and their number of apperaence for${endColour} ${yellowColour}$key${endColour} ${grayColour}is:${endColour}"
  echo ${list_f[$key]}
  # Total number of different letters
  total_letters=$(echo "${file[$key]}" | tr -d ' ' | grep -o . | sort |uniq | wc -l)
  echo -e "\t${greenColour}[-]${endColour} ${grayColour}Number of different letters:${endColour} ${greenColour}$total_letters${endColour}"  
done

# Total numbers with the three files
for letter in {A..Z}; do
  num_f1=$(echo "${list_f[found1]}" | tr ' ' '\n' | grep $letter -B 1 | head -n 1)
  if [ -z "$num_f1" ];then num_f1=0;fi
  num_f2=$(echo "${list_f[found2]}" | tr ' ' '\n' | grep $letter -B 1 | head -n 1)
  if [ -z "$num_f2" ];then num_f2=0;fi
  num_f3=$(echo "${list_f[found3]}" | tr ' ' '\n' | grep $letter -B 1 | head -n 1)
  if [ -z "$num_f3" ];then num_f3=0;fi
  ave_num=$(echo "scale=3; ($num_f1+$num_f2+$num_f3)" | bc)
  avg_letter+="$ave_num $letter\n" 
done

# Frequency Analysis
echo -e "\n\n${blueColour}Analysis:${endColour}"
echo -e "\n${blueColour}[!]${endColour} ${grayColour}In total, the frequency of the letters is:${endColour}"
echo -e "$avg_letter" | sort -nr | column

dict_decrypt=$(echo -e "$avg_letter" | sort -nr | awk 'NF{print $NF}' | tr -d '\n')
echo -e "\n${blueColour}[+]${endColour} ${grayColour}The ascendent order is:${endColour} ${blueColour}$dict_decrypt${endColour}"
# Frequency Analysis data for American English
most_freq="EATSORNIHCLDUPYFWGMBKVXQJZ"
echo -e "${blueColour}[+]${endColour} ${grayColour}The ascendent order in American English is:${endColour} ${yellowColour}$most_freq${endColour}"


# Final result: the password
echo -e "\n\n${greenColour}Result:${endColour}"

echo -e "\n${greenColour}[+]${endColour} ${grayColour}Comparing our analysis and the frequency of the letters in American English.\n The key is:${endColour}"
echo -e "${greenColour}$dict_decrypt${endColour} ${grayColour}->${endColour} ${yellowColour}$most_freq${endColour}"
echo -e "\n${greenColour}[+]${endColour} ${grayColour}The decrypted file with the password has the following information:${endColour}"
cat krypton4 | tr $dict_decrypt $most_freq | tr -d ' '
password=$(cat krypton4 | tr $dict_decrypt $most_freq | awk 'NF{print $NF}')
echo -e "\n${greenColour}[+]${endColour} ${grayColour}The password is:${endColour} ${greenColour}$password${endColour}"



