{{/* vim: set filetype=mustache: */}}

{{- define "template" -}}
{{- $name := index . 0 -}}
{{- $context := index . 1 -}}
{{- $v:= $context.Template.Name | split "/" -}}
{{- $n := len $v -}}
{{- $last := sub $n 1 | printf "_%d" | index $v -}}
{{- $wtf := $context.Template.Name | replace $last $name -}}
{{ include $wtf $context }}
{{- end -}}


{{- define "service-receipt.env" -}}
  {{- $envtype := required "A valid envtype value is required" .Values.envtype -}}
  {{- $envid := required "A valid envid value is required" .Values.envid -}}
  {{- printf "%s%s" $envtype $envid -}}
{{- end -}}


{{/* Name of the application. Example: service-receipt */}}
{{- define "service-receipt.name" -}}
  {{- printf "%s" .Chart.Name -}}
{{- end -}}


{{/* Full name of the application: <name>-<env> Example: service-receipt */}}
{{- define "service-receipt.fullname" -}}
  {{- printf "%s-%s" (include "service-receipt.name" .) (include "service-receipt.env" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/* Docker image of the service-receipt deployment. */}}
{{- define "service-receipt.container" -}}
{{- $repo := required "A valid service-receipt docker repo value is required" .Values.image.repo -}}
{{- $path := required "A valid service-receipt docker path value is required" .Values.image.path -}}
{{- $tag := required "A valid service-receipt docker tag value is required" .Values.image.tag -}}
{{- printf "%s%s:%s" $repo $path $tag -}}
{{- end -}}


{{/* Chart name and version as used by the chart label. Example: service-receipt-1.0.1 */}}
{{- define "service-receipt.chart" -}}
  {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Domain name based on envtype. zipzero.net for development, zipzero.com for production Example: zipzero.net */}}
{{- define "service-receipt.domain" -}}
  {{- if .Values.domain -}}
    {{- .Values.domain -}}
  {{- else -}}
    {{- if or (eq .Values.envtype "int") (eq .Values.envtype "dev") (eq .Values.envtype "cid") (eq .Values.envtype "tst") -}}
      {{- print "zipzero.net" -}}
    {{- else if or (eq .Values.envtype "stg") (eq .Values.envtype "uat") (eq .Values.envtype "prd") -}}
      {{- print "zipzero.com" -}}
    {{- else}}
      {{- fail (printf "ERROR: 'invalid envtype'") -}}
    {{- end -}}
  {{- end -}}
{{- end -}}



{{- define "service-receipt.dns" -}}
  {{- $host := default (include "service-receipt.fullname" .) .Values.dns.host -}}
    {{- printf "%s.%s" $host (include "service-receipt.domain" .) -}}
{{- end -}}

{{- define "service-receipt.labels" -}}
env: {{ template "service-receipt.env" . }}
envtype: {{ .Values.envtype }}
release: {{ .Release.Name | quote }}
app: service-receipt 
{{- end -}}

{{- define "chart.labels" -}}
chart: {{ template "service-receipt.chart" . }}
heritage: {{ .Release.Service | quote }}
{{- end -}}


{{- define "service-receipt.selector" -}}
app: service-receipt 
env: {{ template "service-receipt.env" . }}
{{- end -}}


{{- define "mongo.db" -}}
  {{- if .postfix }}
    {{- printf " %s-%s-service-receipt-%s-%s" .Release.Namespace (include "service-receipt.name" .) (include "service-receipt.env" .) .postfix -}}
  {{- else }}
    {{- printf " %s-%s-service-receipt-%s" .Release.Namespace (include "service-receipt.name" .) (include "service-receipt.env" .) -}}
  {{- end }}
{{- end -}}


{{- /* Create full database user name for MongoDB. Example: service-receipt-dev01 */ -}}
{{- define "mongo.user" -}}
  {{- printf "%s-%s-%s" .Release.Namespace (include "service-receipt.name" .) (include "service-receipt.env" .) -}}
{{- end -}}
