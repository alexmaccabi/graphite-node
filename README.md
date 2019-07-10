## Graphite Data Node

An image running graphite,carbon-cache,redis-server. **Version**: 1.1.5

This image contains a sensible default configuration of graphite and
carbon-cache. Starting this container will, by default, bind the the following
host ports:

- `80`: the graphite web interface (Nginx with Graphite endpoint)
- `2003`: the carbon-cache line receiver (the standard graphite protocol)
- `2004`: the carbon-cache pickle receiver
- `7002`: the carbon-cache query port (used by the web interface)
- `6379`: redis server run localy for every pod

### Data volumes

Graphite data is stored at `/var/lib/graphite/storage/whisper` within the
container.

### Technical details

By default, this instance of carbon-cache uses the following retention periods
resulting in whisper files of approximately 2.5MiB.

    10s:8d,1m:31d,10m:1y,1h:5y

kube-watch.js script handles events and updates local_settings.py for memcached endpoint (graphite-cache-memcached).