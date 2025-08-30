#!/bin/bash

# Script to list and run Ansible playbooks from the 'tasks' directory on localhost

TASKS_DIR="tasks"

# Check if tasks directory exists
if [ ! -d "$TASKS_DIR" ]; then
	echo "Error: Directory '$TASKS_DIR' does not exist."
	exit 1
fi

# Find all .yml files in tasks directory
PLAYBOOKS=$(find "$TASKS_DIR" -type f -name "*.yml" -printf "%f\n" | sort)

if [ -z "$PLAYBOOKS" ]; then
	echo "No Ansible playbooks found in '$TASKS_DIR'."
	exit 0
fi

# Add 'all' and 'quit' options
OPTIONS="all quit $PLAYBOOKS"

echo "Available playbooks in '$TASKS_DIR':"
select PLAYBOOK in $OPTIONS; do
	if [ "$PLAYBOOK" = "quit" ]; then
		echo "Exiting."
		exit 0
	elif [ "$PLAYBOOK" = "all" ]; then
		echo "Running all playbooks..."
		for pb in $PLAYBOOKS; do
			echo "Running $pb..."
			ansible-playbook -i localhost, "$TASKS_DIR/$pb"
			if [ $? -ne 0 ]; then
				echo "Error running $pb."
			fi
		done
		echo "All playbooks executed."
		exit 0
	elif [ -n "$PLAYBOOK" ]; then
		echo "Running $PLAYBOOK..."
		ansible-playbook -i localhost, "$TASKS_DIR/$PLAYBOOK"
		if [ $? -ne 0 ]; then
			echo "Error running $PLAYBOOK."
		else
			echo "$PLAYBOOK executed successfully."
		fi
		# Ask if user wants to run another
		read -p "Run another? (y/n): " choice
		if [ "$choice" != "y" ]; then
			exit 0
		fi
	else
		echo "Invalid selection."
	fi
done
