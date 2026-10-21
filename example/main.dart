// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_aws_cloudwatch/otel_aws_cloudwatch.dart';

/// Traces Aws Cloudwatch calls with OpenTelemetry.
///
/// `otel_aws_cloudwatch` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Aws Cloudwatch call in
/// [tracedAwsCloudWatch]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'aws-cloudwatch-example');

  // Traces a Aws Cloudwatch call.
  final awsCloudWatchId = await tracedAwsCloudWatch<String>(
    operation: 'create',
    invoke: () async {
      // Make the Aws Cloudwatch call here, then report what it returned.
      const id = 'aws_cloudwatch_8f3a2c';
      return const AwsCloudWatchCallResult(
          value: id,
          result: AwsCloudWatchResult(
              namespace: 'example',
              logGroup: 'example',
              logStream: 'example',
              metricName: 'example',
              statistic: 'example',
              alarmName: 'example',
              alarmState: 'active',
              region: 'us-east-1',
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedAwsCloudWatch create returned $awsCloudWatchId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutAwsCloudWatchInstrumentationAsync.
  await runWithoutAwsCloudWatchInstrumentationAsync(
    () => tracedAwsCloudWatch<String>(
      operation: 'create',
      invoke: () async {
        const id = 'aws_cloudwatch_8f3a2c';
        return const AwsCloudWatchCallResult(
            value: id,
            result: AwsCloudWatchResult(
                namespace: 'example',
                logGroup: 'example',
                logStream: 'example',
                metricName: 'example',
                statistic: 'example',
                alarmName: 'example',
                alarmState: 'active',
                region: 'us-east-1',
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
