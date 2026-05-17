// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_aws_cloudwatch_suppression.dart';

class AwsCloudWatchResult {
  const AwsCloudWatchResult({
    this.namespace,
    this.logGroup,
    this.logStream,
    this.metricName,
    this.statistic,
    this.alarmName,
    this.alarmState,
    this.region,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? namespace;
  final String? logGroup;
  final String? logStream;
  final String? metricName;
  final String? statistic;
  final String? alarmName;
  final String? alarmState;
  final String? region;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

class AwsCloudWatchCallResult<T> {
  const AwsCloudWatchCallResult({required this.value, this.result});
  final T value;
  final AwsCloudWatchResult? result;
}

Future<T> tracedAwsCloudWatch<T>({
  required String operation,
  required Future<AwsCloudWatchCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (awsCloudWatchInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_aws_cloudwatch');
  final span = t.startSpan('cloudwatch $operation', kind: SpanKind.client);
  try {
    span.setStringAttribute('rpc.system', 'aws-api');
    span.setStringAttribute('rpc.service', 'CloudWatch');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.namespace != null) {
        span.setStringAttribute('aws.cloudwatch.namespace', res.namespace!);
      }
      if (res.logGroup != null) {
        span.setStringAttribute('aws.log.group.name', res.logGroup!);
      }
      if (res.logStream != null) {
        span.setStringAttribute('aws.log.stream.name', res.logStream!);
      }
      if (res.metricName != null) {
        span.setStringAttribute('aws.cloudwatch.metric.name', res.metricName!);
      }
      if (res.statistic != null) {
        span.setStringAttribute('aws.cloudwatch.statistic', res.statistic!);
      }
      if (res.alarmName != null) {
        span.setStringAttribute('aws.cloudwatch.alarm.name', res.alarmName!);
      }
      if (res.alarmState != null) {
        span.setStringAttribute('aws.cloudwatch.alarm.state', res.alarmState!);
      }
      if (res.region != null) {
        span.setStringAttribute('cloud.region', res.region!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('cloudwatch.error.code', res.errorCode!);
      }
      final fail =
          res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
          ErrorResource.errorType.key,
          res.errorCode ?? 'cloudwatch.error',
        );
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
