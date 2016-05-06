#!/usr/bin/env ruby
#
# A deploy script to drive Ansible to deploy Mason Linux onto a compatible host (which means CentOS 7 only, at least as of 2016-05-02).

require_relative '../lib/cli.rb'
require_relative '../lib/io.rb'

require 'pathname'
require 'tempfile'
require 'yaml'

PATH_TO_ME      = Pathname.new(File.expand_path(__FILE__))
PATH_TO_ROOT    = PATH_TO_ME.parent.parent
INVOCATION_NAME = PATH_TO_ME.basename


POSSIBLE_ARGS = {
  reset:       "Remove any stored 'last-used' settings (will cause defaults to be used).",
}

VALID_SETTINGS = {
  # This list allows crude user-input validation to be done, rejecting invalid input.
  ansible_playbook:    ['ansible/site.yml', 'ansible/site-debug.yml'],
  server_type:         ['vmware-fusion', 'generic'],
}

DEFAULT_SETTINGS = {
  ansible_playbook: 'ansible/site.yml',
  override_ssh_key: 'key',
  rails_app_name: 'my_cool_rails_app',
  server_type: 'generic',
  sysadmin_user_name: 'centos',
  target_host: "1.2.3.4",
  target_ssh_port: 22,
}


class MasonLinuxDeployer

  def initialize
    @settings = DEFAULT_SETTINGS
  end


  def main(args=ARGV)
      greet_user
      process_args
      confirm_settings
      perform_work
  end


  def build_command_for_playbook(playbook_name)
		key_src = @settings[:override_ssh_key]
		if [nil, ''].include? key_src
			key_src = :auto
		end

    private_key_file = write_private_key_to_temp_file key_src

    inventory_content = "[#{@settings[:server_type]}]\ndeploy_target ansible_ssh_host=#{@settings[:target_host]} ansible_ssh_port=#{@settings[:target_ssh_port]}"

    inventory_file = Tempfile.new 'inventory'
    inventory_file.write inventory_content
    inventory_file.close

    extra_vars  = "--extra-vars \""
    extra_vars += "sysadmin_username='#{@settings[:sysadmin_user_name]}' "
    extra_vars += "server_type='#{@settings[:server_type]}' "
    extra_vars += "rails_app_name='#{@settings[:rails_app_name]}' "
    extra_vars += "\" "

    command  = "ansible-playbook " # Mason 2016-03-15: you can add -vvvvv here to debug ansible troubles.
    command += "--inventory-file='#{inventory_file.path}' "
    command += "--user='#{@settings[:sysadmin_user_name]}' "
    command += "--private-key='#{private_key_file}' "
    # command += "--ask-vault-pass " if @settings[:server_type] == 'production'
    command += extra_vars
    command += "#{playbook_name}"

    command
  end


  def perform_work
    command = "#{build_command_for_playbook @settings[:ansible_playbook]}"

    settings_write

    puts "\nATTEMPTING TO DEPLOY VIA ANSIBLE AS FOLLOWS:\n"
    puts command

    Kernel.system "time #{command}"
  end

end


if __FILE__ == $PROGRAM_NAME
  me = MasonLinuxDeployer.new.main
end
