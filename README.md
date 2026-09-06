# CFData-Web Docker 适配版

> 本项目基于 [PoemMisty/CFData-WEB](https://github.com/PoemMisty/CFData-WEB) 官方项目进行适配。
>
> **本项目仅增加 Docker 镜像打包与自动发布能力，不修改 CFData-WEB 的核心功能。**
>
> 主要解决原项目在群晖 NAS、软路由、Linux 服务器等 Docker 环境中的部署问题：无需手动下载对应架构的二进制文件，直接拉取 Docker 镜像即可运行。

## 本项目解决的需求

原作者已经通过 Release 提供不同平台的正式编译版本，但在 NAS、软路由等设备上直接使用二进制程序时，仍需要自行判断 CPU 架构、下载对应文件、上传到设备、赋予执行权限并配置长期运行。

本项目只针对这一部署环节进行适配：

- **不改变原作者的扫描、测速、筛选、导出等功能。**
- **直接使用原作者 Release 中已经编译好的 Linux 程序。**
- 通过 GitHub Actions 自动检测原作者最新 Release。
- 自动下载官方 `linux/amd64` 和 `linux/arm64` 程序。
- 自动分别打包成对应架构的 Docker 镜像。
- 自动创建 Multi-Arch 镜像。
- 使用 `latest` 时，Docker 会根据设备 CPU 架构自动选择正确的镜像。
- 原作者发布新版本后，可由定时任务自动发现新版本并重新打包、更新 `latest`。

### 与原作者项目的关系

```text
PoemMisty/CFData-WEB
        │
        │ 官方 Release
        ▼
官方 Linux 二进制
        │
        ├── cfdata-linux-amd64
        └── cfdata-linux-arm64
        │
        │ 本项目仅增加 Docker 封装
        ▼
GitHub Actions 自动构建
        │
        ▼
GHCR Multi-Arch 镜像
        │
        ├── linux/amd64
        └── linux/arm64
        │
        ▼
Docker 自动选择架构
```

### 为什么不重新编译？

本项目的目标是**尽量保持 Docker 版本与原作者 Release 版本一致**。

因此 Docker 镜像不是从源码重新编译 CFData-WEB，而是直接封装原作者 Release 中已经编译完成的对应 Linux 二进制：

```text
原作者正式 Release
        ↓
下载对应 Linux 二进制
        ↓
Docker 镜像封装
```

而不是：

```text
源代码
  ↓
本项目重新编译
  ↓
Docker 镜像
```

这样可以减少自行编译环境、Go 版本及依赖差异造成的问题，也使 Docker 镜像与原作者正式 Release 的对应关系更加清晰。

---

## Docker 镜像

### 镜像地址

```text
ghcr.io/myi101/cfdata-web:latest
```

如果使用自己的 Fork，请将 `myi101` 替换为自己的 GitHub 用户名。

### 默认端口

```text
13335
```

### 当前支持的 Docker 架构

```text
linux/amd64
linux/arm64
```

| 设备 | Docker 架构 | 自动使用 |
|---|---|---|
| Intel / AMD PC、服务器、x86 NAS | `linux/amd64` | `cfdata-linux-amd64` |
| 群晖 DS218 等 ARM64 设备 | `linux/arm64` | `cfdata-linux-arm64` |

> 原作者 Release 中的 Windows、macOS、Android 等程序属于其他平台，不能作为 Linux Docker 容器的运行程序，因此不会放入 Linux Multi-Arch 镜像。

### 自动更新流程

```text
定时检查原作者最新 Release
              ↓
        是否发现新版本？
          ↙           ↘
        否             是
        ↓              ↓
      跳过       下载官方 AMD64
                       ↓
                构建 amd64 镜像
                       ↓
                下载官方 ARM64
                       ↓
                构建 arm64 镜像
                       ↓
                创建 Multi-Arch
                       ↓
              更新版本号 + latest
```

如果当前版本已经存在并且同时包含 `amd64`、`arm64`，则不会重复构建。

---

## Docker 部署

### Docker CLI

```bash
docker run -d \
  --name cfdata-web \
  --restart unless-stopped \
  -p 13335:13335 \
  ghcr.io/myi101/cfdata-web:latest
```

### Docker Compose

```yaml
services:
  cfdata-web:
    image: ghcr.io/myi101/cfdata-web:latest
    container_name: cfdata-web
    restart: unless-stopped
    ports:
      - "13335:13335"
```

启动：

```bash
docker compose up -d
```

### 群晖 Container Manager

1. 打开 **Container Manager → 项目 → 新增**。
2. 创建或粘贴上面的 `docker-compose.yml`。
3. 使用镜像 `ghcr.io/myi101/cfdata-web:latest`。
4. 完成部署。

对于 DS218 这类 ARM64 群晖，无需手动选择 ARM64 镜像；Docker 会从 Multi-Arch 镜像中自动选择 `linux/arm64`。

### OpenWrt / 软路由

创建容器时：

```text
容器名称：cfdata-web
镜像：ghcr.io/myi101/cfdata-web:latest
端口：13335 → 13335
重启策略：Always / Unless Stopped
```

---

## 访问 Web 页面

容器启动成功后：

```text
http://<设备IP>:13335
```

例如：

```text
http://192.168.2.200:13335
```

---

## 功能

- 官方优选：扫描 Cloudflare IPv4/IPv6，按数据中心继续详细延迟测试。
- 非标优选：上传本地 txt/csv 或填写网络 URL，测试自定义 IP/域名与端口。
- 测速：支持单点测速、批量测速、非标并发测速和测速阈值筛选。
- 导出：支持 CSV/TXT、自定义字段、IP 类型筛选、合格结果筛选。
- 上传：支持将导出结果上传到 GitHub。
- APK：支持 Android WebView 壳运行内置后端。


## 二进制部署指南（请到原著作者项目下载）
从 [Releases](https://github.com/PoemMisty/CFData-WEB/releases/latest) 下载对应平台程序后运行。

默认启动 Web 模式：

```text
服务启动于 http://localhost:13335
当前测速网址: auto
```

浏览器打开终端中的地址即可使用。

CLI 模式：

```bash
./cfdata-linux-amd64 -cli
```

首次使用 CLI 配置文件时会生成模板并退出，编辑配置后重新运行即可。

简单示例：

```bash
# 默认 CLI：按命令行 > 配置文件 > 环境变量 > 默认值自动运行
./cfdata-linux-amd64 -cli

# 官方模式：扫描 IPv4，测试 443 端口，测速地址自动选择
./cfdata-linux-amd64 -cli -mode official -offiptype 4 -offport 443 -offurl auto

# 非标模式：读取本地文件，开启 TLS 和 5 个测速线程
./cfdata-linux-amd64 -cli -mode nsb -nsbfile ip.txt -nsbtls=true -nsbspeedtest 5 -offurl auto
```

## Web 使用

界面顶部「扫描方式」选择器支持 TCPing（默认）和 HTTPing。不同扫描模式的延迟数据不可互相比较，仅同模式内的对比才有意义。

### 扫描方式说明

- **TCPing**：测量 TCP 握手延迟，基准值。
- **HTTPing**：测量 HTTP TTFB（Time To First Byte），延迟比 TCPing 高属正常现象。延迟阈值和渲染颜色已按倍率自动缩放，倍率仅为延迟等级参考值，非精确换算：
  - 无 TLS（HTTP 端口）：×1.3
  - 有 TLS（HTTPS 端口）：×4.0

### 官方优选

1. 选择 IPv4 或 IPv6。
2. 设置测试端口、扫描并发、延迟阈值。
3. 点击“开始扫描与测试”。
4. 扫描完成后选择数据中心继续详细测试。
5. 在详细测试结果中可单点测速或批量测速。

### 非标优选

1. 切换到“非标优选”。
2. 上传 txt/csv，或填写网络 URL（二选一）。
3. 设置备用端口、并发、TLS、结果上限、测速线程、测速阈值等参数。
4. 点击“开始扫描与测试”。
5. 在结果表格查看、筛选、导出或上传。

非标输入推荐格式：

```text
1.2.3.4 443
5.6.7.8 8443
2606:4700::1111 443
1.1.1.1
```

未提供端口时会使用备用端口；备用端口默认随 TLS 模式自动选择，关闭 TLS 为 80，开启 TLS 为 443。

## 测速地址

默认测速地址为 `auto`，表示由后端自动选择内置测速源。

Web 下拉项：

- 自动选择
- Cloudflare
- CM提供
- 移动专属
- 手动输入

CLI 可通过 `-offurl`/`-nsburl` 指定：

```bash
./cfdata-linux-amd64 -cli -offurl auto
./cfdata-linux-amd64 -cli -offurl speed.cloudflare.com/__down?bytes=99999999
./cfdata-linux-amd64 -cli -offurl https://example.com/file.bin
```

说明：测速只读取响应字节流计算速度，不会把测速文件保存到本地。

## 常用参数

```text
-cli              启用 CLI 模式
-mode             official 或 nsb
-scanmode         扫描方式：tcping（默认，TCP 握手延迟）或 httping（HTTP TTFB，延迟比 tcping 高属正常，不同模式数据不可对比）
-offthreads       官方扫描并发数
-nsbthreads       非标扫描并发数
-offport          官方测试/测速端口
-offdelay         官方延迟阈值，单位毫秒
-nsbdelay         非标延迟阈值，单位毫秒
-offurl           官方测速下载地址，默认 auto
-nsburl           非标测速下载地址，默认 auto
-dns              自定义 DNS 服务器
-debug            调试日志等级：false、error、all
-offout           官方输出文件名
-nsbout           非标输出文件名
```

非标常用参数：

```text
-nsbfile          本地输入文件
-nsbsourceurl     网络输入 URL
-nsbfallbackport  非标输入缺省端口；不传时随 TLS 自动使用 443/80
-nsbtls           非标是否启用 TLS
-nsbspeedtest     非标测速线程数，0 表示不测速。多 IP 并发影响实际速度，需要准确应设为 1
-nsbresultlimit   非标延迟测试结果上限
-nsbspeedmin      非标测速合格阈值，单位 MB/s
-nsbspeedlimit    非标测速合格结果上限
```

完整参数可运行：

```bash
./cfdata-linux-amd64 -h
```

## 本地缓存

Web 右上角设置菜单提供“恢复全部默认配置”，会清理本地缓存文件，例如 `ips-v4.txt`、`ips-v6.txt`、`locations.json`、ASN 数据库等。任务运行中不会直接清理，避免影响测试。

## 免责声明

本程序仅限用于学习与研究目的。请在下载后24小时内自行删除。使用本程序时，应自行遵守所在地区的法律法规。作者不对使用本程序所产生的任何后果承担责任。下载或使用本程序即视为已阅读、理解并同意上述声明。

## 致谢

- TG 频道：[CF中转IP](https://t.me/CF_NAT)
- GitHub：[Kwisma/iptest](https://github.com/Kwisma/iptest)

## License

Copyright (C) 2026 PoemMisty

This project is licensed under the GNU General Public License v3.0 or later.
See the LICENSE file for details.
