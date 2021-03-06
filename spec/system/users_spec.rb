require 'rails_helper'

describe 'ユーザー認証のテスト' do
  describe 'ユーザー新規登録' do
    before do
      visit new_user_registration_path
    end
    context '新規登録画面に遷移' do
      it '新規登録に成功する' do
        fill_in 'user[name]', with: Faker::Name.name
        fill_in 'user[email]', with: Faker::Internet.email
        fill_in 'user[company]', with: Faker::Company.name
        fill_in 'user[postcode]', with: Faker::Address.postcode
        fill_in 'user[address]', with: Faker::Address.city
        fill_in 'user[phonenumber]', with: '09011111111'
        fill_in 'user[password]', with: 'password'
        fill_in 'user[password_confirmation]', with: 'password'
        click_button '登録する'
      end

      it '新規登録に失敗する' do
        fill_in 'user[name]', with: ''
        fill_in 'user[email]', with: ''
        fill_in 'user[password]', with: ''
        fill_in 'user[password_confirmation]', with: ''
        click_button '登録する'

        expect(page).to have_content 'エラー'
      end
    end

    describe 'ユーザーログイン' do
      let(:user) { create(:user) }
      before do
        visit new_user_session_path
      end
      context 'ログイン画面に遷移' do
        let(:test_user) { user }
        it 'ログインに成功する' do
          fill_in 'user[email]', with: test_user.email
          fill_in 'user[password]', with: test_user.password
          click_button 'ログイン'
        end

        it 'ログインに失敗する' do
          fill_in 'user[email]', with: ''
          fill_in 'user[password]', with: ''
          click_button 'ログイン'

          expect(current_path).to eq(new_user_session_path)
        end
      end
    end
  end
end