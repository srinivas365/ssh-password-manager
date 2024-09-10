# Terminal Password Manager

This script sets up a terminal-based password manager for SSH commands in macOS and Linux. It will display a dialog with the password when you run `ssh` or `sudo su`.

## Setup

To set up the password manager, run the following command:

```bash
curl -sSL https://raw.githubusercontent.com/srinivas365/terminal-password-manager/main/setup.sh | bash

# Add your host and passwords in the format 'username@hostname:password' to ~/.ssh_passwords
```
