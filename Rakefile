require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

namespace :spec do
  desc "Download latest IHO index fixture from relaton-data-iho"
  task :update_index do
    require "net/http"
    require "uri"
    require_relative "lib/relaton/iho"

    filename = "#{Relaton::Iho::INDEXFILE}.zip"
    url = "https://raw.githubusercontent.com/relaton/relaton-data-iho/data-v2/\#{filename}"
    dest = File.join(__dir__, "spec", "fixtures", filename)

    puts "Downloading \#{url} ..."
    uri = URI.parse(url)
    response = Net::HTTP.get_response(uri)

    if response.is_a?(Net::HTTPSuccess)
      File.binwrite(dest, response.body)
      puts "Updated \#{dest} (\#{response.body.bytesize} bytes)"
    else
      abort "Failed to download: HTTP \#{response.code}"
    end
  end
end
