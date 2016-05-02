class MasonLinuxDeployer

  def settings_path
    File.expand_path('~/.mason_linux_deployer.rb.settings')
  end


  def settings_read
    result = {}
    begin
      file_contents = IO.read settings_path
      old_settings  = YAML.load file_contents
      if old_settings.class == Hash
        result = old_settings
      end
    rescue
      result = {}
    end
    result
  end


  def settings_write(settings_hash=@settings)
    File.open settings_path, 'w' do |f|
      f.write settings_hash.to_yaml
    end
  end


  def ansible_vault_read(path_to_encrypted_file)
    exit_status = 1
    ssh_key     = 'ERROR BRO'

    while exit_status != 0
      ssh_key = %x( ansible-vault view #{path_to_encrypted_file})
      exit_status = $?.exitstatus

      if exit_status != 0
        puts "Unable to decrypt sysadmin SSH key #{path_to_encrypted_file}. Please try again.\n\n"
      end
    end

    ssh_key
  end


  def write_private_key_to_temp_file(src_file)
    # For consistency, we always write the private SSH key to a temp file . Sometimes the key is encrypted (e.g., production), and sometimes not (e.g., local dev server). Rather than hardcode which keys are encrypted, we just try to figure it out by looking at the file. (Easy because we use ansible-vault for encryption.)
    # Mason 2015-07-06: cleaning up of these files seems reasonably robust; e.g. it happens even if program crashes after create but before finish.

    src_file_contents = IO.read src_file

    if src_file_contents.include? 'ANSIBLE_VAULT'
      src_file_contents = ansible_vault_read src_file
    end

    # Mason 2016-03-15: You MUST keep a ref to a Tempfile-created temp file around; if not,
    # the file will be deleted when instance is GC'd. Caused shitty 30 min headache bug, where
    # SSH connection failed because the key disappeared during connecting!

    @private_key_file = Tempfile.new 'private_key.pem'
    @private_key_file.write src_file_contents
    @private_key_file.close

    FileUtils.chmod 0600, @private_key_file.path # Mason 2016-03-15: may not be necessary (?), but doesn't hurt.

    @private_key_file.path
  end

end
