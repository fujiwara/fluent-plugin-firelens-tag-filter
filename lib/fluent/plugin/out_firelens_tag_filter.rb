#
# Copyright 2020- FUJIWARA Shunichiro
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "fluent/plugin/output"

module Fluent
  module Plugin
    class FirelensTagFilterOutput < Fluent::Plugin::Output
      Fluent::Plugin.register_output("firelens_tag_filter", self)
      helpers :event_emitter

      desc 'rewrote tag prefix'
      config_param :tag_prefix, :string, :default => 'firelens'

      desc 'tag format'
      config_param :tag, :string, :default => '${tag_prefix}.${container_name}.${source}.${task_id}'

      def configure(conf)
        super
        @tag_format = @tag.gsub(/%/, '%%').gsub(/\$\{(.*?)\}/, '%{\1}')
        log.debug("tag_format #{@tag_format}")
      end

      # rewrite message tag
      # from: [containerName]-firelens-[taskID]
      # to:   [tag_prefix].[containerName].(stdout|stderr).[taskID]
      def process(tag, es)
        matched = tag.match(/^(.*?)-firelens-(.*)/)
        if !matched
          log.warn("unexpected tag #{tag}")
          router.emit_stream(@tag_prefix + "." + tag, es)
          return
        end
        v = {
          tag_prefix: @tag_prefix,
          container_name: matched[1],
          task_id: matched[2],
        }
        es.each do |time, record|
          v[:source] = record['source'] || 'unknown'
          router.emit(
            sprintf(@tag_format, v),
            time,
            record,
          )
        end
      end # def process
    end # class FirelensTagFilterOutput
  end # module Plugin
end # module Fluent
