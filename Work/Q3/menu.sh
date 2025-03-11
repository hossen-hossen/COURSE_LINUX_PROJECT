#!/usr/bin/env bash

current_csv=""
plot_script="../Q2/plant_plots.py"  # Adjust if needed

new_csv() {
  echo "CSV file name to create or overwrite?"
  read fname
  if [ -f "$fname" ]; then
    echo "File '$fname' already exists. Overwrite? (y/n)"
    read yn
    [ "$yn" != "y" ] && echo "Aborted." && return
  fi
  echo "Plant,Height,LeafCount,DryWeight" > "$fname"
  current_csv="$fname"
  echo "Created $fname and set as current."
}

pick_csv() {
  echo "Enter path of an existing CSV:"
  read fname
  [ ! -f "$fname" ] && echo "No file '$fname' found!" && return
  current_csv="$fname"
  echo "Selected $current_csv"
}

show_csv() {
  [ -z "$current_csv" ] && echo "No CSV is selected." && return
  echo "---- $current_csv ----"
  cat "$current_csv"
}

add_plant_line() {
  [ -z "$current_csv" ] && echo "No CSV is selected." && return
  echo "Enter Plant name:"
  read p
  echo "Height data (e.g. 50 55 60):"
  read h
  echo "LeafCount data (e.g. 30 34 38):"
  read l
  echo "DryWeight data (e.g. 1.8 2.0 2.3):"
  read d
  # store them with quotes around multi-value fields
  echo "${p},\"${h}\",\"${l}\",\"${d}\"" >> "$current_csv"
  echo "Added line for $p."
}

run_q2() {
  [ -z "$current_csv" ] && echo "No CSV is selected." && return
  [ ! -f "$plot_script" ] && echo "Missing $plot_script" && return
  echo "Which plant do you want to plot?"
  read p
  line=$(grep -i "^$p," "$current_csv")
  [ -z "$line" ] && echo "No row found for '$p'." && return
  # remove quotes
  no_quotes=$(echo "$line" | sed 's/\"//g')
  IFS=',' read -r col1 col2 col3 col4 <<< "$no_quotes"
  echo "Running Python for $col1"
  python3 "$plot_script" --plant "$col1" --height $col2 --leaf_count $col3 --dry_weight $col4
}

update_line() {
  [ -z "$current_csv" ] && echo "No CSV is selected." && return
  echo "Which plant to update?"
  read pname
  oldline=$(grep -i "^$pname," "$current_csv")
  [ -z "$oldline" ] && echo "No row for $pname" && return
  echo "Found: $oldline"
  # parse old data
  oq=$(echo "$oldline" | sed 's/"//g')
  IFS=',' read -r o_plant o_h o_l o_d <<< "$oq"
  # read new data
  echo "New height (blank=keep old):"
  read nh
  echo "New leaf count (blank=keep old):"
  read nl
  echo "New dry weight (blank=keep old):"
  read nd
  [ -z "$nh" ] && nh="$o_h"
  [ -z "$nl" ] && nl="$o_l"
  [ -z "$nd" ] && nd="$o_d"
  updated_line="${o_plant},\"${nh}\",\"${nl}\",\"${nd}\""
  sed -i "s~^$pname,.*~$updated_line~I" "$current_csv"
  echo "Updated $pname"
}

delete_line() {
  [ -z "$current_csv" ] && echo "No CSV is selected." && return
  echo "Delete by (1) plant or (2) row index?"
  read choice
  case "$choice" in
    1)
      echo "Which plant to delete?"
      read dp
      sed -i "/^$dp,/Id" "$current_csv"
      echo "Removed lines for $dp"
      ;;
    2)
      echo "Enter row index to delete (1=first data row):"
      read ridx
      awk -v i=$((ridx+1)) 'NR==1 || NR!=i' "$current_csv" > tmpfile && mv tmpfile "$current_csv"
      echo "Deleted row $ridx"
      ;;
    *)
      echo "Invalid choice."
      ;;
  esac
}

max_leaves() {
  [ -z "$current_csv" ] && echo "No CSV is selected." && return
  tail -n +2 "$current_csv" | while IFS= read -r line; do
    stripq=$(echo "$line" | sed 's/"//g')
    IFS=',' read -r pname hh ll dd <<< "$stripq"
    arr=($ll)
    s=0; c=0
    for val in "${arr[@]}"; do
      s=$(awk -v sm=$s -v vt=$val 'BEGIN{printf "%.2f", sm+vt}')
      ((c++))
    done
    [ $c -gt 0 ] && avg=$(awk -v sm=$s -v ct=$c 'BEGIN{printf "%.2f", sm/ct}') && echo "$pname,$avg"
  done | sort -t',' -k2 -nr | head -n1 | while IFS=',' read -r top avg; do
    echo "Plant with highest average leaves: $top ($avg)"
  done
}

while true; do
  echo ""
  echo "==== PLANT CSV MENU ===="
  echo "1) Create/Overwrite CSV"
  echo "2) Select existing CSV"
  echo "3) Show CSV"
  echo "4) Add plant line"
  echo "5) Run Q2 Python code on a plant"
  echo "6) Update line (by plant)"
  echo "7) Delete line (by plant or index)"
  echo "8) Plant with greatest average leaves"
  echo "9) Exit"
  read opt
  case "$opt" in
    1) new_csv ;;
    2) pick_csv ;;
    3) show_csv ;;
    4) add_plant_line ;;
    5) run_q2 ;;
    6) update_line ;;
    7) delete_line ;;
    8) max_leaves ;;
    9) echo "Goodbye."; break ;;
    *) echo "Invalid option." ;;
  esac
done
