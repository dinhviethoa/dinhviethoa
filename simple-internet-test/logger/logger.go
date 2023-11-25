package logger

import (
	"fmt"
	"os"
	"smartcpe-test-tools/config"

	"github.com/julienroland/usg"
	"github.com/rs/zerolog"
)

var Logger zerolog.Logger

const (
	exitCode = 1
)

func init() {
	modeDebug := config.AppConfig.DebugMode
	if modeDebug {
		fmt.Println(usg.Get.Square, usg.Get.Square, usg.Get.Square, usg.Get.Square, "DEBUG MODE", usg.Get.Square, usg.Get.Square, usg.Get.Square, usg.Get.Square)
		Logger = zerolog.New(os.Stdout).With().Timestamp().Logger()
	} else {
		logPath := config.AppConfig.LogPath
		file, err := os.OpenFile(
			logPath, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0664)
		if err != nil {
			fmt.Println(err)
			os.Exit(exitCode)
			return
		}
		Logger = zerolog.New(file).With().Timestamp().Logger()
	}
}

type CronJobLogger struct {
}

func NewCronJobLogger() CronJobLogger {
	return CronJobLogger{}
}

func (cron *CronJobLogger) Info(msg string, keysAndValues ...interface{}){
	
	Logger.Info().Str("service", "cron logger").Msg(msg)
}

func (cron *CronJobLogger) Error(err error, msg string, keysAndValues ...interface{}){
	Logger.Err(err).Str("service", "cron logger").Msg(msg)
}