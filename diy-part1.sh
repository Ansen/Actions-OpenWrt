#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Uncomment a feed source
#sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# Add a feed source
#echo 'src-git helloworld https://github.com/fw876/helloworld' >>feeds.conf.default
#echo 'src-git passwall https://github.com/xiaorouji/openwrt-passwall' >>feeds.conf.default

# Fix the upstream json_overview_image_info.py make-output unpacking bug.

python3 - <<'PY'
from pathlib import Path

path = Path("scripts/json_overview_image_info.py")
if not path.exists():
    raise SystemExit(f"Patch target not found: {path}")

text = path.read_text()
old = '''    default_packages, output["arch_packages"] = run(
        [
            "make",
            "--no-print-directory",
            "-C",
            "target/linux/",
            "val.DEFAULT_PACKAGES",
            "val.ARCH_PACKAGES",
        ],
        stdout=PIPE,
        stderr=PIPE,
        check=True,
        env=environ.copy().update({"TOPDIR": Path().cwd()}),
        universal_newlines=True,
    ).stdout.splitlines()
'''
new = '''    build_env = environ.copy()
    build_env["TOPDIR"] = str(Path().cwd())

    def make_value(name):
        return run(
            [
                "make",
                "--no-print-directory",
                "-C",
                "target/linux/",
                name,
            ],
            stdout=PIPE,
            stderr=PIPE,
            check=True,
            env=build_env,
            universal_newlines=True,
        ).stdout.strip()

    default_packages = make_value("val.DEFAULT_PACKAGES")
    output["arch_packages"] = make_value("val.ARCH_PACKAGES")
'''

if old in text:
    path.write_text(text.replace(old, new))
elif 'def make_value(name):' not in text:
    raise SystemExit("The expected json_overview_image_info.py block was not found")
PY
