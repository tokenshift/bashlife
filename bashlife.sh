#!/bin/sh
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

# Options:
# -r {N}
# Perform N iterations/frames. -1 means iterate infinitely.
# -p {seconds}
# Pause for user input between each frame.

PAUSE_BETWEEN_FRAMES=0
ITERATIONS=1

for arg in "$@"; do
	if [ "$setting" = "iterations" ]; then
		ITERATIONS="$arg"
		setting=''
	elif [ "$setting" = "pause" ]; then
		PAUSE_BETWEEN_FRAMES="$arg"
		setting=''
	elif [ "$arg" = "-r" ]; then
		setting="iterations"
	elif [ "$arg" = "-p" ]; then
		setting="pause"
	else
		>&2 echo "Unrecognized argument: $arg"
		exit 1
	fi
done

for (( i=0; i!=$ITERATIONS; i++ )); do
	old_temp_file="$new_temp_file"
	new_temp_file=`mktemp -t bashlife`

	if [ "$i" -eq 0 ]; then
		# Read initial state from stdin
		processInput | tee "$new_temp_file"
	else
		if [ "$PAUSE_BETWEEN_FRAMES" -ne 0 ]; then
			sleep $PAUSE_BETWEEN_FRAMES
		fi

		# Read state from temp file
		processInput < "$old_temp_file" | tee "$new_temp_file"
	fi
done