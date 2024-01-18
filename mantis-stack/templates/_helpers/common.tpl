{{/*
Define the host for the API service
*/}}
{{- define "mantis.api.host" -}}
{{ printf "mantis-api.%s.svc.%s" (.Release.Namespace) (.Values.mantis.clusterDomain) }}
{{- end -}}
