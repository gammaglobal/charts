{{/* vim: set filetype=mustache: */}}

{{/* Name of the application. Example: dev01-base */}}
{{- define "dev01-base.name" -}}
  {{- printf "%s" .Chart.Name -}}
{{- end -}}

{{- define "chart.labels" -}}
chart: {{ template "dev01-base.chart" . }}
heritage: {{ .Release.Service | quote }}
{{- end -}}

{{- define "dev01-base.env" -}}
  {{- $envtype := required "A valid envtype value is required" .Values.envtype -}}
  {{- $envid := required "A valid envid value is required" .Values.envid -}}
  {{- printf "%s%s" $envtype $envid -}}
{{- end -}}

{{/*
Chart name and version as used by the chart label.
Example: dev01-base-0.1.0
*/}}
{{- define "dev01-base.chart" -}}
  {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Full name of the application: <name>-<env> Example: dev01-base */}}
{{- define "dev01-base.fullname" -}}
  {{- printf "%s-%s" (include "dev01-base.name" .) (include "dev01-base.env" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- /*
Labels for all other kubernetes objects except pods.
*/ -}}
{{- define "dev01-base.labels" -}}
release: {{ .Release.Name | quote }}
chart: {{ template "dev01-base.chart" . }}
heritage: {{ .Release.Service | quote }}
{{- end -}}
