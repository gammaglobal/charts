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


{{- define "service-notification.env" -}}
  {{- $envtype := required "A valid envtype value is required" .Values.envtype -}}
  {{- $envid := required "A valid envid value is required" .Values.envid -}}
  {{- printf "%s%s" $envtype $envid -}}
{{- end -}}


{{/* Name of the application. Example: service-notification */}}
{{- define "service-notification.name" -}}
  {{- printf "%s" .Chart.Name -}}
{{- end -}}


{{/* Full name of the application: <name>-<env> Example: service-notification */}}
{{- define "service-notification.fullname" -}}
  {{- printf "%s-%s" (include "service-notification.name" .) (include "service-notification.env" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/* Docker image of the service-notification deployment. */}}
{{- define "service-notification.container" -}}
{{- $repo := required "A valid service-notification docker repo value is required" .Values.image.repo -}}
{{- $path := required "A valid service-notification docker path value is required" .Values.image.path -}}
{{- $tag := required "A valid service-notification docker tag value is required" .Values.image.tag -}}
{{- printf "%s%s:%s" $repo $path $tag -}}
{{- end -}}


{{/* Chart name and version as used by the chart label. Example: service-notification-1.0.1 */}}
{{- define "service-notification.chart" -}}
  {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Domain name based on envtype. zipzero.net for development, zipzero.com for production Example: zipzero.net */}}
{{- define "service-notification.domain" -}}
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



{{- define "service-notification.dns" -}}
  {{- $host := default (include "service-notification.fullname" .) .Values.dns.host -}}
    {{- printf "%s.%s" $host (include "service-notification.domain" .) -}}
{{- end -}}

{{- define "service-notification.labels" -}}
env: {{ template "service-notification.env" . }}
envtype: {{ .Values.envtype }}
release: {{ .Release.Name | quote }}
app: service-notification 
{{- end -}}

{{- define "chart.labels" -}}
chart: {{ template "service-notification.chart" . }}
heritage: {{ .Release.Service | quote }}
{{- end -}}


{{- define "service-notification.selector" -}}
app: service-notification 
env: {{ template "service-notification.env" . }}
{{- end -}}


{{- define "mongo.db" -}}
  {{- if .postfix }}
    {{- printf " %s-%s-service-notification-%s-%s" .Release.Namespace (include "service-notification.name" .) (include "service-notification.env" .) .postfix -}}
  {{- else }}
    {{- printf " %s-%s-service-notification-%s" .Release.Namespace (include "service-notification.name" .) (include "service-notification.env" .) -}}
  {{- end }}
{{- end -}}


{{- /* Create full database user name for MongoDB. Example: service-notification-dev01 */ -}}
{{- define "mongo.user" -}}
  {{- printf "%s-%s-%s" .Release.Namespace (include "service-notification.name" .) (include "service-notification.env" .) -}}
{{- end -}}
