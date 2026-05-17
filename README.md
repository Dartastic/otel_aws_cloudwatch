# otel_aws_cloudwatch

Dartastic OpenTelemetry bridge for AWS CloudWatch (metrics + logs + alarms).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_aws_cloudwatch/otel_aws_cloudwatch.dart';

await tracedAwsCloudWatch<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return AwsCloudWatchCallResult(value: r, result: AwsCloudWatchResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutAwsCloudWatchInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
