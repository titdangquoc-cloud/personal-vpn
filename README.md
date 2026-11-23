# personal-vpn
Self-hosted WireGuard VPN
Project log starts 12 Nov 2026

## What this project does

A self-hosted WireGuard VPN on a DigitalOcean server in Sydney. My laptop and phone send their internet traffic through an encrypted tunnel to the server. The server filters DNS with AdGuard Home, sends a daily security report to Discord, and is built entirely from code (Terraform and Ansible), so it can be rebuilt from scratch.

## Architecture

```
Laptop / phone
   │  encrypted WireGuard tunnel (UDP 51820)
   ▼
Server (Ubuntu 24.04, Sydney)
   ├── WireGuard (wg0, 10.8.0.1)
   ├── AdGuard Home (DNS filter on 10.8.0.1:53)
   ├── ufw + cloud firewall (default deny)
   ├── fail2ban (bans repeated failed SSH logins)
   └── daily report script → Discord
   │  NAT (MASQUERADE)
   ▼
Internet
```

## Security decisions

- **SSH:** key-only login, root login disabled, one admin user. The cloud firewall only allows SSH from my home IP.
- **Firewall:** default deny for incoming traffic. Only UDP 51820 is open to the internet. DNS and the AdGuard dashboard are only reachable through the VPN.
- **Brute-force protection:** fail2ban bans an IP for 1 hour after 3 failed SSH logins.
- **Secrets:** private keys stay on the devices that use them. The Discord webhook is encrypted with Ansible Vault. `.vault_pass`, `clients/` and Terraform state files are gitignored.
- **Updates:** automatic security updates through unattended-upgrades.
- **Repeatable setup:** infrastructure and configuration are code. Re-running the playbook makes no changes (`changed=0`).

## Test results

| Test | Result | Evidence |
|---|---|---|
| Port scan (TCP) | SSH, DNS and AdGuard ports show as filtered from outside | [nmap TCP](docs/screenshots/10-nmap-tcp.png) |
| Port scan (UDP) | WireGuard port is open or filtered | [nmap UDP](docs/screenshots/11-nmap-udp.png) |
| DNS not open to the internet | Queries to the server time out | [dig](docs/screenshots/12-dig-timeout.png) |
| IP leak | Shows the server's IP, no home IP | [ipleak](docs/screenshots/08-ipleak-vpn-on.png) |
| DNS leak | Resolvers are in Sydney, none from my home ISP | [dnsleaktest](docs/screenshots/13-dns-leak-test.png) |
| DNS filtering | Tracker domains blocked in the AdGuard query log | [query log](docs/screenshots/14-adguard-query-log.png) |
| Reboot | WireGuard and AdGuard running after a restart | [reboot](docs/screenshots/09-reboot-test.png) |
| Hardening (Lynis) | Index rose from 58 to 68 | [before](docs/screenshots/02-lynis-before.png), [after](docs/screenshots/15-lynis-after.png) |
| Speed | With VPN: 25.17 Mbps down, 73.18 up. Without VPN: 44.71 down, 68.75 up | [with VPN](docs/screenshots/16-speedtest-vpn-on.png), [without VPN](docs/screenshots/17-speedtest-vpn-off.png) |
| Secrets in Git | gitleaks found no leaks in 9 commits | (terminal output) |

**Known limitation (failed test):** the Windows WireGuard kill switch was enabled, but when the tunnel process was stopped during testing, traffic fell back to my normal connection. The kill switch did not prevent that leak in this test.

## What I'd do next

- Repeat the kill-switch test on a Linux client, where I can control failure behaviour more precisely.
- Check the phone's DNS setting and add a screenshot.
- Rotate the laptop WireGuard key, the Vault password and the Discord webhook, since some of these were shared during the build.
- Run a full `terraform destroy` and rebuild to prove the setup works from scratch.
- Stretch goal: build a custom tunnel instead of using the WireGuard tool.