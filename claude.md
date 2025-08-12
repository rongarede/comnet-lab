你现在扮演“稳健的 DevSecOps 终端助手”。 请严格按下面步骤在**当前 Git 仓库根目录**执行，不要擅自改路径或文件名。任何一步失败要立刻停止并输出错误。

# 目标（DOD）：
# - 生成 tools/slither-report.json
# - 生成 tools/slither-report.sarif
# - 生成 reports/W1D2-slither.md（按 High/Medium/Low/Informational 分类，并预留误报说明区）
# - 过滤目录：lib | node_modules | test | mocks

----BEGIN BASH----
set -euo pipefail

# 0) 确认在 Git 仓库根目录
git rev-parse --show-toplevel >/dev/null

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"
mkdir -p tools reports

echo "[INFO] Repo root: $ROOT"

# 1) 安装/确认 Slither（优先 pipx，回退 pip）
if ! command -v slither >/dev/null 2>&1; then
  echo "[INFO] Installing slither..."
  if command -v pipx >/dev/null 2>&1; then
    pipx install slither-analyzer || true
  fi
  if ! command -v slither >/dev/null 2>&1; then
    python3 -m pip install --user --upgrade pip wheel
    python3 -m pip install --user slither-analyzer crytic-compile
    export PATH="$HOME/.local/bin:$PATH"
  fi
fi

# 2) 记录版本信息（便于复现）
{
  echo "slither: $(slither --version 2>&1 || echo N/A)"
  echo "python : $(python3 --version 2>&1 || echo N/A)"
  echo "solc   : $(solc --version 2>&1 | head -n1 || echo N/A)"
  echo "forge  : $(forge --version 2>&1 | head -n1 || echo N/A)"
} | tee tools/slither-version.txt

# 3) 运行 Slither（强制用 Foundry 编译，过滤依赖路径，输出 JSON+SARIF）
# 说明：
# --compile-force-framework foundry  强制使用 Foundry 工具链（读取 foundry.toml / remappings）
# --filter-paths "A|B|C"             以正则过滤文件路径
# --exclude-optimization             去掉纯优化类提示（降低噪音；如需完整请移除此项）
slither . \
  --compile-force-framework foundry \
  --filter-paths "(^|/)(lib|node_modules|test|mocks)(/|$)" \
  --json tools/slither-report.json \
  --sarif tools/slither-report.sarif \
  --exclude-optimization

# 4) 用 Python 从 JSON 生成 Markdown 报告骨架（按严重性分组）
python3 - "$ROOT/tools/slither-report.json" "$ROOT/reports/W1D2-slither.md" <<'PY'
import json, sys, pathlib

src = pathlib.Path(sys.argv[1])
dst = pathlib.Path(sys.argv[2])
data = json.loads(src.read_text())

detectors = data.get("results", {}).get("detectors", [])
buckets = {"High": [], "Medium": [], "Low": [], "Informational": []}

for d in detectors:
    impact = d.get("impact", "Informational")
    if impact not in buckets: impact = "Informational"
    buckets[impact].append(d)

def fmt_item(d):
    check = d.get("check","unknown")
    desc  = (d.get("description","") or "").strip().replace("\n"," ")
    elems = d.get("elements") or []
    file, line = "N/A", ""
    if elems:
        sm = elems[0].get("source_mapping") or {}
        file = sm.get("filename_relative") or sm.get("filename_absolute") or "N/A"
        lines = sm.get("lines") or []
        line = f":{lines[0]}" if lines else ""
    return f"- **{check}** — {desc}  \n  `@ {file}{line}`"

md = []
md.append("# W1D2 — Slither Report")
md.append("")
md.append("## Summary")
for k in ["High","Medium","Low","Informational"]:
    md.append(f"- {k}: {len(buckets[k])} findings")
md.append("")
for k in ["High","Medium","Low","Informational"]:
    md.append(f"## {k}")
    if buckets[k]:
        md.extend(fmt_item(d) for d in buckets[k])
    else:
        md.append("- None")
    md.append("")

md.append("## False Positives (Justifications)")
md.append("- 在此逐条列出认为是误报/可忽略项的理由（模式匹配误伤、接口桩、测试代码、不可达路径等）。")
md.append("")
dst.write_text("\n".join(md), encoding="utf-8")
print(f"[OK] Wrote {dst}")
PY

# 5) 列出产物
ls -lah tools/slither-report.json tools/slither-report.sarif reports/W1D2-slither.md
----END BASH----
