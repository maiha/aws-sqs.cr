# aws-sqs

aws-sqs is the unofficial AWS SQS library for the Crystal.

## Installation

1. Add the dependency to your `shard.yml`:

```yaml
dependencies:
  aws-sqs:
    github: maiha/aws-sqs.cr
```

2. Run `shards install`

## Usage

```crystal
require "aws-sqs"

client = Aws::SQS::Client.new("us-east-2", "key", "secret")
client.send_message(queue_url: queue_url, message_body: "message")

# FIFO
client.send_message(queue_url: queue_url, message_body: "message", message_group_id: "g1", message_deduplication_id: "d1")
```

## Samples

```console
$ export AWS_DEFAULT_REGION=us-east-2
$ export AWS_ACCESS_KEY_ID=XXXXXXXXXXXXXXXXXXXX
$ export AWS_SECRET_ACCESS_KEY=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

$ crystal samples/send_message.cr "https://sqs.us-east-2.amazonaws.com/123456789012/MyQueue" "hello"
```

## API

* [ ] add_permission
* [ ] change_message_visibility
* [ ] change_message_visibility_batch
* [ ] create_queue
* [ ] delete_message
* [ ] delete_message_batch
* [ ] delete_queue
* [ ] get_queue_attributes
* [ ] get_queue_url
* [ ] list_dead_letter_source_queues
* [ ] list_queue_tags
* [ ] list_queues
* [ ] purge_queue
* [ ] receive_message
* [ ] remove_permission
* [x] send_message
* [ ] send_message_batch
* [ ] set_queue_attributes
* [ ] tag_queue
* [ ] untag_queue

## Development

```console
$ crystal spec
```

## Contributing

1. Fork it (<https://github.com/maiha/aws-sqs.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [maiha](https://github.com/maiha) - creator and maintainer

## Thanks

- [sdogruyol](https://github.com/sdogruyol) - basic codes for `Aws::SQS`
- [aws-sdk-go](https://github.com/aws/aws-sdk-go) - This library derives its AWS API schema from sdk-sdk-go.
  - Apache License 2.0
