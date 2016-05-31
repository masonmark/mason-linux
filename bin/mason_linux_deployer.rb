#!/usr/bin/env ruby
#
# A deploy script to drive Ansible to deploy Mason Linux onto a compatible host (which means CentOS 7 only, at least as of 2016-05-02).

unless ENV['BUNDLE_GEMFILE']
  puts "  ☠   "
  puts "  ☠   ERROR: BUNDLER ENVIRONMENT REQUIRED."
  puts "  ☠   "
  puts "  ☠   It seems you are not using Bundler to"
  puts "  ☠   invoke this script. It is required."
  puts "  ☠   "
  puts "  ☠   Please re-run this script something like:"

  puts ""
  puts "       bundle exec #{$PROGRAM_NAME} #{ARGV}"

  puts "  ☠   "
  abort()
end


require 'mason'



definitions = {
  ansible_playbook: ['ansible/site.yml', 'ansible/site-debug.yml'],
  server_type: ['generic', 'vmware-fusion'],
  override_ssh_key: 'key',
  rails_app_name: 'my_cool_rails_app',
  sysadmin_username: 'centos',
  target_host: "1.2.3.4",
  target_ssh_port: 22,
}

derp = Mason::Derployer.new 'mason-linux-deployer'

definitions.each do |k, v|
  derp.define k => v
end

derp.run