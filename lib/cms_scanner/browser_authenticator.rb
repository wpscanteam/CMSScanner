# frozen_string_literal: true

require 'ferrum'

module BrowserAuthenticator
  def self.authenticate(login_url)
    browser = Ferrum::Browser.new(headless: false)

    browser.goto(login_url)

    # Here you might prompt the user to manually complete the login
    puts 'Please log in through the opened browser window. Press enter once done.'
    gets # Waits for user input

    cookies = browser.cookies.all.to_a
    browser.quit

    cookies
  end
end
