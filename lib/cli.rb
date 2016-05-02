#

class MasonLinuxDeployer

  def ask(q, a='')
    puts q
    STDIN.gets.strip
  end


  def greet_user
    puts ""
    puts "--- MASON LINUX DEPLOYER ---"
    puts "(#{PATH_TO_ME})"
    puts ""
    puts "This script can provision a server and/or deploy the app."
    puts "With no args, this script will use the last-used or default settings."
    puts "Other possible args are: #{POSSIBLE_ARGS.keys.join(', ')}"
    puts ""
  end


  def die(msg="unknown problem occurred")
    abort "💀  FATAL: #{msg}"
  end


  def process_args
    # FIXME: use slop you reject!! and self-bundle you trasher!

    if ARGV.include? 'reset'
      puts "Resetting all settings to default."
      settings_write({})
    end

    previous_settings = settings_read
    if previous_settings.count > 0
      puts "Initializing with last-used settings."
      @settings.merge! previous_settings
    else
      puts "Initializing with default settings."
    end
  end


  def validate_user_input(setting, value)
    valid_values = VALID_SETTINGS[setting]
    if valid_values
      valid_values.include? value
    else
      ! [nil, ''].include?(value)
    end
  end


  def select_value_from_list(setting_name, valid_values)
    setting_name = setting_name.to_sym
    puts "\nSelect the new value for #{setting_name}:"

    answers = []
    valid_values.each_with_index do |value, index|
      num = index + 1
      puts "[#{num}] #{value}"
      answers << "#{num}"
    end
    answers << ''

    answer = ask "\n[Enter/Return] accept current value: #{@settings[setting_name]}"

    if answer == ''
      @settings[setting_name]
    elsif answers.include? answer
      index = answer.to_i - 1
      valid_values[index]
    else
      puts "Sorry, #{answer} is not a valid selection. Please try again."
      select_value_from_list setting_name, valid_values
    end
  end


  def change_setting(user_input)
    setting_number = user_input.to_i
    setting_index  = setting_number - 1
    setting_name   = @settings.keys[setting_index] # ordered hash ftw
    valid_values   = VALID_SETTINGS[setting_name]
    new_setting    = nil

    if setting_number < 1 || setting_number > @settings.count
      puts "Sorry, '#{user_input}' is not a valid selection. Please try again.\n"
    elsif valid_values
      new_setting = select_value_from_list setting_name, valid_values
    else
      new_setting  = ask "Enter value#{' (' + valid_values.join('/') +')' if valid_values} for #{setting_name}: [#{@settings[setting_name]}]"
    end

    if validate_user_input setting_name, new_setting
      @settings[setting_name] = new_setting
    else
      error_message = "👹  Warning: '#{new_setting}' is not an acceptable value for #{setting_name}; settings were not changed."
    end

    confirm_settings error_message
  end


  def confirm_settings(error_message=nil)
    if error_message
      puts ''
      puts error_message
    end
    puts "\nREADY TO DEPLOY WITH THESE SETTINGS:\n\n"
    i = 1
    @settings.each do |k, v|
      puts "[#{i.to_s}] #{k}: #{v}"
      i += 1
    end
    puts ""

    answer = ask "Enter an item number to change, or Return to continue: "

    if answer != ''
      puts ""
      change_setting answer
    end
  end

end
