# Easily cleanup DigitalOcean droplets snapshots using Docker

## Usage

Run the script with the following environment variables:
```
docker run \
  -e API_KEY="DIGITAL_OCEAN_PERSONAL_ACCESS_TOKEN" \
  -e DROPLETS="1111,2222,3333,4444" \
  -e NUMBER_SNAPSHOTS_TO_KEEP=4 (default: 3) \
  -e CRONITOR_URL="Cronitor URL to ping at the beginning and at the end of the script (optional)" \
  firmapi/digitalocean-snapshot-cleanup
```
