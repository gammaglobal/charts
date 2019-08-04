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


{{- define "service-wallet.env" -}}
  {{- $envtype := required "A valid envtype value is required" .Values.envtype -}}
  {{- $envid := required "A valid envid value is required" .Values.envid -}}
  {{- printf "%s%s" $envtype $envid -}}
{{- end -}}


{{/* Name of the application. Example: service-wallet */}}
{{- define "service-wallet.name" -}}
  {{- printf "%s" .Chart.Name -}}
{{- end -}}


{{/* Full name of the application: <name>-<env> Example: service-wallet */}}
{{- define "service-wallet.fullname" -}}
  {{- printf "%s-%s" (include "service-wallet.name" .) (include "service-wallet.env" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/* Docker image of the service-wallet deployment. */}}
{{- define "service-wallet.container" -}}
{{- $repo := required "A valid service-wallet docker repo value is required" .Values.image.repo -}}
{{- $path := required "A valid service-wallet docker path value is required" .Values.image.path -}}
{{- $tag := required "A valid service-wallet docker tag value is required" .Values.image.tag -}}
{{- printf "%s%s:%s" $repo $path $tag -}}
{{- end -}}


{{/* Chart name and version as used by the chart label. Example: service-wallet-1.0.1 */}}
{{- define "service-wallet.chart" -}}
  {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Domain name based on envtype. zipzero.net for development, zipzero.com for production Example: zipzero.net */}}
{{- define "service-wallet.domain" -}}
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



{{- define "service-wallet.dns" -}}
  {{- $host := default (include "service-wallet.fullname" .) .Values.dns.host -}}
    {{- printf "%s.%s" $host (include "service-wallet.domain" .) -}}
{{- end -}}

{{- define "service-wallet.labels" -}}
env: {{ template "service-wallet.env" . }}
envtype: {{ .Values.envtype }}
release: {{ .Release.Name | quote }}
app: service-wallet 
{{- end -}}

{{- define "chart.labels" -}}
chart: {{ template "service-wallet.chart" . }}
heritage: {{ .Release.Service | quote }}
{{- end -}}


{{- define "service-wallet.selector" -}}
app: service-wallet 
env: {{ template "service-wallet.env" . }}
{{- end -}}


{{- define "mongo.db" -}}
  {{- if .postfix }}
    {{- printf " %s-%s-service-wallet-%s-%s" .Release.Namespace (include "service-wallet.name" .) (include "service-wallet.env" .) .postfix -}}
  {{- else }}
    {{- printf " %s-%s-service-wallet-%s" .Release.Namespace (include "service-wallet.name" .) (include "service-wallet.env" .) -}}
  {{- end }}
{{- end -}}


{{- /* Create full database user name for MongoDB. Example: service-wallet-dev01 */ -}}
{{- define "mongo.user" -}}
  {{- printf "%s-%s-%s" .Release.Namespace (include "service-wallet.name" .) (include "service-wallet.env" .) -}}
{{- end -}}
