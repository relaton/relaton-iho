require "webmock/rspec"
require "zip"
require "yaml"
require "relaton/iho"

INDEX_ZIP_PATH = File.join(__dir__, "..", "fixtures", "#{Relaton::Iho::INDEXFILE}.zip")

RSpec.configure do |config|
  config.before(:suite) do
    yaml = Zip::File.open(INDEX_ZIP_PATH) do |zip|
      zip.first.get_input_stream.read
    end
    index_data = YAML.safe_load(yaml, permitted_classes: [Symbol])

    type = Relaton::Index::Type.new(:iho, nil, "#{Relaton::Iho::INDEXFILE}.yaml")
    type.instance_variable_set(:@index, index_data)
    type.define_singleton_method(:actual?) { |**args| args.key?(:url) }

    Relaton::Index.pool.instance_variable_get(:@pool)[:IHO] = type
  end

  config.before(:each) do
    WebMock.reset!
    WebMock.disable_net_connect!
  end
end
