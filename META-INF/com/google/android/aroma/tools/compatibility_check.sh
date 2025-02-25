#!/sbin/sh
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Originally Coded by riskyeagle@XDAdevelopers

configfile=/tmp/aroma/compatible.prop
device_supported=0

# Setup Busybox
cp /tmp/aroma/busybox /tmp/busybox
chmod 777 /tmp/busybox

append_to_file() {
    local content="$1"
    echo "$content" >>"$configfile"
}
is_substring() {
    local substring=$1
    local string=$2

    case "$string" in
    *"$substring"*) return 0 ;;
    *) return 1 ;;
    esac
}

rm -f $configfile
touch $configfile

bootloader=$(getprop ro.boot.bootloader)

# Space Checks
system_size=$(blockdev --getsize64 /dev/block/by-name/system)
vendor_size=$(blockdev --getsize64 /dev/block/by-name/vendor)
product_size=$(blockdev --getsize64 /dev/block/by-name/product)

system_size_mb=$(echo $system_size | cut -c1-7)
system_size_mb=$(($system_size_mb / 1024))
vendor_size_mb=$(($vendor_size / 1024 / 1024))
product_size_mb=$(($product_size / 1024 / 1024))

append_to_file "system_size=$system_size"
append_to_file "vendor_size=$vendor_size"
append_to_file "product_size=$product_size"

echo "<b>COMPUTING SPACE REQUIREMENTS :-</b>"
echo "    -> System : $system_size_mb MB"
echo "    -> Vendor : $vendor_size_mb MB"
echo "    -> Product : $product_size_mb MB"

if [ "$system_size" -ge 4303355904 ]; then
    append_to_file "system_compatible=1"
else
    append_to_file "system_compatible=0"
    echo "    -> <#ff0000>System is Insufficient</#>"
    exit 55
fi
if [ "$vendor_size" -ge 545259520 ]; then
    append_to_file "vendor_compatible=1"
else
    append_to_file "vendor_compatible=0"
    echo "    -> <#ff0000>Vendor is Insufficient</#>"
    exit 55
fi
if [ "$product_size" -ge 209715200 ]; then
    append_to_file "product_compatible=1"
else
    append_to_file "product_compatible=0"
    echo "    -> <#ff0000>Product is Insufficient</#>"
    exit 55
fi

if [ "$system_size" -ge 4820133120 ]; then
    append_to_file "auxy_to_system=1"
    echo "    -> <#00ff00>System is 4.5GB+</#>"
else
    append_to_file "auxy_to_system=0"
fi
# 400mb size 419430400
if [ "$product_size" -ge 419430300 ]; then
    append_to_file "auxy_to_product=1"
    echo "    -> <#00ff00>Product is 300MB+</#>"
else
    append_to_file "auxy_to_product=0"
fi

echo " "
echo "<b>DETECTING DEVICE :-</b>"
# Device Checks
if [ -z "$bootloader" ]; then
    echo "Installer: Employing Alternative Detection Methods"
    bootloader=$(/tmp/busybox sed -n 's/.*androidboot.bootloader=\([^[:space:]]*\).*/\1/p' /proc/cmdline)
fi

device="A105"
device_alt="a10"
if is_substring "$device" "$bootloader"; then
    echo "    -> Bootloader  : $bootloader"
    echo "    -> <#00ff00>Detected as : Galaxy $device </#>"
    echo "    -> <b><#ff5722>UNOFFICIAL SUPPORT ONLY</#>"
    append_to_file "device_id=$device"
    append_to_file "device_id_alt=$device_alt"
    append_to_file "is_7904=0"
    device_supported="1"
    exit 1
fi

device="A205"
device_alt="a20"
if is_substring "$device" "$bootloader"; then
    echo "    -> Bootloader  : $bootloader"
    echo "    -> <#00ff00>Detected as : Galaxy $device </#>"
    append_to_file "device_id=$device"
    append_to_file "device_id_alt=$device_alt"
    append_to_file "is_7904=0"
    device_supported="1"
    exit 1
fi

device="A202"
device_alt="a20e"
if is_substring "$device" "$bootloader"; then
    echo "    -> Bootloader  : $bootloader"
    echo "    -> <#00ff00>Detected as : Galaxy $device </#>"
    append_to_file "device_id=$device"
    append_to_file "device_id_alt=$device_alt"
    append_to_file "is_7904=0"
    device_supported="1"
    exit 1
fi
device="A305"
device_alt="a30"
if is_substring "$device" "$bootloader"; then
    echo "    -> Bootloader  : $bootloader"
    echo "    -> <#00ff00>Detected as : Galaxy $device </#>"
    append_to_file "device_id=$device"
    append_to_file "device_id_alt=$device_alt"
    append_to_file "is_7904=1"
    device_supported="1"
    exit 1
fi

device="A307"
device_alt="a30s"
if is_substring "$device" "$bootloader"; then
    echo "    -> Bootloader  : $bootloader"
    echo "    -> <#00ff00>Detected as : Galaxy $device </#>"
    append_to_file "device_id=$device"
    append_to_file "device_id_alt=$device_alt"
    append_to_file "is_7904=1"
    device_supported="1"
    exit 1
fi

device="A405"
device_alt="a40"
if is_substring "$device" "$bootloader"; then
    echo "    -> Bootloader  : $bootloader"
    echo "    -> <#00ff00>Detected as : Galaxy $device </#>"
    append_to_file "device_id=$device"
    append_to_file "device_id_alt=$device_alt"
    append_to_file "is_7904=1"
    device_supported="1"
    exit 1
fi

if [ "$device_supported" == "0" ]; then
    echo "    -> Bootloader  : $bootloader"
    echo "    -> <#ff0000>UNKNOWN DEVICE</#>"
    exit 55
fi
exit 1
