# Panduan Lengkap WSL2 & Antigravity IDE Multi-Task Integration

Dokumen ini berisi analisis mendalam, arsitektur, pemetaan PID, serta petunjuk konfigurasi untuk menjalankan **Antigravity IDE** dalam mode **Multi-Tasking** pada lingkungan **WSL2 (Windows Subsystem for Linux 2)**.

---

## 1. Arsitektur WSL2 (Windows Subsystem for Linux 2)

WSL2 menggunakan teknologi **Hyper-V Utility VM** yang sangat ringan dengan kernel Linux asli yang dipelihara oleh Microsoft.

### Komponen Utamanya:
- **vmmemWSL (MicroVM Engine)**: Proses di sisi Windows host yang memegang resource RAM dan CPU virtual untuk Linux kernel.
- **Plan 9 File System Protocol (`plan9`)**: Driver VFS yang menjembatani sistem berkas Windows (NTFS) dengan sistem berkas Linux (EXT4). Akses drive Windows (`G:\My Drive\...`) dieksekusi melalui Plan 9 network socket.
- **Mirrored Networking Stack**: WSL2 berbagi IP address dan network stack secara langsung dengan Windows host, menghilangkan isu ketersambungan `localhost` atau VPN.
- **Systemd Integration**: WSL2 mendukung `systemd` sebagai PID 1 untuk mengelola service background seperti Docker (`dockerd`), database (MariaDB/PostgreSQL), dan cron jobs.

---

## 2. Ekosistem Antigravity IDE

Antigravity IDE adalah platform AI Coding Agentic tingkat lanjut yang memiliki arsitektur terdistribusi:

- **Agent Orchestrator**: Mengatur subagent independen (`invoke_subagent`), eksekusi perintah background (`run_command`), dan penjadwalan berkala (`schedule`).
- **Workspace Isolation Mode**:
  - `inherit`: Berbagi ruang kerja langsung dengan parent context.
  - `branch`: Membuat git branch terisolasi untuk eksekusi tugas paralel tanpa risiko konflik kode utama.
  - `share`: Berbagi repositori fisik menggunakan mekanisme clone/worktree tanpa duplikasi penyimpanan.
- **Multi-Agent Message Bus**: Sistem antrian pesan real-time (reactive wakeup) yang menerima pemberitahuan dari background task, subagent, dan event scheduler tanpa perlunya polling manual.

---

## 3. Perilaku Antigravity IDE di WSL2

Saat Antigravity IDE berjalan di Windows dan berinteraksi dengan proyek yang terletak di WSL2 atau Drive Windows:

1. **Host-to-Guest Interop**:
   - Antigravity berjalan sebagai proses Electron di Windows (`Antigravity.exe`).
   - Eksekusi perintah Linux dilakukan via perantara `wslhost.exe` yang meneruskan instruksi ke `/init` atau `/bin/bash` di dalam WSL2.
2. **Path Translation & Plan 9 VFS**:
   - Drive Windows seperti `G:\My Drive\` dipetakan ke Linux via Plan 9. Jika Plan 9 mengalami bottleneck saat multi-tasking (banyak agent membaca/menulis file sekaligus), proses bisa terhambat.
   - Solusi: Pengaturan `automount` metadata pada `/etc/wsl.conf` dan penyesuaian alokasi memory `.wslconfig`.

---

## 4. Analisis & Pemetaan PID (Process ID)

### A. Windows Host Processes (Host Environment)
| Nama Proses | Tipikal PID | Peran & Fungsi |
| :--- | :--- | :--- |
| `Antigravity.exe` | `7488, 10252, 14576, 24180, 28652, 30676` | Main Electron UI, Extension Host, Subagent Orchestrator, & Storage Engine |
| `wslhost.exe` | `760, 25080, 27936` | Jembatan komunikasi gRPC / AF_UNIX antara Antigravity Host dan WSL2 |
| `vmmemWSL` | `15696` | Process Container VM Hyper-V yang mengalokasikan RAM/CPU Linux |
| `wslservice.exe` | `5412` | Service Windows latar belakang untuk manajemen distribusi WSL |

### B. WSL2 Linux Guest Processes (Guest Environment)
| PID Linux | Nama Proses | Peran & Fungsi |
| :--- | :--- | :--- |
| `1` | `/sbin/init` | `systemd` master process / init daemon |
| `2` | `/init` | Internal WSL bootstrap process |
| `6` | `plan9` | Server socket VFS untuk akses file lintas Windows-Linux |
| `177` | `/usr/libexec/wsl-pro-service` | Service integrasi WSL Ubuntu Pro |
| `264` | `/usr/bin/dockerd` | Docker Engine Daemon |
| `715` | `node server.js` | Web App backend node server |
| `724` | `mariadbd` | Database MariaDB server |
| `974` | `/usr/lib/systemd/systemd --user` | User Session Manager untuk user `me` |
| `1014` | `-bash` | Interactive shell session |

---

## 5. Konfigurasi Multi-Tasking Antigravity IDE di WSL2

Untuk memastikan Antigravity IDE dapat memproses **Multi-Tasking** dan **Multi-Subagent** secara optimal tanpa hang atau OOM (Out Of Memory):

### File Konfigurasi:
1. **`.wslconfig`** (Di-copy ke `%USERPROFILE%\.wslconfig`):
   - Memory RAM: `20GB` (dari 28GB total)
   - CPU Processors: `12` Cores
   - Swap Space: `8GB`
   - Networking: `mirrored`
   - Memory Reclaim: `gradual`
2. **`wsl.conf`** (Di-copy ke `/etc/wsl.conf` di WSL):
   - Systemd enabled
   - Metadata automount enabled
   - Interop enabled
3. **`antigravity-wsl-multitask.json`**: Konfigurasi batasan tugas paralel Antigravity agent.

---

## 6. Script Eksekusi & Pengujian (`setup-multitask.ps1`)

Jalankan script `setup-multitask.ps1` untuk menerapkan konfigurasi ini secara otomatis dan memverifikasi kesehatan sistem.
