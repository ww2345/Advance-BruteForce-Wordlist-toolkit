#!/bin/bash

# ================== AUTHOR ==================
AUTHOR="Ishant Dahiya"
VERSION="1.0"

# ================== INTEGRITY CHECK ==================
EXPECTED_HASH="ORIGINAL_HASH_PLACEHOLDER"

CURRENT_HASH=$(sha256sum "$0" 2>/dev/null | awk '{print $1}')

if [[ "$EXPECTED_HASH" != "ORIGINAL_HASH_PLACEHOLDER" && "$CURRENT_HASH" != "$EXPECTED_HASH" ]]; then
  echo -e "\e[31m⚠️ Warning: This script has been modified! Author: $AUTHOR\e[0m"
  sleep 2
fi

# ================== COLORS ==================
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
RESET="\e[0m"

# ================== BANNER ==================
banner() {
  clear
  echo -e "${CYAN}"
  echo "==========================================="
  echo "        🔥 WORDLIST TOOLKIT PRO 🔥"
  echo "==========================================="
  echo -e " Author: ${AUTHOR} | Version: ${VERSION}"
  echo "==========================================="
  echo -e "${RESET}"
}

pause() {
  read -p "Press Enter to continue..."
}

# ================== SPINNER ==================
spinner() {
  local pid=$!
  local spin='-\|/'
  local i=0
  while kill -0 $pid 2>/dev/null; do
    i=$(( (i+1) %4 ))
    printf "\r${CYAN}Processing... ${spin:$i:1}${RESET}"
    sleep .1
  done
  printf "\r"
}

# ================== COMBINER ==================
combiner() {
  echo -e "${YELLOW}Enter input files (space separated):${RESET}"
  read -e -a files

  read -e -p "Enter output file: " output
  read -e -p "Separator (default: none): " sep
  read -e -p "Reverse order? (y/n): " rev

  sep="${sep:-}"

  tmp="tmp_$$.txt"
  cp "${files[0]}" "$tmp"

  (
    for ((i=1; i<${#files[@]}; i++)); do
      next_tmp="tmp_${i}_$$.txt"
      > "$next_tmp"

      while IFS= read -r a; do
        while IFS= read -r b; do
          if [[ "$rev" == "y" ]]; then
            echo "${b}${sep}${a}" >> "$next_tmp"
          else
            echo "${a}${sep}${b}" >> "$next_tmp"
          fi
        done < "${files[$i]}"
      done < "$tmp"

      mv "$next_tmp" "$tmp"
    done

    mv "$tmp" "$output"
  ) &

  spinner

  echo -e "${GREEN}✅ Done! Saved to $output${RESET}"
  pause
}

# ================== MERGE ==================
merge_files() {
  read -e -p "Enter file1: " f1
  read -e -p "Enter file2: " f2
  read -e -p "Enter output file: " out

  cat "$f1" "$f2" > "$out"

  echo -e "${GREEN}✅ Files merged into $out${RESET}"
  pause
}

# ================== NUMBER GENERATOR ==================
number_gen() {
  read -e -p "Enter number of digits: " digits

  if ! [[ "$digits" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Invalid input${RESET}"
    pause
    return
  fi

  out="numbers_${digits}.txt"
  max=$((10**digits - 1))

  (seq -w 0 $max > "$out") &
  spinner

  echo -e "${GREEN}✅ Saved to $out${RESET}"
  pause
}

# ================== USAGE ==================
usage() {
  clear
  echo -e "${CYAN}========== 📘 TOOL USAGE GUIDE ==========${RESET}"

  echo -e "${YELLOW}🔹 What this tool does:${RESET}"
  echo "Creates combinations (Cartesian product) of multiple wordlists."
  echo "It does NOT just pair one-to-one — it combines ALL possibilities."
  echo

  echo -e "${GREEN}🔹 Example (IMPORTANT):${RESET}"

  echo "file1.txt:"
  echo "anup"
  echo "raj"
  echo

  echo "file2.txt:"
  echo "123"
  echo "456"
  echo

  echo -e "${CYAN}Output will be:${RESET}"
  echo "anup123"
  echo "anup456"
  echo "raj123"
  echo "raj456"
  echo

  echo -e "${YELLOW}👉 Notice:${RESET}"
  echo "- Each word from file1 combines with ALL words from file2"
  echo "- Not just one-to-one matching"
  echo

  echo -e "${GREEN}🔹 Multi-file example:${RESET}"
  echo "file1: names → anup"
  echo "file2: nums → 123"
  echo "file3: symbols → @"
  echo

  echo "Output:"
  echo "anup123@"
  echo

  echo -e "${YELLOW}🔹 Use cases:${RESET}"
  echo "- Test your own password strength"
  echo "- Learn password patterns"
  echo "- Generate structured datasets"
  echo

  echo -e "${RED}⚠️ Use responsibly on authorized systems only${RESET}"

  pause
}

# ================== MAIN MENU ==================
while true; do
  banner

  echo -e "${YELLOW}1) Combine multiple files${RESET}"
  echo -e "${YELLOW}2) Merge two files${RESET}"
  echo -e "${YELLOW}3) Generate number wordlist${RESET}"
  echo -e "${YELLOW}4) Usage / Help${RESET}"
  echo -e "${RED}0) Exit${RESET}"
  echo

  read -e -p "Select option: " choice

  case $choice in
    1) combiner ;;
    2) merge_files ;;
    3) number_gen ;;
    4) usage ;;
    0) exit ;;
    *) echo -e "${RED}Invalid option${RESET}"; sleep 1 ;;
  esac
done