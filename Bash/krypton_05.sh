#!/bin/bash
# Name script: krypton_05.sh
# Name author: Cristian Estarellas
# Year: 2023
# Explanation script:
# This script will figure out the password for level 6 of krypton wargame in Overthewire
# https://overthewire.org/wargames/
# The level contains three useful files: found1, found2 and found3
# The password for level 6 is in the file krypton6
#
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
  echo -e "${grayColour}The script $0 will determine the key for decrypting the password of the level krypton 6 in Overthewire. The script shows the steps of the process.${endColour}"
  echo -e "\n${grayColour}For avoiding errors, you need to run this script in the same folder that you have the files of the level:${endColour}"
  echo -e "\t${blueColour}[+]${endColour}${grayColour} found1${endColour}"
  echo -e "\t${blueColour}[+]${endColour}${grayColour} found2${endColour}"
  echo -e "\t${blueColour}[+]${endColour}${grayColour} found3${endColour}"
  echo -e "\t${blueColour}[+]${endColour}${grayColour} krypton6${endColour}"
}

function decryption(){
  
  # Variables
  pass=$1
  key=$2
  pass_trans=""
  #Parameters
  length_abc=26
  len_pass=${#pass}
  # Creating an array to associate the letter to the position
  declare -A abc_id
  declare -a id_abc
  itera=0
  for i in {A..Z};do
    abc_id[$i]=$itera
    id_abc[$itera]=$i
    let itera+=1
  done
  # Repeat key to match the length of the password
  for ((i=0; i<len_pass; i++));do
    key_expanded+=$key
  done
  key_expanded=${key_expanded:0:$len_pass}
  
  for i in $(seq 1 $len_pass);do
    letter_key=$(echo $key_expanded | head -c $i | tail -c 1)
    letter_pass=$(echo $pass | head -c $i | tail -c 1)
    letter_decrypt=$((abc_id[$letter_pass]-abc_id[$letter_key]))
    #if [ $letter_decrypt -lt 0 ];then
    #  let letter_decrypt+=$length_abc
    #fi
    letter_decrypt=$(($letter_decrypt % $length_abc))
    pass_trans+="${id_abc[$letter_decrypt]}"
  done
  echo "$pass_trans"
}
#######################################################################################
# MAIN PROGRAM
#######################################################################################

#Panel of information
while getopts "h" arg; do
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
  echo -e "\n ${redColour}[!] There is an error. Probably you don't have the file needed.\n Check${endColour} ${grayColour}$0 -h${endColour} ${redColour} for help${endColour}"
  exit 1
fi


echo -e "\n${yellowColour}Information of the files:${endColour}\n"
# Frequency analysis: Letters
for key in ${!file[@]}; do
  # List of different letters and their frequency in the text
  list_f[$key]=$(echo "${file[$key]}" | tr -d ' ' | grep -o . | sort | uniq -c | sort -nr)
  echo -e "${yellowColour}[+]${endColour} ${grayColour}The frequency of letters in${endColour} ${yellowColour}$key${endColour} ${grayColour}is:${endColour}"
  echo ${list_f[$key]}
done

echo -e "\n${yellowColour}[+]${endColour} ${grayColour}The total value for each letter is:${endColour}"
echo "${file[found1]}" "${file[found2]}" "${file[found3]}" | tr -d ' ' | grep -o . | sort | uniq -c | sort -nr | column


# Determining the length of the key
echo -e "\n\n${blueColour}Determining the length of the key:${endColour}\n"
# Defining an array for the dictionary
declare -a abc=()
for il in {A..Z};do
  abc+=("$il")
done
echo -e "${blueColour}[+]${endColour} ${grayColour}The letters that we use come from the American English:${endColour}"
echo "${abc[@]}"

# Exploring the problable length of the key
max_length=12
echo -e "${blueColour}[+]${endColour} ${grayColour}Checking the problable length of the key:${endColour}"
echo -e "\t${grayColour}· The maximum value of coincident letters will correspond to the length of the key${endColour}"
echo -e "\t${grayColour} · The maximum length is $max_length letters${endColour}"

declare -a text1=($( cat found1 | tr -d ' ' | fold -w1))
declare -a text2=($( cat found2 | tr -d ' ' | fold -w1))
declare -a text3=($( cat found3 | tr -d ' ' | fold -w1))

shift_max=0
top_coincidence=0
for j in $(seq 1 $max_length);do
count_coincidence=0
  # For found1
  for i in $(seq 0 $((${#text1[@]}-$((1+$j)))));do
    letter_1="${text1[$i]}"               # Original position letter
    letter_2="${text1[$i+j]}"               # Shift position letter
    if [ "$letter_1" == "$letter_2" ];then
      let count_coincidence+=1
    fi
  done
  # For found2
  for i in $(seq 0 $((${#text2[@]}-$((1+$j)))));do
    letter_1="${text2[$i]}"               # Original position letter
    letter_2="${text2[$i+j]}"               # Shift position letter
    if [ "$letter_1" == "$letter_2" ];then
      let count_coincidence+=1
    fi
  done
  # For found3
  for i in $(seq 0 $((${#text3[@]}-$((1+$j)))));do
    letter_1="${text3[$i]}"               # Original position letter
    letter_2="${text3[$i+j]}"               # Shift position letter
    if [ "$letter_1" == "$letter_2" ];then
      let count_coincidence+=1
    fi
  done

  if [ "$count_coincidence" -gt "$top_coincidence" ];then
    top_coincidence=$count_coincidence
    shift_max=$j
  fi
  echo -e "\t${blueColour}[-]${endColour} ${grayColour}Shift of length${endColour} ${blueColour}$j${endColour}${grayColour}: $count_coincidence${endColour}"
done
echo -e "\n${blueColour}[+]${endColour} ${grayColour}Key length:${endColour} ${blueColour}$shift_max${endColour}"

#Decrypting the key
echo -e "\n\n${greenColour}Decrypting the key${endColour}\n" 
# Total numbers with the three files

for i in $(seq 1 $shift_max);do
avg_letter=[]
  for letter in {A..Z}; do
    num_f1=$(echo "${file[found1]}" |  tr -d ' ' | fold -w$shift_max | cut -c $i | sort | uniq -c | grep $letter | awk '{print $1}')
    if [ -z "$num_f1" ];then num_f1=0;fi
    num_f2=$(echo "${file[found2]}" |  tr -d ' ' | fold -w$shift_max | cut -c $i | sort | uniq -c | grep $letter | awk '{print $1}')
    if [ -z "$num_f2" ];then num_f2=0;fi
    num_f3=$(echo "${file[found3]}" |  tr -d ' ' | fold -w$shift_max | cut -c $i | sort | uniq -c | grep $letter | awk '{print $1}')
    if [ -z "$num_f3" ];then num_f3=0;fi
    ave_num=$(echo "scale=3; ($num_f1+$num_f2+$num_f3)" | bc)
    avg_letter+="$ave_num $letter\n" 
  done
  echo -e "${greenColour}[+]${endColour} ${grayColour} Letter${endColour} ${greenColour}$i${endColour}${grayColour}:${endColour}"
  echo -e $avg_letter | sort -rn | awk '{print $2}' | xargs
  pass_code+="$(echo -e $avg_letter | sort -rn | awk '{print $2}' | xargs | head -c 1)"
done

echo -e "\n${greenColour}[+]${endColour}${grayColour} The most frequent letters are:${endColour} ${greenColour}$pass_code${endColour}"

#Decrypting the KEY for the decryption
most_freq_letter="E"
pass_code="OICPIRKXL"
key_codec=$(decryption "$pass_code" "$most_freq_letter")
echo -e "${greenColour}[+]${endColour} ${grayColour}The  key is:${endColour} ${greenColour}$key_codec${endColour}"

#Decrypting the password
password=$(cat krypton6 | tr -d ' ')
password_decrypted=$(decryption "$password" "$key_codec")

echo -e "\n${purpleColour}Solution${endColour}\n"
echo -e "${purpleColour}[+]${endColour} ${grayColour}The password for the level 6 is:${endColour} ${purpleColour}${password_decrypted}${endColour}"
