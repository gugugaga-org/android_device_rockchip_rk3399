#!/system/bin/sh
set -o pipefail

echo TPM312_TOMBSTONE_WATCH_BEGIN
waited=0
crashing=
process_name=

while [ "$waited" -lt 120 ]; do
    crashing=$(/system/bin/getprop sys.init.updatable_crashing)
    process_name=$(/system/bin/getprop sys.init.updatable_crashing_process_name)

    if [ "$crashing" = "1" ] && [ "$process_name" = "zygote" ]; then
        break
    fi

    if [ "$(/system/bin/getprop sys.boot_completed)" = "1" ]; then
        echo TPM312_BOOT_COMPLETED_NO_CRASH_CAPTURE
        echo TPM312_TOMBSTONE_WATCH_END
        exit 0
    fi

    /system/bin/sleep 1
    waited=$((waited + 1))
done

if [ "$crashing" != "1" ] || [ "$process_name" != "zygote" ]; then
    echo TPM312_NO_ZYGOTE_UPDATABLE_CRASH
    echo TPM312_TOMBSTONE_WATCH_END
    exit 0
fi

echo TPM312_ZYGOTE_UPDATABLE_CRASH_CAPTURE_BEGIN
/system/bin/sleep 1

for tombstone in $(/system/bin/ls -t /data/tombstones/tombstone_[0-9][0-9] 2>/dev/null); do
    if ! /system/bin/grep -Fq '>>> system_server <<<' "$tombstone"; then
        continue
    fi

    echo "TPM312_SYSTEM_SERVER_TOMBSTONE_BEGIN $tombstone"
    if ! /system/bin/dd if="$tombstone" bs=512 count=256 status=none; then
        echo TPM312_TOMBSTONE_DUMP_FAILED
        exit 1
    fi
    echo TPM312_SYSTEM_SERVER_TOMBSTONE_END

    echo TPM312_LOGCAT_BEGIN
    if ! /system/bin/logcat -b all -d -v threadtime -t 512 | \
            /system/bin/tail -c 131072 | /system/bin/dd bs=512 status=none; then
        echo TPM312_LOGCAT_DUMP_FAILED
        exit 1
    fi
    echo TPM312_LOGCAT_END
    echo TPM312_TOMBSTONE_CAPTURE_END
    exit 0
done

echo TPM312_NO_SYSTEM_SERVER_TEXT_TOMBSTONE
echo TPM312_TOMBSTONE_WATCH_END
