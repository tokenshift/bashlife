#!/bin/sh

# Blinker (period 2, 5x5):
# - - - - -
# - - - - -
# - x x x -
# - - - - -
# - - - - -
#
# - - - - -
# - - x - -
# - - x - -
# - - x - -
# - - - - -

LIVE_CELL='x'
DEAD_CELL='-'

output () {
	prev_row="$1"
	curr_row="$2"
	next_row="$3"

	if [ -z "$prev_row" ] && [ -z "$curr_row" ]; then return; fi

	row_neighbors=()
	for (( i=0; i<${#curr_row}; i++ )); do
		cell_neighbors=0

		# Left Column
		if [ $i -gt 0 ]; then
			# Above
			if [ "${prev_row:$((i-1)):1}" = "$LIVE_CELL" ]; then
				(( cell_neighbors++ ))
			fi

			# Current
			if [ "${curr_row:$((i-1)):1}" = "$LIVE_CELL" ]; then
				(( cell_neighbors++ ))
			fi

			# Below
			if [ "${next_row:$((i-1)):1}" = "$LIVE_CELL" ]; then
				(( cell_neighbors++ ))
			fi
		fi

		# Current Column

		# Above
		if [ "${prev_row:$i:1}" = "$LIVE_CELL" ]; then
			(( cell_neighbors++ ))
		fi

		# Below
		if [ "${next_row:$i:1}" = "$LIVE_CELL" ]; then
			(( cell_neighbors++ ))
		fi

		# Right Column

		# Above
		if [ "${prev_row:$((i+1)):1}" = "$LIVE_CELL" ]; then
			(( cell_neighbors++ ))
		fi

		# Current
		if [ "${curr_row:$((i+1)):1}" = "$LIVE_CELL" ]; then
			(( cell_neighbors++ ))
		fi

		# Below
		if [ "${next_row:$((i+1)):1}" = "$LIVE_CELL" ]; then
			(( cell_neighbors++ ))
		fi

		row_neighbors[$i]=$cell_neighbors
	done


	for (( i=0; i<${#curr_row}; i++ )); do
		if [ ${row_neighbors[$i]} -eq 3 ]; then
			echo "$LIVE_CELL\c"
		elif [ "${curr_row:$i:1}" = "$LIVE_CELL" ] && [ ${row_neighbors[$i]} -eq 2 ]; then
			echo "$LIVE_CELL\c"
		else
			echo "$DEAD_CELL\c"
		fi
	done
	echo ""
}

rows=()
row_i=0

while read line; do
	rows[row_i]="$line"

	if [ -z "$line" ]; then
		break
	fi
	
	output "${rows[$(( (row_i + 1) % 3 ))]}" "${rows[$(( (row_i + 2) % 3 ))]}" "${rows[$row_i]}"

	row_i=$(( (row_i + 1) % 3 ))
done

output "${rows[$(( (row_i + 1) % 3 ))]}" "${rows[$(( (row_i + 2) % 3 ))]}" "${rows[$row_i]}"
output "${rows[$(( (row_i + 2) % 3 ))]}" "${rows[$row_i]}" ""