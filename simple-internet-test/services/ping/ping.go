package ping

import (
	"encoding/csv"
	"fmt"
	"log"
	"os"
	"smartcpe-test-tools/config"
	"smartcpe-test-tools/logger"
	"smartcpe-test-tools/utils/utils"
	"strconv"
	"time"

	"github.com/go-ping/ping"
)

type pingData struct {
	isError           bool
	error             string
	packetTransmitted int
	packetReceived    int
	packetLoss        float64
	roundTripMax      time.Duration
	roundTripMin      time.Duration
	roundTripAverage  time.Duration
}

var (
	pingInterval = time.Second * time.Duration(config.AppConfig.PingInterval)
	pingCount    = config.AppConfig.PingCount
	checklists   = []string{"google-01.csv", "google-02.csv", "cloudflare.csv", "facebook.csv", "youtube.csv", "tiktok.csv", "dns.csv"}
	fileMap      = map[string]string{
		"google-public-dns-a.google.com": "./data/google-01.csv",
		"google-public-dns-b.google.com": "./data/google-02.csv",
		"1.1.1.1":                        "./data/cloudflare.csv",
		"facebook.com":                   "./data/facebook.csv",
		"youtube.com":                    "./data/youtube.csv",
		"tiktok.com":                     "./data/tiktok.csv",
		config.AppConfig.DnsServer:       "./data/dns.csv",
	}
)

func init() {
	for _, checklist := range checklists {
		path := "./data/" + checklist
		if !utils.IsFileExist(path) {
			err := utils.CreateFile(path)
			if err != nil {
				log.Fatalln(err)
			}
		}
	}
}

func onReceive(pkt *ping.Packet) {
	fmt.Printf("%d bytes from %s: icmp_seq=%d time=%v\n",
		pkt.Nbytes, pkt.IPAddr, pkt.Seq, pkt.Rtt)
}

func onDuplicateReceive(pkt *ping.Packet) {
	fmt.Printf("%d bytes from %s: icmp_seq=%d time=%v ttl=%v (DUP!)\n",
		pkt.Nbytes, pkt.IPAddr, pkt.Seq, pkt.Rtt, pkt.Ttl)
}

func onFinish(stats *ping.Statistics) {
	if config.AppConfig.DebugMode {
		fmt.Printf("\n--- %s ping statistics ---\n", stats.Addr)
		fmt.Printf("%d packets transmitted, %d packets received, %v%% packet loss\n",
			stats.PacketsSent, stats.PacketsRecv, stats.PacketLoss)
		fmt.Printf("round-trip min/avg/max/stddev = %v/%v/%v/%v\n",
			stats.MinRtt, stats.AvgRtt, stats.MaxRtt, stats.StdDevRtt)
	}

	pd := newPingData(stats.PacketsSent, stats.PacketsRecv, stats.PacketLoss, stats.MaxRtt, stats.MinRtt, stats.AvgRtt)
	storeLog(*pd, stats.Addr)
}

