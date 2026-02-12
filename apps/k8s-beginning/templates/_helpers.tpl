{{- define "k8s-beginning.name" -}}
k8s-beginning
{{- end}}

{{- define "k8s-beginning.fullname" -}}
{{include "k8s-beginning.name" . }}
{{- end}}