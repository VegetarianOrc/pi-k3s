set shell := ["bash", "-cu"]

repos:
	helm repo add grafana https://grafana.github.io/helm-charts
	helm repo add tailscale https://pkgs.tailscale.com/helmcharts
	helm repo add 1password https://1password.github.io/connect-helm-charts
	helm repo update

tailscale:
	helm upgrade \
		--install \
		tailscale-operator \
		tailscale/tailscale-operator \
		--namespace=tailscale \
		--create-namespace \
		--set-string oauth.clientId="$TAILSCALE_CLIENT_ID" \
		--set-string oauth.clientSecret="$TAILSCALE_CLIENT_SECRET" \
		--wait

grafana:
	helm dependency build ./monitoring-stack/charts/grafana
	helm upgrade --install grafana ./monitoring-stack/charts/grafana \
		-n monitoring \
		--create-namespace \
		-f monitoring-stack/charts/grafana/values.yaml

influxdb:
	helm upgrade --install influxdb ./monitoring-stack/charts/influxdb \
		-n monitoring --create-namespace \
		-f monitoring-stack/charts/influxdb/values.yaml

telegraf:
	helm upgrade --install telegraf ./monitoring-stack/charts/telegraf \
		-n monitoring --create-namespace \
		-f monitoring-stack/charts/telegraf/values.yaml

op:
	helm upgrade --install op-connect 1password/connect --set-file connect.credentials=1password-credentials.json --set operator.create=true --set operator.token.value="$OP_TOKEN"


uninstall release namespace:
	helm uninstall {{release}} -n {{namespace}}