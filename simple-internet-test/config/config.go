package config

import (
	"log"
	"os"

	"github.com/spf13/viper"
)

const (
	configName = "config"
	configType = "yaml"
	configPath = "./"
	exitCode   = 1
)

type Config struct {
	DebugMode            bool   `mapstructure:"debug_mode"`
	LogPath              string `mapstructure:"log_path"`
	DnsServer            string `mapstructure:"dns_server"`
	PingCount            int    `mapstructure:"ping_count"`
	PingInterval         int    `mapstructure:"ping_interval"`
	PingCronjobTime      string `mapstructure:"ping_cron_time"`
	SpeedtestCronjobTime string `mapstructure:"speedtest_cron_time"`
}

var (
	AppConfig Config
)

func init() {
	viper.SetConfigName(configName)
	viper.SetConfigType(configType)
	viper.AddConfigPath(configPath)
	err := viper.ReadInConfig()
	if err != nil {
		log.Fatalln(err)
		os.Exit(exitCode)
	}
	err = viper.Unmarshal(&AppConfig)
	if err != nil {
		log.Fatalln(err)
		os.Exit(exitCode)
	}
}
