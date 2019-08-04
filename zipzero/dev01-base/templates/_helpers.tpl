{{/* vim: set filetype=mustache: */}}

{{/*
Chart name and version as used by the chart label.
Example: awind-base-0.1.0
*/}}
{{- define "awind.chart" -}}
  {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- /*
Labels for all other kubernetes objects except pods.
*/ -}}
{{- define "awind.labels" -}}
release: {{ .Release.Name | quote }}
chart: {{ template "awind.chart" . }}
heritage: {{ .Release.Service | quote }}
{{- end -}}
