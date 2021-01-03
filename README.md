# MsGraphRest
## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ms_graph_rest'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install ms_graph_rest

## Usage

Getting a new client

```ruby
client = MsGraphRest.new_client(access_token: access_token) 
```

### Users

#### List

Reference : https://docs.microsoft.com/en-us/graph/api/user-list

```ruby
# Get all users
result = client.users.get
result.each do |user|
  puts user.display_name
  puts user.mail
  puts user.mail_nickname
  puts user.other_mails
  puts user.proxy_addresses
  puts user.user_principal_name
end

# Get a user account using a sign-in name
result = client.users.filter("identities/any(c:c/issuerAssignedId eq 'j.smith@yahoo.com')")
                     .select("displayName,id")
                     .get
result.each do |user|
  puts user.display_name
end

# Get users including their last sign-in time
result = client.users.select("displayName,userPrincipalName,signInActivity")
                     .get
puts result.odata.context
result.each do |user|
  puts user.display_name
  puts user.user_principal_name
  puts user.sign_in_activity.last_sign_in_date_time
  puts user.sign_in_activity.last_sign_in_request_id
end

# Get users including their last sign-in time
result = client.users.select("displayName,userPrincipalName,signInActivity")
                     .get
result.each do |user|
  puts user.display_name
  puts user.user_principal_name
  puts user.sign_in_activity.last_sign_in_date_time
  puts user.sign_in_activity.last_sign_in_request_id
end

# List the last sign-in time of users with a specific display name
result = client.users.filter('startswith(displayName,\'Eric\'),')
                     .select('displayName,signInActivity')
                     .get
result.each do |user|
  puts user.display_name
  puts user.sign_in_activity.last_sign_in_date_time
  puts user.sign_in_activity.last_sign_in_request_id
end
```

### Subscriptions

#### Create

```ruby
result = client.subscriptions.create(
        change_type: "created",
        notification_url: "https://webhook.azurewebsites.net/api/send/myNotifyClient",
        resource: "me/mailFolders('Inbox')/messages",
        expiration_date_time: "2016-11-20T18:23:45.9356913Z",
        client_state: "secretClientValue"
      )

puts result.odata_context
puts result.id
puts result.resource
puts result.application_id
puts result.change_type
puts result.change_type
puts result.client_state
puts result.notification_url
puts result.expiration_date_time
puts result.creator_id
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/ms_graph_rest.

