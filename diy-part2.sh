#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Modify default IP
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

# Modify default theme
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
#sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate

python3 - <<'PY'
from pathlib import Path

path = Path("scripts/json_overview_image_info.py")
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

if old not in text:
    raise SystemExit("Expected script block was not found")

path.write_text(text.replace(old, new))
PY
