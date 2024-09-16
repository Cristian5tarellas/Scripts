#!/bin/bash
# Name script: brute_ceasar.sh
# Name author: Cristian Estarellas
# Year: 2023
# Explanation script:
# This scritp is focused on decrypt the cryptographic technique ceasar (rot).
# The main goal is to get access to the levels 2 and 3 in the server krypton of Overthewire (wargames):
# https://overthewire.org/wargames/
# The levels that we have to indicate are:
# level="2"                             #For level 1->2
# password="YRIRY GJB CNFFJBEQ EBGGRA"  #For level 1->2
#
# level="3"                             #For level 2->3
# password="OMQEMDUEQMEK"               #For level 2->3
# Important!!! The password I indicate in this explanation is the password in the year 2024.
# This could change in the future:
# host="krypton${level}@krypton.labs.overthewire.org"
# port="2231"
#
# Additionally this script has two different functions:
# 1) A function to apply all possible combinations (decrypt)
# 2) A function to apply a specific combination (rot_decrypt)
#
# To have information about the use of the script: ./brute_ceasar.sh -h

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
  echo -e "\n${purpleColour}[+] Script help pannel: ${endColour}"
  echo -e "\n${grayColour}The parameters that you can use are:${endColour}" 
  echo -e "\t${purpleColour}-p)${endColour} ${grayColour}The password or information crypted in ceasar.${endColour}"
  echo -e "\t${purpleColour}-l)${endColour} ${grayColour}If you want to use it for exercise of krypton in Overthewire. You have to indicate the exercise. You only have this two options:${endColour}"
  echo -e "\t\t${yellowColour} -l 2${endColour} ${grayColour} for level1->2${endColour}"
  echo -e "\t\t${yellowColour} -l 3${endColour} ${grayColour} for level2->3${endColour}"
  echo -e "\t${purpleColour}-r)${endColour} ${grayColour}Indicate the number of the combination to use to decrypt the information${endColour}"
  echo -e "\t${purpleColour}-h)${endColour} ${grayColour}Help panel${endColour}"
}

# Function decrypt:
# This function will translate the text to the different combinations of encryption ceasar (26 combinations)
function decrypt(){
  password=$1
  
  declare -a L_capital=(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z)
  declare -a L_low=(a b c d e f g h i j k l m n o p q r s t u v w x y z) 
  
  tput civis
  for i in {0..25}; do
    # Starting with the brute force
    A_cap="${L_capital[$i]}"
    A_low="${L_low[$i]}"
    Z_cap="${L_capital[$(($i+1))]}"
    Z_low="${L_low[$(($i+1))]}"
    # Last combination
    if [ "$i" -eq 25 ];then
      Z_cap="A"; Z_low="a"
    fi
    # Decrypting the infromation for a specific rot 
    change="$Z_cap-ZA-$A_cap$Z_low-za-$A_low"
    decrypt=$(echo $password | tr 'A-Za-z' $change)
    
    # Output of the information decrypted
    echo -e "\n${yellowColour}[-] ROT$(($i+1)):${endColour}"
    echo -e "${yellowColour}[+]${endColour}${grayColour} Changing${endColour} ${yellowColour}A${endColour} ${grayColour}->${endColour} ${yellowColour}$Z_cap${endColour} ${grayColour}y${endColour} ${yellowColour}a${enColour} ${grayColour}->${endColour} ${yellowColour}$Z_low${endColour}"
    echo -e "${redColour}[!]${endColour} ${grayColour}The encrypted message is:${endColour} ${redColour}$password${endColour}"
    echo -e "${blueColour}[!]${endColour} ${grayColour}The decrypted message is :${endColour} ${blueColour}$decrypt${endColour}"
  
  done
  tput cnorm

}

