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
puts result.client_state
puts result.notification_url
puts result.expiration_date_time
puts result.creator_id
```

#### Update

```ruby
result = client.subscriptions.update("7f105c7d-2dc5-4530-97cd-4e7ae6534c07",
                                     expiration_date_time: "2016-11-20T18:23:45.9356913Z")

puts result.id
puts result.resource
puts result.application_id
puts result.change_type
puts result.client_state
puts result.notification_url
puts result.expiration_date_time
puts result.creator_id
puts result.include_resource_data
```

#### Delete

```ruby
client.subscriptions.delete("7f105c7d-2dc5-4530-97cd-4e7ae6534c07")
```

### Calendar

#### List calendarView

reference https://docs.microsoft.com/en-us/graph/api/user-list-calendarview?view=graph-rest-1.0&tabs=http

```ruby
  result = client.calendar_view.get(start_date_time: '2020-01-01T19:00:00-08:00', end_date_time: '2020-01-02T19:00:00-08:00')
  result.each do |event|
    puts event.original_start_time_zone
    puts event.original_end_time_zone
    puts event.response_status.response
    puts event.response_status.time
    puts event.i_cal_u_id
    puts event.reminder_minutes_before_start
    puts event.is_reminder_on
  end
```

using select

```ruby
  result = client.calendar_view.select('subject,body,bodyPreview,organizer,attendees,start,end,location')
                               .get(start_date_time: 1.day.ago, end_date_time: Time.current)
  puts result.odata.context
  result.each do |event|
    puts event.id
    puts event.odata_etag
    puts event.subject
    puts event.body_preview
    puts event.body.content_type
    puts event.body.content
    puts event.start.date_time
    puts event.start.time_zone
    puts event.end.date_time
    puts event.end.time_zone
    puts event.end.date_time
    puts event.location.display_name
    puts event.location.location_type
    puts event.location.unique_id
    puts event.location.unique_id_type
    event.attendees.each do |attendee|
      puts attendee.type
      puts attendee.status.response
      puts attendee.status.time
      puts attendee.email_address.name
      puts attendee.email_address.address
    end
    puts organizer.email_address.name
    puts organizer.email_address.address
  end
```

getting next link query params

```ruby
  result = client.calendar_view.get(start_date_time: '2020-01-01T19:00:00-08:00', end_date_time: '2020-01-02T19:00:00-08:00')
  puts result.odata_next_link # ...?endDateTime=2021-01-12T22%3a39%3a15Z&startDateTime=2020-01-12T22%3a39%3a15Z&%24top=10&%24skip=10
  puts result.next_get_query # {start_date_time: '2020-01-01T19:00:00-08:00', end_date_time: '2020-01-02T19:00:00-08:00', skip: 10}
  next_result = client.calendar_view(**result.next_get_query)
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/ms_graph_rest.

