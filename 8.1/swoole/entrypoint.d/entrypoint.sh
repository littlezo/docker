#!/usr/bin bash

set -e

export USER=$(/usr/bin/whoami)
export GROUP=$(/usr/bin/groups)

/usr/bin/chown -R ${USER}:${GROUP} /app-src

echo
echo "目录权限设置成功..."
echo

if /usr/bin/find "/entrypoint.d/" -mindepth 1 -print -quit 2>/dev/null | /bin/grep -q .; then
    echo "$0: 在/entrypoint.d/中查找shell脚本"
    for f in $(/usr/bin/find /entrypoint.d/ -type f -name "*.sh"); do
        echo "$0: 执行脚本 $f"
        ."$f"
    done
    for f in $(/usr/bin/find /entrypoint.d/ -type f -not -name "*.sh" -not -name "*.json" -not -name "*.pem"); do
        echo "$0: 忽略 $f"
    done

else
    echo "$0: /entrypoint.d/为空，跳过初始配置。..."
fi
exec "$@"
