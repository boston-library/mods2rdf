# Generated via
#  `rails generate curation_concerns:work Sample`
require 'rails_helper'
include Warden::Test::Helpers

feature 'Create a Sample' do
  context 'a logged in user' do
    let(:user_attributes) do
      { email: 'test@example.com' }
    end
    let(:user) do
      User.new(user_attributes) { |u| u.save(validate: false) }
    end

    before do
      login_as user
    end

    scenario do
      visit new_curation_concerns_sample_path
      fill_in 'Title', with: 'Test Sample'
      click_button 'Create Sample'
      expect(page).to have_content 'Test Sample'
    end
  end
end
