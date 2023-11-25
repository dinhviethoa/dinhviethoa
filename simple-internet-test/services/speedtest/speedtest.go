package speedtest

import (
	"encoding/csv"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"os/exec"
	"smartcpe-test-tools/logger"
	"smartcpe-test-tools/utils/utils"
	"time"
)

type SpeedtestInfo struct {
	Type      string    `json:"type"`
	Timestamp time.Time `json:"timestamp"`
	Ping      struct {
		Jitter  float64 `json:"jitter"`
		Latency float64 `json:"latency"`
		Low     float64 `json:"low"`
		High    float64 `json:"high"`
	} `json:"ping"`
	Download struct {
		Bandwidth int `json:"bandwidth"`
		Bytes     int `json:"bytes"`
		Elapsed   int `json:"elapsed"`
		Latency   struct {
			Iqm    float64 `json:"iqm"`
			Low    float64 `json:"low"`
			High   float64 `json:"high"`
			Jitter float64 `json:"jitter"`
		} `json:"latency"`
	} `json:"download"`
	Upload struct {
		Bandwidth int `json:"bandwidth"`
		Bytes     int `json:"bytes"`
		Elapsed   int `json:"elapsed"`
		Latency   struct {
			Iqm    float64 `json:"iqm"`
			Low    float64 `json:"low"`
			High   float64 `json:"high"`
			Jitter float64 `json:"jitter"`
		} `json:"latency"`
	} `json:"upload"`
}

type SpeedtestInfoShorten struct {
	DLTime string
	ULTime string
}

func init() {
	path := "./data/speedtest.csv"
	if !utils.IsFileExist(path) {
		err := utils.CreateFile(path)
		if err != nil {
			log.Fatalln(err)
		}
	}

}
func storeLog(sd SpeedtestInfoShorten) {
	var record []string

	record = append(record, sd.DLTime, sd.ULTime)

	csvFile, err := os.OpenFile("./data/speedtest.csv", os.O_APPEND|os.O_WRONLY, os.ModeAppend)
	if err != nil {
		log.Fatalln(err)
	}
	csvwriter := csv.NewWriter(csvFile)

	if err := csvwriter.Write(record); err != nil {
		log.Fatalln(err)
	}
	csvwriter.Flush()
	csvFile.Close()
}

func speedtest() (*SpeedtestInfoShorten, error) {
	cmd_s := exec.Command("speedtest", "-s", "2515", "-f", "json")
	stdout, err := cmd_s.Output()
	if err != nil {
		fmt.Println(err.Error())
		return nil, err
	}
	var speedtestInfo SpeedtestInfo
	err = json.Unmarshal(stdout, &speedtestInfo)
	if err != nil {
		return nil, err
	}
	download := fmt.Sprintf("%f", float64(speedtestInfo.Download.Bandwidth)/float64(125000))

	upload := fmt.Sprintf("%f", float64(speedtestInfo.Upload.Bandwidth)/float64(125000))

	return &SpeedtestInfoShorten{
		DLTime: download,
		ULTime: upload,
	}, nil

}

func Speedtest() {
	logger.Logger.Info().Msg("start speedtest")
	sd, err := speedtest()
	if err != nil {
		log.Fatalln(err)
	}
	fmt.Println("upload: ", sd.ULTime)
	fmt.Println("download: ", sd.DLTime)
	storeLog(*sd)
	logger.Logger.Info().Msg("completed speedtest")
}
