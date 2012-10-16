guard 'bundler' do
  watch('Gemfile')
end

guard 'rspec', :version => 2, :bundler => false do
  watch(%r{^spec/(.*)_spec\.rb$})
  watch(%r{^lib/cbraspag.rb$})                       { "spec" }
  watch(%r{^lib/cbraspag/(.*)\.rb$})                 { |m| "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')                       { "spec" }
end