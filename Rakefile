require "rubygems"
require "vagrant"


#### our custom tasks (clear cache for example)
task :cc do
  env = Vagrant::Environment.new
  raise "Must run `vagrant up`" if !env.primary_vm.created?
  raise "Must be running!" if env.primary_vm.state != :running
  env.primary_vm.channel.execute("cd /srv/www/janus.supanova.org.au/local && drush cc all")
end