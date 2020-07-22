lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name    = "fluent-plugin-firelens-tag-filter"
  spec.version = "0.1.0"
  spec.authors = ["FUJIWARA Shunichiro"]
  spec.email   = ["fujiwara.shunichiro@gmail.com"]

  spec.summary       = %q{fluent plugin for AWS firelens}
  spec.description   = %q{Rewrite tags of messages sent by AWS firelens for easy handling.}
  spec.homepage      = "https://github.com/fujiwara/fluent-plugin-firelens-tag-filter"
  spec.license       = "Apache-2.0"

  test_files, files  = `git ls-files -z`.split("\x0").partition do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.files         = files
  spec.executables   = files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = test_files
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "test-unit", "~> 3.0"
  spec.add_runtime_dependency "fluentd", [">= 0.14.10", "< 2"]
end
