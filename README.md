# fluent-plugin-firelens-tag-filter

[Fluentd](https://fluentd.org/) output plugin to rewrite tag of message sent by [AWS Firelens](https://docs.aws.amazon.com/AmazonECS/latest/userguide/using_firelens.html).

A tag of messages from AWS firelens has format like `[containerName]-firelens-[taskID]`, but a tag of fluentd is a string separated by dots (e.g. myapp.access) usually.

fluent-plugin-firelens-tag-filter rewrites message tags from `[containerName]-firelens-[taskID]` to `[tag_prefix].[containerName].(stdout|stderr).[taskID]` by default.

## Installation

### RubyGems

```
$ gem install fluent-plugin-firelens-tag-filter
```

### Bundler

Add following line to your Gemfile:

```ruby
gem "fluent-plugin-firelens-tag-filter"
```

And then execute:

```
$ bundle
```

## Configuration

```conf
<match *-firelens-*>
  @type firelens_tag_filter
  tag_prefix ecs       # default firelens
</match>

<filter ecs.nginx.stdout.**>
  @type parser
  key_name log
  format ltsv
</filter>

<match ecs.app.**>
  # ...
</match>
```

Customize `tag` format.

```conf
<match *-firelens-*>
  @type firelens_tag_filter
  tag ${container_name}.${source}
</match>

<match app.stdout>
  # ...
</match>
```

Placeholders allowed in tag as below.

- ${container-name} : Container name in task.
- ${task_id} : ECS task ID
- ${source} : source field in record (`stdout` or `stderr`)

## Copyright

* Copyright(c) 2020- FUJIWARA Shunichiro
* License
  * Apache License, Version 2.0
