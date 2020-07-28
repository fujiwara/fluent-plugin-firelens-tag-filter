require "helper"
require "fluent/plugin/out_firelens_tag_filter.rb"

class FirelensTagFilterOutputTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
  end

  test "normal" do
    d = create_driver ""
    time = event_time("2020-07-22 11:22:33Z")
    d.run(default_tag: "app-firelens-a27287f301b06d77") do
      d.feed(time, {"foo" => "bar", "source" => "stdout"})
      d.feed(time, {"foo" => "baz", "source" => "stderr"})
      d.feed(time, {"foo" => "boo"})
    end

    events = d.events
    assert_equal 3, events.length
    assert_equal events[0], ['firelens.app.stdout.a27287f301b06d77', time, {"foo" => "bar", "source" => "stdout"}]
    assert_equal events[1], ['firelens.app.stderr.a27287f301b06d77', time, {"foo" => "baz", "source" => "stderr"}]
    assert_equal events[2], ['firelens.app.unknown.a27287f301b06d77', time, {"foo" => "boo"}]
  end

  test "tag_prefix" do
    d = create_driver "tag_prefix ecs"
    time = event_time("2020-07-22 11:22:33Z")
    d.run(default_tag: "app-firelens-a27287f301b06d77") do
      d.feed(time, {"foo" => "bar", "source" => "stdout"})
      d.feed(time, {"foo" => "baz", "source" => "stderr"})
      d.feed(time, {"foo" => "boo"})
    end

    events = d.events
    assert_equal 3, events.length
    assert_equal events[0], ['ecs.app.stdout.a27287f301b06d77', time, {"foo" => "bar", "source" => "stdout"}]
    assert_equal events[1], ['ecs.app.stderr.a27287f301b06d77', time, {"foo" => "baz", "source" => "stderr"}]
    assert_equal events[2], ['ecs.app.unknown.a27287f301b06d77', time, {"foo" => "boo"}]
  end

  test "tag" do
    d = create_driver "tag xxx.${source}.${task_id}.${container_name}"
    time = event_time("2020-07-22 11:22:33Z")
    d.run(default_tag: "app-firelens-a27287f301b06d77") do
      d.feed(time, {"foo" => "bar", "source" => "stdout"})
      d.feed(time, {"foo" => "baz", "source" => "stderr"})
      d.feed(time, {"foo" => "boo"})
    end

    events = d.events
    assert_equal 3, events.length
    assert_equal events[0], ['xxx.stdout.a27287f301b06d77.app', time, {"foo" => "bar", "source" => "stdout"}]
    assert_equal events[1], ['xxx.stderr.a27287f301b06d77.app', time, {"foo" => "baz", "source" => "stderr"}]
    assert_equal events[2], ['xxx.unknown.a27287f301b06d77.app', time, {"foo" => "boo"}]
  end

  test "unexpected" do
    d = create_driver ""
    time = event_time("2020-07-22 11:22:33Z")
    d.run(default_tag: "xxx.yyy.zzz") do
      d.feed(time, {"foo" => "bar", "source" => "stdout"})
    end

    events = d.events
    assert_equal 1, events.length
    assert_equal events[0], ['firelens.xxx.yyy.zzz', time, {"foo" => "bar", "source" => "stdout"}]
  end

  private

  def create_driver(conf)
    Fluent::Test::Driver::Output.new(Fluent::Plugin::FirelensTagFilterOutput).configure(conf)
  end
end
