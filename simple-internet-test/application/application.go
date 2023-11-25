package application

import (
	"fmt"
	"os"
	"smartcpe-test-tools/config"
	"smartcpe-test-tools/logger"
	"smartcpe-test-tools/services/ping"
	"smartcpe-test-tools/services/speedtest"

	"4d63.com/tz"
	"github.com/robfig/cron/v3"
)

func Start() {
	cronLogger := logger.NewCronJobLogger()
	durationPing := "@every " + config.AppConfig.PingCronjobTime
	durationSpeedtest := "@every " + config.AppConfig.SpeedtestCronjobTime
	loc, _ := tz.LoadLocation("Asia/Ho_Chi_Minh")

	cronJob := cron.New(cron.WithLocation(loc),
		cron.WithChain(
			cron.Recover(&cronLogger),
		))
	_, err := cronJob.AddFunc(durationPing, ping.PingGoogleA)
	if err != nil {
		os.Exit(1)
	}

	_, err = cronJob.AddFunc(durationPing, ping.PingGoogleB)
	if err != nil {
		os.Exit(1)
	}

	_, err = cronJob.AddFunc(durationPing, ping.PingCloudflare)
	if err != nil {
		os.Exit(1)
	}

	_, err = cronJob.AddFunc(durationPing, ping.PingFacebook)
	if err != nil {
		os.Exit(1)
	}

	_, err = cronJob.AddFunc(durationPing, ping.PingYoutube)
	if err != nil {
		os.Exit(1)
	}

	_, err = cronJob.AddFunc(durationPing, ping.PingTiktok)
	if err != nil {
		os.Exit(1)
	}

	_, err = cronJob.AddFunc(durationPing, ping.PingDns)
	if err != nil {
		os.Exit(1)
	}

	_, err = cronJob.AddFunc(durationSpeedtest, speedtest.Speedtest)
	if err != nil {
		os.Exit(1)
	}
	fmt.Println("Cron job start!")
	cronJob.Start()

	select {}
}
