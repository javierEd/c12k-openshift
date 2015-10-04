#! /bin/sh
### BEGIN INIT INFO
# Provides:          eventos
# Required-Start:    $local_fs $remote_fs $syslog apache2 mongodb
# Required-Stop:     $local_fs $remote_fs $syslog apache2 mongodb
# Should-Start:      
# Should-Stop:       
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: eventos
# Description:       eventos
### END INIT INFO

. /lib/lsb/init-functions

. /etc/default/eventos

if [ $USER != 'root' ]
then
    echo "Debes ejecutar este script como root o sudo."
    exit 1
fi

if [ $ENABLE != true ]
then
    echo "Debes activar eventos en el archivo ubicado en /etc/default/eventos."
    exit 1
fi

start() {
  log_begin_msg "Iniciando eventos"
  if [ ! -e $DIRECTORIO/tmp/pids/daemon.pid ]
  then
    start-stop-daemon -c $USUARIO -b -m -p $DIRECTORIO/tmp/pids/daemon.pid --start --exec $DIRECTORIO/bin/rails -- server $APPSERVER -e $ENTORNO -b $BINDING -p $PUERTO
  fi
  log_end_msg 0
}

stop() {
  log_begin_msg "Deteniendo eventos"
  if [ -e $DIRECTORIO/tmp/pids/daemon.pid ]
  then
    start-stop-daemon -p $DIRECTORIO/tmp/pids/daemon.pid --stop --remove-pidfile
  fi
  log_end_msg 0
}

restart() {
  log_begin_msg "Reiniciando eventos"
  stop
  start
  log_end_msg 0
}

status() {
  start-stop-daemon -p $DIRECTORIO/tmp/pids/daemon.pid --status
}

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    restart
    ;;
  status)
    status
    ;;
  *)
    echo "Uso de: $0 {start|stop|restart|status}"
    exit 1
esac