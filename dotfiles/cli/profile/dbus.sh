if [ ! -r '/var/lib/dbus/machine-id' ]; then return; fi
read -r DBUS_MACHINE_ID < '/var/lib/dbus/machine-id'

if [ -z "${HOME-}" -o -z "${DISPLAY-}" ]; then return; fi
DBUS_SESSION_ENV="$HOME/.dbus/session-bus/$DBUS_MACHINE_ID-${DISPLAY#:}"

. "$DBUS_SESSION_ENV"
export \
  DBUS_MACHINE_ID \
  DBUS_SESSION_ENV \
  DBUS_SESSION_BUS_ADDRESS \
  DBUS_SESSION_BUS_PID \
  DBUS_SESSION_BUS_WINDOWID
