# Simple tools for testing internet

## Configure in config.yaml

- `ping_count`: total ping packet every time cronjob runs ping.
- `ping_interval`: timing between 2 ping's packet.
- `ping_cron_time`: schedule ping cron job.
- `speedtest_cron_time`: schedule speedtest cron job.

```bash
go build . 
./run.sh
```