func storeLog(pd pingData, address string) {
	var record []string
	packetTrans := strconv.Itoa(pd.packetTransmitted)
	packetRev := strconv.Itoa(pd.packetReceived)
	packetLoss := fmt.Sprintf("%f", pd.packetLoss)
	rtMax := fmt.Sprintf("%v", pd.roundTripMax)
	rtMin := fmt.Sprintf("%v", pd.roundTripMin)
	rtAvr := fmt.Sprintf("%v", pd.roundTripAverage)
	if pd.isError {
		record = append(record, "-1", pd.error)
	} else {
		record = append(record, "0", "nil")
	}
	record = append(record, packetTrans, packetRev, packetLoss, rtMax, rtMin, rtAvr)

	csvFile, err := os.OpenFile(fileMap[address], os.O_APPEND|os.O_WRONLY, os.ModeAppend)
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

func newPingDataError(err error) *pingData {
	return &pingData{
		isError:           true,
		error:             err.Error(),
		packetTransmitted: 0,
		packetReceived:    0,
		packetLoss:        0,
		roundTripMax:      0,
		roundTripMin:      0,
		roundTripAverage:  0,
	}
}

func newPingData(trans, rev int, loss float64, rtmax, rtmin, rtavr time.Duration) *pingData {
	return &pingData{
		isError:           false,
		error:             "",
		packetTransmitted: trans,
		packetReceived:    rev,
		packetLoss:        loss,
		roundTripMax:      rtmax,
		roundTripMin:      rtmin,
		roundTripAverage:  rtavr,
	}
}

func PingGoogleA() {
	logger.Logger.Info().Msg("start ping google a")
	pinger, err := ping.NewPinger("google-public-dns-a.google.com")
	if err != nil {
		pd := newPingDataError(err)
		storeLog(*pd, "google-public-dns-a.google.com")
	}

	if config.AppConfig.DebugMode {
		pinger.OnRecv = onReceive
		pinger.OnDuplicateRecv = onDuplicateReceive
	}

	pinger.OnFinish = onFinish
	pinger.Count = pingCount
	pinger.Interval = pingInterval

	fmt.Printf("PING %s (%s):\n", pinger.Addr(), pinger.IPAddr())
	err = pinger.Run()
	if err != nil {
		// if config.AppConfig.DebugMode {
		// 	log.Fatalln(err)
		// }
		pd := newPingDataError(err)
		storeLog(*pd, "google-public-dns-a.google.com")
	}
	logger.Logger.Info().Msg("completed ping google a")
}

func PingGoogleB() {
	logger.Logger.Info().Msg("start ping google b")
	pinger, err := ping.NewPinger("google-public-dns-b.google.com")
	if err != nil {
		pd := newPingDataError(err)
		storeLog(*pd, "google-public-dns-b.google.com")
	}

	if config.AppConfig.DebugMode {
		pinger.OnRecv = onReceive
		pinger.OnDuplicateRecv = onDuplicateReceive
	}

	pinger.OnFinish = onFinish
	pinger.Count = pingCount
	pinger.Interval = pingInterval

	fmt.Printf("PING %s (%s):\n", pinger.Addr(), pinger.IPAddr())
	err = pinger.Run()
	if err != nil {
		// if config.AppConfig.DebugMode {
		// 	log.Fatalln(err)
		// }
		pd := newPingDataError(err)
		storeLog(*pd, "google-public-dns-b.google.com")
	}
	logger.Logger.Info().Msg("completed ping google b")
}

func PingCloudflare() {
	logger.Logger.Info().Msg("start ping cloudflare")
	pinger, err := ping.NewPinger("1.1.1.1")
	if err != nil {
		pd := newPingDataError(err)
		storeLog(*pd, "1.1.1.1")
	}

	if config.AppConfig.DebugMode {
		pinger.OnRecv = onReceive
		pinger.OnDuplicateRecv = onDuplicateReceive
	}

	pinger.OnFinish = onFinish
	pinger.Count = pingCount
	pinger.Interval = pingInterval

	fmt.Printf("PING %s (%s):\n", pinger.Addr(), pinger.IPAddr())
	err = pinger.Run()
	if err != nil {
		// if config.AppConfig.DebugMode {
		// 	log.Fatalln(err)
		// }
		pd := newPingDataError(err)
		storeLog(*pd, "1.1.1.1")
	}
	logger.Logger.Info().Msg("completed ping cloudflare")
}

func PingFacebook() {
	logger.Logger.Info().Msg("start ping facebook")
	pinger, err := ping.NewPinger("facebook.com")
	if err != nil {
		pd := newPingDataError(err)
		storeLog(*pd, "facebook.com")
	}

	if config.AppConfig.DebugMode {
		pinger.OnRecv = onReceive
		pinger.OnDuplicateRecv = onDuplicateReceive
	}

	pinger.OnFinish = onFinish
	pinger.Count = pingCount
	pinger.Interval = pingInterval

	fmt.Printf("PING %s (%s):\n", pinger.Addr(), pinger.IPAddr())
	err = pinger.Run()
	if err != nil {
		// if config.AppConfig.DebugMode {
		// 	log.Fatalln(err)
		// }
		pd := newPingDataError(err)
		storeLog(*pd, "facebook.com")
	}
	logger.Logger.Info().Msg("completed ping facebook")
}

func PingYoutube() {
	logger.Logger.Info().Msg("start ping youtube")
	pinger, err := ping.NewPinger("youtube.com")
	if err != nil {
		pd := newPingDataError(err)
		storeLog(*pd, "youtube.com")
	}

	if config.AppConfig.DebugMode {
		pinger.OnRecv = onReceive
		pinger.OnDuplicateRecv = onDuplicateReceive
	}

	pinger.OnFinish = onFinish
	pinger.Count = pingCount
	pinger.Interval = pingInterval

	fmt.Printf("PING %s (%s):\n", pinger.Addr(), pinger.IPAddr())
	err = pinger.Run()
	if err != nil {
		// if config.AppConfig.DebugMode {
		// 	log.Fatalln(err)
		// }
		pd := newPingDataError(err)
		storeLog(*pd, "youtube.com")
	}
	logger.Logger.Info().Msg("completed ping youtube")
}

func PingTiktok() {
	logger.Logger.Info().Msg("start ping tiktok")
	pinger, err := ping.NewPinger("tiktok.com")
	if err != nil {
		pd := newPingDataError(err)
		storeLog(*pd, "tiktok.com")
	}

	if config.AppConfig.DebugMode {
		pinger.OnRecv = onReceive
		pinger.OnDuplicateRecv = onDuplicateReceive
	}

	pinger.OnFinish = onFinish
	pinger.Count = pingCount
	pinger.Interval = pingInterval

	fmt.Printf("PING %s (%s):\n", pinger.Addr(), pinger.IPAddr())
	err = pinger.Run()
	if err != nil {
		// if config.AppConfig.DebugMode {
		// 	log.Fatalln(err)
		// }
		pd := newPingDataError(err)
		storeLog(*pd, "tiktok.com")
	}
	logger.Logger.Info().Msg("completed ping tiktok")
}

func PingDns() {
	logger.Logger.Info().Msg("start ping dns")
	pinger, err := ping.NewPinger(config.AppConfig.DnsServer)
	fmt.Println(config.AppConfig.DnsServer)
	fmt.Println(fileMap[config.AppConfig.DnsServer])
	if err != nil {
		pd := newPingDataError(err)
		storeLog(*pd, config.AppConfig.DnsServer)
	}

	if config.AppConfig.DebugMode {
		pinger.OnRecv = onReceive
		pinger.OnDuplicateRecv = onDuplicateReceive
	}

	pinger.OnFinish = onFinish
	pinger.Count = pingCount
	pinger.Interval = pingInterval

	fmt.Printf("PING %s (%s):\n", pinger.Addr(), pinger.IPAddr())
	err = pinger.Run()
	if err != nil {
		// if config.AppConfig.DebugMode {
		// 	log.Fatalln(err)
		// }
		pd := newPingDataError(err)
		storeLog(*pd, config.AppConfig.DnsServer)
	}
	logger.Logger.Info().Msg("completed ping dns")
}
