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


{{- define "service-purchase.env" -}}
  {{- $envtype := required "A valid envtype value is required" .Values.envtype -}}
  {{- $envid := required "A valid envid value is required" .Values.envid -}}
  {{- printf "%s%s" $envtype $envid -}}
{{- end -}}


{{/* Name of the application. Example: service-purchase */}}
{{- define "service-purchase.name" -}}
  {{- printf "%s" .Chart.Name -}}
{{- end -}}


{{/* Full name of the application: <name>-<env> Example: service-purchase */}}
{{- define "service-purchase.fullname" -}}
  {{- printf "%s-%s" (include "service-purchase.name" .) (include "service-purchase.env" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/* Docker image of the service-purchase deployment. */}}
{{- define "service-purchase.container" -}}
{{- $repo := required "A valid service-purchase docker repo value is required" .Values.image.repo -}}
{{- $path := required "A valid service-purchase docker path value is required" .Values.image.path -}}
{{- $tag := required "A valid service-purchase docker tag value is required" .Values.image.tag -}}
{{- printf "%s%s:%s" $repo $path $tag -}}
{{- end -}}


{{/* Chart name and version as used by the chart label. Example: service-purchase-1.0.1 */}}
{{- define "service-purchase.chart" -}}
  {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Domain name based on envtype. zipzero.net for development, zipzero.com for production Example: zipzero.net */}}
{{- define "service-purchase.domain" -}}
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



{{- define "service-purchase.dns" -}}
  {{- $host := default (include "service-purchase.fullname" .) .Values.dns.host -}}
    {{- printf "%s.%s" $host (include "service-purchase.domain" .) -}}
{{- end -}}

{{- define "service-purchase.labels" -}}
env: {{ template "service-purchase.env" . }}
envtype: {{ .Values.envtype }}
release: {{ .Release.Name | quote }}
app: service-purchase 
{{- end -}}

{{- define "chart.labels" -}}
chart: {{ template "service-purchase.chart" . }}
heritage: {{ .Release.Service | quote }}
{{- end -}}


{{- define "service-purchase.selector" -}}
app: service-purchase 
env: {{ template "service-purchase.env" . }}
{{- end -}}


{{- define "mongo.db" -}}
  {{- if .postfix }}
    {{- printf " %s-%s-service-purchase-%s-%s" .Release.Namespace (include "service-purchase.name" .) (include "service-purchase.env" .) .postfix -}}
  {{- else }}
    {{- printf " %s-%s-service-purchase-%s" .Release.Namespace (include "service-purchase.name" .) (include "service-purchase.env" .) -}}
  {{- end }}
{{- end -}}


{{- /* Create full database user name for MongoDB. Example: service-purchase-dev01 */ -}}
{{- define "mongo.user" -}}
  {{- printf "%s-%s-%s" .Release.Namespace (include "service-purchase.name" .) (include "service-purchase.env" .) -}}
{{- end -}}
