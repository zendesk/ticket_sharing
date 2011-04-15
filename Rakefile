
desc 'Run tests'
task :test do
  system "ruby -Ilib -Itest -e 'ARGV.each { |f| load f }' test/unit/*"
end

task :default => [:test]
