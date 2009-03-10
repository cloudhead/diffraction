require 'diffraction'

# Rack config
use Rack::Static, urls: ['/js', '/diffraction.html', '/index.html']
use Rack::ShowExceptions

# Run application
run Diffraction.new
