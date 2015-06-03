require "./lib/web_ui_controller"
use Rack::Reloader, 0
use Rack::Static, :urls => ["/stylesheets"], :root => "public"
run WebUiController
 