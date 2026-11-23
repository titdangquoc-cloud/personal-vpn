# Threat model

## What this protects
- Traffic from my laptop to the internet while on untrusted networks (public Wi-Fi, hotels).
- DNS queries, which are filtered by AdGuard Home on the server.

## What it does not protect
- Activity once traffic leaves the server (websites still see the server's IP).
- Anything if the server or my laptop is compromised.
- A brief leak if the WireGuard process crashes on Windows (kill switch test failed, see Test evidence).

## Assets
- Laptop and phone WireGuard private keys.
- Server SSH access (key-only, from home IP).
- The Discord webhook and Ansible Vault password.

## Threats and mitigations
| Threat | Mitigation | Evidence |
|---|---|---|
| Brute-force SSH | Key-only login, root disabled, fail2ban (3 tries, 1h ban) | 04-root-denied.png, fail2ban status in daily report |
| Port scanning | Cloud firewall + ufw, only UDP 51820 open to the internet | 10-nmap-tcp.png, 11-nmap-udp.png |
| Ads and trackers | AdGuard Home blocks them over VPN | 14-adguard-query-log.png |
| DNS leaks | DNS set to 10.8.0.1 on the client | 13-dns-leak-test.png |
| Secrets in Git | Ignored files and Ansible Vault | gitleaks scan result |
| Server reboot breaks VPN | systemd ordering and enabled services | 09-reboot-test.png |

## Known gaps
- Kill switch failed in the Windows crash test (traffic leaked).
- Phone DNS not verified.
- Keys have not been rotated since the screenshots and zips were shared.