"""
Single-stream TCP bandwidth test (like one ZeroMQ connection), no iperf3 needed.

  python tools/net_bench.py server --bind 10.0.0.11 --port 5099      # on the receiver
  python tools/net_bench.py client --connect 10.0.0.11 --port 5099 --seconds 5
      -> prints "GBPS <receiver-measured Gb/s>"
"""
import argparse
import socket
import time

CHUNK = 4 * 1024 * 1024


def server(bind, port, timeout):
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        s.bind((bind, port))
        s.listen(1)
        s.settimeout(timeout)
        conn, _ = s.accept()
        with conn:
            buf = bytearray(CHUNK)
            total, t0 = 0, None
            while True:
                n = conn.recv_into(buf)
                if n == 0:
                    break
                if t0 is None:
                    t0 = time.perf_counter()
                total += n
            elapsed = time.perf_counter() - (t0 or time.perf_counter())
            conn.sendall(f"{total} {elapsed}".encode())


def client(connect, port, seconds, retry):
    deadline = time.time() + retry
    while True:   # the server may still be starting
        try:
            s = socket.create_connection((connect, port), timeout=10)
            break
        except OSError:
            if time.time() > deadline:
                raise
            time.sleep(0.3)
    with s:
        data = bytes(CHUNK)
        end = time.perf_counter() + seconds
        while time.perf_counter() < end:
            s.sendall(data)
        s.shutdown(socket.SHUT_WR)
        reply = b""
        while True:
            r = s.recv(256)
            if not r:
                break
            reply += r
    total, elapsed = reply.decode().split()
    print(f"GBPS {int(total) * 8 / float(elapsed) / 1e9:.3f}")


def main():
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest="role", required=True)
    s = sub.add_parser("server")
    s.add_argument("--bind", required=True)
    s.add_argument("--port", type=int, default=5099)
    s.add_argument("--timeout", type=float, default=60)
    c = sub.add_parser("client")
    c.add_argument("--connect", required=True)
    c.add_argument("--port", type=int, default=5099)
    c.add_argument("--seconds", type=float, default=5)
    c.add_argument("--retry", type=float, default=20)
    a = ap.parse_args()
    if a.role == "server":
        server(a.bind, a.port, a.timeout)
    else:
        client(a.connect, a.port, a.seconds, a.retry)


if __name__ == "__main__":
    main()
