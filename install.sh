#!/bin/bash

# ================= COLORS =================
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
NC="\e[0m"

echo -e "${CYAN}==============================================${NC}"
echo -e "${GREEN}         SSH-MENU PRO v1.0                    ${NC}"
echo -e "${CYAN}==============================================${NC}"

# ================= INSTALL DEPENDENCIES =================
echo -e "${YELLOW}Updating system & installing packages...${NC}"
apt update -y
apt install -y ssh sed grep nano

BACKUP_DIR="/etc/ssh/backup"
USERPASS_FILE="/etc/ssh/ssh-users.txt"
SSHD_CONFIG="/etc/ssh/sshd_config"

mkdir -p "$BACKUP_DIR"
touch "$USERPASS_FILE"

# ================= DISABLE SOCKET ACTIVATION =================
echo -e "${YELLOW}Disabling SSH socket activation...${NC}"

systemctl stop ssh.socket 2>/dev/null
systemctl disable ssh.socket 2>/dev/null

rm -f /etc/systemd/system/ssh.service.requires/ssh.socket 2>/dev/null
rm -f /etc/systemd/system/sockets.target.wants/ssh.socket 2>/dev/null

systemctl daemon-reload
systemctl restart ssh

echo -e "${GREEN}Socket activation disabled.${NC}"

# ================= BASE SSH FIXES =================
echo -e "${YELLOW}Applying SSH config...${NC}"

sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' "$SSHD_CONFIG"

grep -qxF "AllowTcpForwarding yes" "$SSHD_CONFIG" || echo "AllowTcpForwarding yes" >> "$SSHD_CONFIG"
grep -qxF "PermitTunnel yes" "$SSHD_CONFIG"       || echo "PermitTunnel yes" >> "$SSHD_CONFIG"
grep -qxF "PermitOpen any" "$SSHD_CONFIG"         || echo "PermitOpen any" >> "$SSHD_CONFIG"
grep -qxF "Port 22" "$SSHD_CONFIG"                || echo "Port 22" >> "$SSHD_CONFIG"

systemctl restart ssh

# ================= INSTALL SSH-MENU =================
echo -e "${YELLOW}Installing SSH-MENU PRO...${NC}"

cat << 'EOF' > /usr/local/bin/ssh-menu
#!/bin/bash

# ===== COLORS =====
RED="\e[31m"; GREEN="\e[32m"; YELLOW="\e[33m"; BLUE="\e[34m"; MAGENTA="\e[35m"; CYAN="\e[36m"; NC="\e[0m"

USERPASS_FILE="/etc/ssh/ssh-users.txt"
SSHD_CONFIG="/etc/ssh/sshd_config"
BACKUP_DIR="/etc/ssh/backup"

ensure_env() {
    mkdir -p "$BACKUP_DIR"
    touch "$USERPASS_FILE"
    systemctl enable ssh &>/dev/null

    sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' "$SSHD_CONFIG"

    grep -qxF "AllowTcpForwarding yes" "$SSHD_CONFIG" || echo "AllowTcpForwarding yes" >> "$SSHD_CONFIG"
    grep -qxF "PermitTunnel yes" "$SSHD_CONFIG"       || echo "PermitTunnel yes" >> "$SSHD_CONFIG"
    grep -qxF "PermitOpen any" "$SSHD_CONFIG"         || echo "PermitOpen any" >> "$SSHD_CONFIG"
    grep -qxF "Port 22" "$SSHD_CONFIG"                || echo "Port 22" >> "$SSHD_CONFIG"
}

backup() {
    T=$(date +"%Y-%m-%d_%H-%M-%S")
    cp "$SSHD_CONFIG" "$BACKUP_DIR/sshd_config_$T.bak"
    echo -e "${GREEN}Backup saved.${NC}"
}

restore() {
    echo -e "${CYAN}Available backups:${NC}"
    ls -1t "$BACKUP_DIR"
    read -p "Enter file name: " F
    cp "$BACKUP_DIR/$F" "$SSHD_CONFIG"

    if sshd -t; then
        systemctl restart ssh
        echo -e "${GREEN}Restored.${NC}"
    else
        echo -e "${RED}Invalid config!${NC}"
    fi
}

set_port() {
    read -p "Enter second port: " P
    backup
    sed -i '/^Port /d' "$SSHD_CONFIG"
    echo "Port 22" >> "$SSHD_CONFIG"
    echo "Port $P" >> "$SSHD_CONFIG"

    if sshd -t; then
        systemctl restart ssh
        echo -e "${GREEN}Port $P added.${NC}"
    else
        echo -e "${RED}Error. Rolling back...${NC}"
        restore
    fi
}

list_ports() {
    echo -e "${CYAN}Config ports:${NC}"
    grep "^Port " "$SSHD_CONFIG"
    echo -e "${MAGENTA}\nLive:${NC}"
    ss -tulpn | grep ssh || echo "SSH not listening"
}

add_user() {
    read -p "Username: " U
    read -sp "Password: " P
    echo ""
    useradd -m -d /home/"$U" -s /usr/sbin/nologin "$U"
    echo "$U:$P" | chpasswd
    echo "$U | $P" >> "$USERPASS_FILE"
    echo -e "${GREEN}User created.${NC}"
}

del_user() {
    read -p "Delete user: " U
    userdel -r "$U"
    sed -i "/^$U /d" "$USERPASS_FILE"
    echo -e "${YELLOW}User removed.${NC}"
}

show_users() {
    echo -e "${BLUE}Users:${NC}"
    cat "$USERPASS_FILE"
}

ssh_status() {
    systemctl status ssh --no-pager
    echo -e "\n${MAGENTA}Live:${NC}"
    ss -tulpn | grep ssh
}

# ========== FIXED CONFIRM ==========
ssh_start() {
    systemctl start ssh
    echo -e "${GREEN}SSH started successfully!${NC}"
}

ssh_stop() {
    systemctl stop ssh
    echo -e "${RED}SSH stopped successfully!${NC}"
}

monitor() {
    echo -e "${MAGENTA}Live Monitor (CTRL+C to exit)${NC}"
    while true; do
        ss -tulpn | grep ssh
        sleep 2
        echo ""
    done
}

menu() {
    clear
    echo -e "${GREEN}=========== SSH-MENU PRO v1.0 ===========${NC}"
    echo "1) Start SSH"
    echo "2) Stop SSH"
    echo "3) SSH Status"
    echo "4) Set Second Port"
    echo "5) Show Ports"
    echo "6) Create Tunnel User"
    echo "7) Delete User"
    echo "8) List Users"
    echo "9) Live Monitor"

    # ==== FIXED COLORS ====
    echo -e "${MAGENTA}B) Backup${NC}"
    echo -e "${MAGENTA}R) Restore${NC}"
    echo -e "${YELLOW}0) Exit${NC}"

    read -p "Choose: " C

    case "$C" in
        1) ssh_start ;;
        2) ssh_stop ;;
        3) ssh_status ;;
        4) set_port ;;
        5) list_ports ;;
        6) add_user ;;
        7) del_user ;;
        8) show_users ;;
        9) monitor ;;
        B|b) backup ;;
        R|r) restore ;;
        0) exit ;;
        *) echo "Invalid option" ;;
    esac
}

ensure_env
while true; do menu; read -p "Press Enter…" ; done
EOF

# ==== این سه خط مهم که گفتی ====
chmod +x /usr/local/bin/ssh-menu

echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}   INSTALL DONE! Run using: ssh-menu          ${NC}"
echo -e "${GREEN}==============================================${NC}"
