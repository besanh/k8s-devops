{{- define "redis.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "redis.labels" -}}
app: {{ include "redis.fullname" . }}
{{- end -}}