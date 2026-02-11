{{- define "common.labels" -}}
{{ .Chart.Name }}
{{- end }}

{{- define "common.fullname" -}}
{{ .Release.Name }}
{{- end}}