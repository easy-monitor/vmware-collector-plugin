#!/bin/bash


PACKAGE_NAME=vmware-collector-plugin
PACKAGE_PATH=$(dirname $(dirname "$(cd `dirname $0`; pwd)"))
LOG_DIRECTORY=$PACKAGE_PATH/log
LOG_FILE=$LOG_DIRECTORY/$PACKAGE_NAME.log


if ! type getopt >/dev/null 2>&1 ; then
  message="command \"getopt\" is not found"
  echo "[ERROR] Message: $message" >& 2
  echo "$(date "+%Y-%m-%d %H:%M:%S") [ERROR] Message: $message" > $LOG_FILE
  exit 1
fi

getopt_cmd=`getopt -o h -a -l help:,config-file-path:,exporter-port: -n "start_script.sh" -- "$@"`
if [ $? -ne 0 ] ; then
    exit 1
fi
eval set -- "$getopt_cmd"


config_file_path="conf/config.yml"
exporter_port=9272

print_help() {
    echo "Usage:"
    echo "    start_script.sh [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help                 show help"
    echo "      --config-file-path     the path of config file (\"conf/config.yml\" by default)"
    echo "      --exporter-port        the listen port of exporter (9272 by default)"
}

while true
do
    case "$1" in
        -h | --help)
            print_help
            shift 1
            exit 0
            ;;
        --config-file-path)
            case "$2" in
                "")
                    shift 2  
                    ;;
                *)
                    config_file_path="$2"
                    shift 2;
                    ;;
            esac
            ;;
        --exporter-port)
            case "$2" in
                "")
                    shift 2  
                    ;;
                *)
                    exporter_port="$2"
                    shift 2;
                    ;;
            esac
            ;;
        --)
            shift
            break
            ;;
        *)
            message="argument \"$1\" is invalid"
            echo "[ERROR] Message: $message" >& 2
            echo "$(date "+%Y-%m-%d %H:%M:%S") [ERROR] Message: $message" > $LOG_FILE
            print_help
            exit 1
            ;;
    esac
done

mkdir -p $LOG_DIRECTORY

message="start exporter"
echo "[INFO] Message: $message"
echo "$(date "+%Y-%m-%d %H:%M:%S") [INFO] Message: $message" >> $LOG_FILE

cd $PACKAGE_PATH/script

if [ ! -d "src/python" ]; then
    if [ ! -f "src/python.tar.gz" ]; then
        message="missing \"src/python.tar.gz\""
        echo "[ERROR] Message: $message" >& 2
        echo "$(date "+%Y-%m-%d %H:%M:%S") [ERROR] Message: $message" > $LOG_FILE
        exit 1
    fi

    message="unzip \"src/python.tar.gz\""
    echo "[INFO] Message: $message" >& 2
    echo "$(date "+%Y-%m-%d %H:%M:%S") [INFO] Message: $message" > $LOG_FILE
    tar xzvf src/python.tar.gz -C src > /dev/null
fi

./src/python/bin/python3 ./src/python/bin/vmware_exporter -c $config_file_path -p $exporter_port 2>&1 | tee -a $LOG_FILE