# Function krypton_decrypt:
# This function will determine the password that will connect to the level krypton of Overthewire. This script will determine the password for level 2 and 3.
function krypton_decrypt(){
  password=$1
  level=$2
  # Checking if the level selected is valid
  if [ "$level" -ne 2 ] && [ "$level" -ne 3 ];then
    echo -e "\n${redColour}[!] The level provided is not valid for this script. Check${endColour} ${grayColour}$0 -h${endColour} ${redColour}for help.${endColour}"
    exit 1
  fi

  declare -a L_capital=(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z)
  declare -a L_low=(a b c d e f g h i j k l m n o p q r s t u v w x y z)

  tput civis
  for i in {0..25}; do
    {
    # Starting with the brute force
    A_cap="${L_capital[$i]}"
    A_low="${L_low[$i]}"
    Z_cap="${L_capital[$(($i+1))]}"
    Z_low="${L_low[$(($i+1))]}"
    # Last combination
    if [ "$i" -eq 25 ];then
      Z_cap="A"; Z_low="a"
    fi

    # Decrypting the infromation for a specific rot 
    change="$Z_cap-ZA-$A_cap$Z_low-za-$A_low"
    decrypt=$(echo $password | tr 'A-Za-z' $change)
    pass=$(echo $decrypt | awk 'NF{print $NF}')
 
    # Testing the password
    host="krypton${level}@krypton.labs.overthewire.org"
    port="2231"
    sshpass -p "$pass" ssh -q $host -p $port exit
    # If the password works we show the password desencrypted
    if [ "$?" -eq 0 ];then
      echo -e "\n${blueColour}[+]${endColour} ${grayColour}The method is${endColour} ${yellowColour}ROT$(($i+1))${endColour}"
      echo -e "${blueColour}[+]${endColour} ${grayColour}The password is:${endColour} ${blueColour}$pass${endColour}\n"
      tput cnorm; exit 0
    fi
  } &
  done

  wait
  tput cnorm

}

# Function rot_decrypt:
# This function will use the rotation indicated for decrypting the password
function rot_decrypt(){
  password=$1
  rot=$2
  # Checking if the value rot is valid
  if [ "$rot" -gt 26 ] || [ "$rot" -lt 1 ];then
    echo -e "\n${redColour}[!] The value rot provided is not valid. Check${endColour} ${grayColour}$0 -h${endColour} ${redColour}for help.${endColour}"
    exit 1
  fi

  declare -a L_capital=(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z)
  declare -a L_low=(a b c d e f g h i j k l m n o p q r s t u v w x y z) 

  A_cap="${L_capital[$(($rot-1))]}"
  A_low="${L_low[$(($rot-1))]}"
  Z_cap="${L_capital[$rot]}"
  Z_low="${L_low[$rot]}"
  # Last combination
  if [ "$rot" -eq 26 ];then
    Z_cap="A"; Z_low="a"
  fi
  # Decrypting the infromation for a specific rot 
  change="$Z_cap-ZA-$A_cap$Z_low-za-$A_low"
  decrypt=$(echo $password | tr 'A-Za-z' $change)
    
  # Output of the information decrypted
  echo -e "\n${yellowColour}[-] ROT$(($rot)):${endColour}"
  echo -e "${yellowColour}[+]${endColour}${grayColour} Changing${endColour} ${yellowColour}A${endColour} ${grayColour}->${endColour} ${yellowColour}$Z_cap${endColour} ${grayColour}y${endColour} ${yellowColour}a${enColour} ${grayColour}->${endColour} ${yellowColour}$Z_low${endColour}"
  echo -e "${redColour}[!]${endColour} ${grayColour}The encrypted message is:${endColour} ${redColour}$password${endColour}"
  echo -e "${blueColour}[!]${endColour} ${grayColour}The decrypted message is :${endColour} ${blueColour}$decrypt${endColour}"
  
}

#######################################################################################
# MAIN PROGRAM
#######################################################################################

pass_count=0
extra_count=0
#Panel of information
while getopts "p:l:r:h" arg; do
  # Cada parámetro es un caso
  case $arg in
    p) password="$OPTARG"; let pass_count+=1;; 
    l) level="$OPTARG"; let extra_count+=1;;
    r) rotation="$OPTARG"; let extra_count+=2;;
    h) help_panel; exit 0;;
  esac
done

# To manage properly the positional argument
shift $(($OPTIND -1))  # Shift to move the arguments to the left


# Checking the input
if [ -z "$password" ]; then
  echo -e "\n${redColour}[!] You have to indicate the password or the information to decrypt with the parameter${endColour} ${yellowColour}-p${endColour}"
  echo -e "${redColour}[+]${endColour} ${grayColour}You can use${endColour} ${yellowColour}$0 -h${endColour} ${grayColour}for help${endColour}"
  exit 1
fi

# Using the function needed depending on the parameters
if [ "$extra_count" -eq 0 ];then
  # Decrypting using all possible combinations
  decrypt "$password"
elif [ "$extra_count" -eq 1 ];then
  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Decodifying the password to enter in level${endColour} ${yellowColour}$level${endColour} ${grayColour}...${endColour}"
  krypton_decrypt "$password" "$level"
elif [ "$extra_count" -eq 2 ];then
  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Decrypting the password for the technique:${endColour}"
  rot_decrypt "$password" "$rotation"
fi
