{{- define "postgres.name" -}}
{{- .Chart.Name -}}
{{- end }}

{{- define "postgres.fullname" -}}
{{- .Release.Name -}}
{{- end}}

{{- define "postgres.labels" -}}
{{- range .Values.labels }}
{{- .key }}: {{ .value }}
{{- end -}}

{{- define "postgres.test" -}}
{{- .Release.Name --}}
{{- end}}