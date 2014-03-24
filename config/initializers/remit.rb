config_file = File.join(Rails.root, 'config', 'amazon.yml')
config = YAML.load_file(config_file)[Rails.env].symbolize_keys

FPS_ACCESS_KEY = config[:access_key_id]
FPS_SECRET_KEY = config[:secret_access_key]