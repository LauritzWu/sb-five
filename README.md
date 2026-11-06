# sb 五协议 VPS 脚本

适用于全新的 Ubuntu 24.04 或 Debian 12 VPS，支持 amd64 和 arm64。服务端使用 sing-box 1.14.4。准备一个独立子域名。IPv4 模式需要 A 记录，IPv6 模式需要 AAAA 记录，双栈模式需要两者。记录指向这台 VPS，使用 Cloudflare DNS 时选择「仅 DNS」。只生成 IPv4 节点时，子域名应仅保留 A 记录。

## 从 GitHub 一行安装

把下面整行粘贴到 VPS 的 Bash 终端。VPS 需要有 `curl`，入口会按需安装 Python 3。

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/LauritzWu/sb-five/main/install.sh)
```

安装入口会下载指定版本的主脚本并打开交互菜单。安装后输入 `sudo sb` 即可重新打开菜单。

## 手动安装与配置

1. 将同目录的 `sb` 文件上传到 VPS，例如上传到登录用户的目录。首次运行需要 Python 3。如果系统没有它，先运行 `sudo apt-get update && sudo apt-get install -y python3`。
2. 在服务器上运行 `sudo python3 ./sb`。输入子域名并选择 IPv4、IPv6 或双栈，再选「全部五个」和各协议端口。保持 TCP 80、443、18443 在首次运行前空闲。
3. REALITY 选择「本脚本创建的同机 HTTPS 网站」。它会在本机环回地址的 TCP 18443 上提供 HTTPS，公网 TCP 443 的 REALITY 入口会将普通 HTTPS 请求转交给它。网页内容可在安装后编辑 `/var/www/sb-five/index.html`。
4. 证书选择 ACME 自动签发或导入已有的受信任证书。选择 ACME 后，可填写自己的邮箱、可收信的邮箱别名，或选择不登记邮箱。ACME HTTP 验证和后续续期需要公网 TCP 80 可达。导入需要完整证书链和对应的私钥，证书必须覆盖所选子域名。
5. 安装完成后，终端会为每个所选地址族展示五条链接和五个二维码，最后分别展示 sing-box 与 Mihomo 的 HTTPS 聚合订阅。节点使用选中的公网 IP 连接，TLS SNI 和证书仍使用域名。

脚本通过系统包管理器安装 nginx、Certbot、qrencode、OpenSSL 和 nftables。首次安装要求全新 VPS。保留原来的 SSH 连接和云控制台入口。

## 默认端口

| 端口 | 用途 |
|---|---|
| TCP 80 | ACME 验证与 HTTPS 跳转 |
| TCP 443 | REALITY，以及普通 HTTPS 网站与订阅 |
| TCP 8444 | VMess WebSocket TLS |
| UDP 443 | Hysteria 2 |
| UDP 10443 | TUIC v5 |
| TCP 9443 | AnyTLS |
| TCP 18443 | 同机 HTTPS 后端，仅本机监听 |

公网端口需要在云防火墙以及已有的系统防火墙中放行。手填或随机分配后，以实际显示的端口为准。Hysteria 2 端口跳跃从菜单启用，还需放行所选 UDP 范围和 Hysteria 2 主端口。脚本用独立的 nftables 表把该范围重定向到主端口，开机时恢复规则。

## 日常操作

运行 `sudo sb`。可以增删协议、修改端口、调整 REALITY 目标、更换证书、打开或关闭中国大陆目的地规则、重新显示节点与二维码、查看状态和日志，以及回滚到上一份配置。通过第 10 项切换节点生成模式。已有安装可运行新版入口或上传新版后执行 `sudo python3 ./sb`，原配置和节点凭据会保留。原默认订阅地址也保留，双栈下默认订阅优先提供 IPv4 节点，分地址族的订阅单独列出。

五种协议都从 VPS 的 IPv4 出站，因此 VPS 仍需要 IPv4 出网能力。选择 IPv6 生成模式会开启双栈监听，并只导出 IPv6 节点。需要仅允许 IPv6 入站时，可在云防火墙限制代理端口的 IPv4 访问。中国大陆规则按规则集匹配目标域名与地址。国内应用走直连仍需在客户端配置。若把 REALITY 改成手填后端，给 VLESS 选一个非 443 端口，TCP 443 会由脚本的 HTTPS 网站提供订阅。

终端二维码是单节点二维码，扫描需要支持相应协议的客户端。聚合地址带随机访问令牌，拿到它的人可以读取全部节点凭据。

## 验收

在实际使用的网络打开子域名确认 HTTPS 正常，再分别连接五个节点并确认出口 IPv4。启用端口跳跃后，让 Hysteria 2 持续传输超过一次跳跃间隔，确认连接可用。ACME 公网签发、云防火墙和 Linux 端口重定向需要在目标 VPS 上验收。
