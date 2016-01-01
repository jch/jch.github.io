# Ruby Rails Gmail SMTP #

When you want to send a quick email in a ruby script, it's easy to
send it through Gmail.  You don't have to worry about email
deliverability, and you get a record of it in your 'Sent Box'.  There
were a few outdated blog posted on how to do this, but I had to make a
few tweaks before it worked for me.

**Update:** For Ruby > 1.8.7 and Rails >= 2.2.2, you can simply
specify 'enable_starttls_auto => true'.  I put the following in
'config/initializers/actionmailer_gmail.rb'

ActionMailer::Base.smtp_settings = {
  :address => "smtp.gmail.com",
  :port => 587,
  :authentication => :plain,
  :enable_starttls_auto => true,
  :user_name => "kwiqi@kwiqi.com",
  :password => "superB1rd!"
}

## Setup ##

    sudo gem install tlsmail
    sudo gem install mail   # optional

[Ruby
Inside](http://www.rubyinside.com/how-to-use-gmails-smtp-server-with-rails-394.html)
recommended 'smtp_tls', but that gem is not compatible with Ruby
versions greater than 1.8.6.  'tlsmail' works for 1.8.6 and above.

Once you have 'tlsmail' installed you can use
[ActionMailer](http://ar.rubyonrails.org/), or [mikel's
mail](http://github.com/mikel/mail) gem to build and send the message.
If you don't want the extra dependency and speak mail headers, you can
write the raw mail message yourself.

## Rails ##

    # in environment.rb
    require 'tlsmail'
    Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)
    ActionMailer::Base.raise_delivery_errors = true
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.delivery_method = :smtp
    ActionMailer::Base.smtp_settings = {
      :address => 'smtp.gmail.com',
      :port => 587,
      :tls => true,
      :domain => 'mail.google.com',  # mail.customdomain.com if you use google apps
      :authentication => :plain,
      :user_name => 'johndoe@gmail.com',  # make sure you include the full email address
      :password => '_secret_password_'
    }


## Ruby ##

    #!/usr/bin/ruby

    begin
      require 'rubygems'
      require 'tlsmail'
      require 'mail'     # http://github.com/mikel/mail
    rescue LoadError => e
      puts "Missing dependency #{e.message}"
      exit 1
    end

    mail = Mail.new do
          from 'johndoe@gmail.com'
            to 'johndoe@gmail.com'
       subject "email subject line"
          body 'blog backup'  # add an attachment via add_file
    end
    Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)
    Net::SMTP.start('smtp.gmail.com', 587, 'gmail.com', 'johndoe@gmail.com', '_secret_', :login) do |smtp|
      smtp.send_message(mail.to_s, 'johndoe@gmail.com', 'johndoe@gmail.com')
    end

## Bonus: Email Testing with Mailtrap ##

[Mailtrap](http://rubymatt.rubyforge.org/mailtrap/) was mentioned in a
related article on
[RubyInside](http://www.rubyinside.com/mailtrap-dummy-ruby-smtp-server-ideal-for-testing-actionmailer-629.html).
The way I had been testing emails on OS X was starting a local smtp
server (sudo postfix start) and send test emails to Gmail.  Mailtrap
lets you do quick tests locally by logging the sent mail to a text
file.
