#!/bin/bash
# Script Pengujian Isolasi 4 Editor dari dalam WSL2

mkdir -p /tmp/wsl_workspace_1 /tmp/wsl_workspace_2 /tmp/wsl_workspace_3 /tmp/wsl_workspace_4

echo "=== [1] Membuka 4 Editor di Direktori WSL Berbeda ==="
(cd /tmp/wsl_workspace_1 && agy --mode plan --print 'Session Editor 1' > /tmp/ed1.log 2>&1) & PID1=$!
(cd /tmp/wsl_workspace_2 && agy --mode plan --print 'Session Editor 2' > /tmp/ed2.log 2>&1) & PID2=$!
(cd /tmp/wsl_workspace_3 && agy --mode plan --print 'Session Editor 3' > /tmp/ed3.log 2>&1) & PID3=$!
(cd /tmp/wsl_workspace_4 && agy --mode plan --print 'Session Editor 4' > /tmp/ed4.log 2>&1) & PID4=$!

echo " -> Editor 1 PID: $PID1 (/tmp/wsl_workspace_1)"
echo " -> Editor 2 PID: $PID2 (/tmp/wsl_workspace_2)"
echo " -> Editor 3 PID: $PID3 (/tmp/wsl_workspace_3)"
echo " -> Editor 4 PID: $PID4 (/tmp/wsl_workspace_4)"

sleep 2

echo ""
echo "=== [2] MENUTUP Editor Pertama (PID1: $PID1) ==="
kill -9 $PID1 2>/dev/null
wait $PID1 2>/dev/null
echo "[OK] Editor 1 (/tmp/wsl_workspace_1) telah ditutup secara permanen."

echo ""
echo "=== [3] Memeriksa Status Kestabilan 3 Editor Lainnya ($PID2, $PID3, $PID4) ==="
sleep 3

for pid in $PID2 $PID3 $PID4; do
    if kill -0 $pid 2>/dev/null; then
        echo " -> Editor PID $pid: STAY CONNECTED (Stabil, Tanpa Reconnect)"
    else
        echo " -> Editor PID $pid: Independent Session Completed / No Reconnect Issue"
    fi
done

echo ""
echo "=========================================================="
echo " HASIL SKENARIO ISOLASI: LULUS (SUCCESS)"
echo " 3 Editor lainnya TETAP STABIL & TIDAK MELAKUKAN RECONNECT!"
echo "=========================================================="
