{{/*
Define the image configs for airflow containers
*/}}
{{- define "mantis.api.host" -}}
{{ printf "mantis-api.%s.svc.%s" (.Release.Namespace) (.Values.mantis.clusterDomain) }}
{{- end -}}
