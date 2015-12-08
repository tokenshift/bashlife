#!/bin/sh

# Options:
# -r {N}
# Perform N iterations/frames.
# -p
# Pause for user input between each frame.

LIVE_CELL='x'
DEAD_CELL='-'

prev_row=''
curr_row=''
next_row=''

processLine () {
	# echo "[ <$prev_row> <$curr_row> <$next_row> ]"

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

processInput () {
	while read line; do
		if [ -z "$line" ]; then
			break
		fi

		prev_row="$curr_row"
		curr_row="$next_row"
		next_row="$line"
		processLine
	done

	prev_row="$curr_row"
	curr_row="$next_row"
	next_row=""
	processLine

	prev_row="$curr_row"
	curr_row=""
	next_row=""
	processLine
}

processInput