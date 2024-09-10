#!/bin/bash

# Install dependencies
echo "Installing dependencies..."
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo apt update
    sudo apt install -y zenity xclip
elif [[ "$OSTYPE" == "darwin"* ]]; then
    brew install zenity xclip
fi

# Create the SSH password manager function
SSH_FUNC=$(cat <<EOF
function ssh() {
    local host="\$1"
    local password=\$(grep "\$host" ~/.ssh_passwords | cut -d ':' -f2)

    # Check if the password exists
    if [ -z "\$password" ]; then
      # If no password is found or the host is not in the file, proceed with the actual ssh command
      command ssh "\$@"
      return
    fi

    # Show Zenity dialog with custom title, increased width, and no lightbulb icon
    zenity --question --text="Password for \$host: \$password" \\
           --ok-label="Copy Password" \\
           --cancel-label="Close" \\
           --title="Password Manager" \\
           --width=400 \\
           --no-markup 2>/dev/null

    # If the "Copy Password" button was pressed
    if [ \$? -eq 0 ]; then
        # Copy the password to the clipboard based on the platform
        if [[ "\$OSTYPE" == "linux-gnu"* ]]; then
            echo -n "\$password" | xclip -selection clipboard
        elif [[ "\$OSTYPE" == "darwin"* ]]; then
            echo -n "\$password" | pbcopy
        fi
    fi

    # Proceed with the actual ssh command
    command ssh "\$@"
}
EOF
)

# Add the SSH function to .bashrc or .zshrc
if [[ "$SHELL" == *"zsh" ]]; then
    echo "$SSH_FUNC" >> ~/.zshrc
    source ~/.zshrc
    echo "Added SSH function to .zshrc"
else
    echo "$SSH_FUNC" >> ~/.bashrc
    source ~/.bashrc
    echo "Added SSH function to .bashrc"
fi

# Create the .ssh_passwords file if it doesn't exist
if [ ! -f ~/.ssh_passwords ]; then
    touch ~/.ssh_passwords
    echo "Created ~/.ssh_passwords file. Add your host and passwords in the format 'username@hostname:password'."
fi

echo "Please do source ~/.bashrc or source ~/.zshrc if dialogbox not opens"
echo "Setup complete. You can now use the password manager with the 'ssh' command."
