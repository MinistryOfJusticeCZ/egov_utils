# desc "Explaining what the task does"
namespace :egov_utils do

  task create_admin: :environment do
    pwd = SecureRandom.hex(8)
    u = EgovUtils::User.new(login: 'admin', mail: 'admin@admin.cz', password: pwd, password_confirmation: pwd, active: true, roles: ['admin'])
    if u.save
      puts "User 'admin' created with password '#{pwd}'"
    else
      u.errors.full_messages.each{ |m| puts m }
    end
  end

  task :require_factory_bot do
    require 'factory_bot'
  end

  task cleanup_db: :environment do
    require 'database_cleaner'

    raise "This is very dangerous method and is not meant to be run in production" if Rails.env.production?

    admins  = EgovUtils::User.where(login: 'admin').collect do |u|
      u.attributes.except('id', 'created_at', 'updated_at')
        .merge('password' => 'abcdefgh', 'password_confirmation' => 'abcdefgh')
    end
    users = EgovUtils::User.where.not(provider: nil).collect{|u| u.attributes.except('id', 'created_at', 'updated_at') }
    groups = EgovUtils::Group.where.not(provider: nil).collect{|u| u.attributes.except('id', 'created_at', 'updated_at') }
    DatabaseCleaner.clean_with :truncation
    EgovUtils::User.create(users)
    EgovUtils::User.create(groups)
    EgovUtils::User.create(admins).each do |admin|
      attrs = admins.detect{ |a| a['login'] == admin.login }
      admin.update_columns(password_digest: attrs['password_digest'])
    end
  end

  task load_staging_data: [:require_factory_bot, :cleanup_db] do
    FactoryBot.find_definitions if Rails.env.staging?
    require Rails.root.join('db', 'staging.rb')
  end
end
