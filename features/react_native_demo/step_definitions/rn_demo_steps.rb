

Given(/^I have launched the SauceLabs My Demo app$/) do
  # activate the app
  AppiumConnect.activate_app
  # ensure Shopping Cart is empty
  empty_cart
  # load data for placeholder user
  user_data_source.find_user('placeholder')
end


Given(/^I am logged in to the SauceLabs My Demo app$/) do
  # activate the app
  AppiumConnect.activate_app
  # log in as a valid user
  user_data_source.find_user('valid_data')
  unless Environ.is_signed_in?
    empty_cart
    login
    Environ.set_signed_in(true)
  end
end


When(/^I enter user credentials with (.*)$/) do |creds|
  user_data_source.find_user(creds.gsub(/\s+/, '_').downcase)
  login_screen.login
end


Given(/^I have logged in a valid user$/) do
  user_data_source.find_user('valid_data')
  login
end


def empty_cart
  # ensure Shopping Cart is empty
  CartData.current = nil
  begin
    products_screen.wait_until_exists(2)
  rescue
    logout
    products_screen.load_screen
  end
  base_rn_demo_app_screen.clear_app_data
end

def login
  begin
    login_screen.load_screen
  rescue
    logout
  end
  login_screen.login
end

def logout
  ScreenManager.current_screen = base_rn_demo_app_screen if ScreenManager.current_screen.nil?
  ScreenManager.current_screen.invoke_nav_menu
  ScreenManager.current_screen.nav_menu.open_log_out
  ScreenManager.current_screen.modal_action('accept')
  login_screen.verify_screen_exists
end
