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


{{- define "service-employee.env" -}}
  {{- $envtype := required "A valid envtype value is required" .Values.envtype -}}
  {{- $envid := required "A valid envid value is required" .Values.envid -}}
  {{- printf "%s%s" $envtype $envid -}}
{{- end -}}


{{/* Name of the application. Example: service-employee */}}
{{- define "service-employee.name" -}}
  {{- printf "%s" .Chart.Name -}}
{{- end -}}


{{/* Full name of the application: <name>-<env> Example: service-employee */}}
{{- define "service-employee.fullname" -}}
  {{- printf "%s-%s" (include "service-employee.name" .) (include "service-employee.env" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/* Docker image of the service-employee deployment. */}}
{{- define "service-employee.container" -}}
{{- $repo := required "A valid service-employee docker repo value is required" .Values.image.repo -}}
{{- $path := required "A valid service-employee docker path value is required" .Values.image.path -}}
{{- $tag := required "A valid service-employee docker tag value is required" .Values.image.tag -}}
{{- printf "%s%s:%s" $repo $path $tag -}}
{{- end -}}


{{/* Chart name and version as used by the chart label. Example: service-employee-1.0.1 */}}
{{- define "service-employee.chart" -}}
  {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Domain name based on envtype. zipzero.net for development, zipzero.com for production Example: zipzero.net */}}
{{- define "service-employee.domain" -}}
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



{{- define "service-employee.dns" -}}
  {{- $host := default (include "service-employee.fullname" .) .Values.dns.host -}}
    {{- printf "%s.%s" $host (include "service-employee.domain" .) -}}
{{- end -}}

{{- define "service-employee.labels" -}}
env: {{ template "service-employee.env" . }}
envtype: {{ .Values.envtype }}
release: {{ .Release.Name | quote }}
app: service-employee 
{{- end -}}

{{- define "chart.labels" -}}
chart: {{ template "service-employee.chart" . }}
heritage: {{ .Release.Service | quote }}
{{- end -}}


{{- define "service-employee.selector" -}}
app: service-employee 
env: {{ template "service-employee.env" . }}
{{- end -}}


{{- define "mongo.db" -}}
  {{- if .postfix }}
    {{- printf " %s-%s-service-employee-%s-%s" .Release.Namespace (include "service-employee.name" .) (include "service-employee.env" .) .postfix -}}
  {{- else }}
    {{- printf " %s-%s-service-employee-%s" .Release.Namespace (include "service-employee.name" .) (include "service-employee.env" .) -}}
  {{- end }}
{{- end -}}


{{- /* Create full database user name for MongoDB. Example: service-employee-dev01 */ -}}
{{- define "mongo.user" -}}
  {{- printf "%s-%s-%s" .Release.Namespace (include "service-employee.name" .) (include "service-employee.env" .) -}}
{{- end -}}
