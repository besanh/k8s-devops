{{- define "common.labels" -}}
{{ .Chart.Name }}
{{- end }}

{{- define "common.fullname" -}}
{{ .Release.Name }}
{{- end}}

{{- define "common.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "common.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}