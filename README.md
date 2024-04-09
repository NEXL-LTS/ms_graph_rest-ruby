# MsGraphRest

[![CircleCI](https://circleci.com/gh/NEXL-LTS/ms_graph_rest-ruby.svg?style=svg)](https://circleci.com/gh/NEXL-LTS/ms_graph_rest-ruby)

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
# Get Next Page
if result.next_get_query
  next_result = client.users.get(**result.next_get_query)
  next_result.each do |user|
    puts user.display_name
  end
end


# Get users including their last sign-in time
result = client.users.select("displayName,userPrincipalName,signInActivity")
                     .get
puts result.odata_context
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

### Personal contact

#### List

Reference : https://learn.microsoft.com/en-us/graph/api/user-list-contacts

```ruby
# Get all contacts
result = client.contacts.get
result.each do |contact|
  puts contact.id
  puts contact.given_name
  puts contact.surname
  puts contact.title
  puts contact.department
  puts contact.office_location
  puts contact.profession
  puts contact.home_phones
  puts contact.mobile_phone
  puts contact.email_addresses.first&.address
end

# Get a user account using a sign-in name
result = client.contacts.filter("emailAddresses/any(a:a/address eq 'j.smith@yahoo.com')")
                        .select("displayName,id")
                        .get
result.each do |user|
  puts user.display_name
end
# Get Next Page
if result.next_get_query
  next_result = client.contacts.get(**result.next_get_query)
  next_result.each do |user|
    puts user.display_name
  end
end
```

#### Create

Reference : https://learn.microsoft.com/en-us/graph/api/user-post-contacts?view=graph-rest-1.0

```ruby
# Create a contact
result = client.contacts.create({ given_name: 'Alex', surname: "Wilber" })
puts result.id
puts result.given_name
puts result.surname
puts result.title
puts result.department
puts result.office_location
puts result.profession
puts result.home_phones
puts result.mobile_phone
puts result.email_addresses.first&.address
```

#### Update

Reference : https://learn.microsoft.com/en-us/graph/api/contact-update?view=graph-rest-1.0

```ruby
# Update a contact
result = client.contacts.update(id, { given_name: 'Alex', surname: "Wilber" })
puts result.id
puts result.given_name
puts result.surname
puts result.title
puts result.department
puts result.office_location
puts result.profession
puts result.home_phones
puts result.mobile_phone
puts result.email_addresses.first&.address
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

### Message

#### List messages

reference https://docs.microsoft.com/en-us/graph/api/user-list-messages?view=graph-rest-1.0&tabs=http

```ruby
  result = client.messages.select([:id, :sender, :subject]).get
  result.each do |message|
    puts message.id
    puts message.subject
    puts message.sender.email_address.name
    puts message.sender.email_address.address
  end
```

using $filter and $orderBy on another user's box

```ruby
  result = client.messages("users/person@example.com")
                 .filter("createdDateTime ge #{1.week.ago.iso8601} and createdDateTime lt #{1.day.ago.iso8601}")
                 .order_by('createdDateTime asc')
                 .get
  result.each do |message|
    puts message.id
    puts message.subject
    puts message.sender.email_address.name
    puts message.sender.email_address.address
  end
```

#### Get message

reference https://docs.microsoft.com/en-us/graph/api/message-get?view=graph-rest-1.0&tabs=http

get message of own inbox with default select attributes

```ruby
  message = client.message.get('[ID HERE]')

  puts message.id
  puts message.subject
  puts message.sender.email_address.name
  puts message.sender.email_address.address
```

getting a message with $select from another user

```ruby
  message = client.message("users/person@example.com")
                  .select([:id, :sender, :subject])
                  .get('[ID HERE]')
    
  puts message.id
  puts message.subject
  puts message.sender.email_address.name
  puts message.sender.email_address.address
```

getting a message using fullpath

```ruby
  message = client.message.get("users/person@example.com/messages/idhere")
    
  puts message.id
  puts message.subject
  puts message.sender.email_address.name
  puts message.sender.email_address.address
```


#### Delta messages

https://docs.microsoft.com/en-us/graph/api/message-delta?view=graph-rest-1.0&tabs=http

delta messages on own inbox

```ruby
  result = client.messages_delta('me','inbox').get
  result.value.each do |message|
    puts message.id
    puts message.subject
    puts message.sender.email_address.name
    puts message.sender.email_address.address
    # etc
  end

  if result.next_get_query
    next_result = client.messages_delta('me','inbox').get(**result.next_get_query)
  end

  if result.delta_query
    PretendStorage.save_for_later(result.delta_query)
    # ... after saving the delta
    query = PretendStorage.restore
    delta_result = client.messages_delta(**query)
  end
```

example using select on  another user's box

```ruby
  result = client.messages_delta("users/person@example.com", 'outbox')
                 .select([:sender, :to_recipients, :received_date_time, :created_date_time])
                 .received_after(Date.parse('2021-10-04'))
                 .order_by('receivedDateTime desc')
                 .get
  
  result.value.each do |message|
    # etc
  end
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

using select and different user

```ruby
  result = client.calendar_view("users/person@example.com")
                 .select('subject,body,bodyPreview,organizer,attendees,start,end,location')
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
  next_result = client.calendar_view.get(**result.next_get_query)
```

#### Get event

reference https://learn.microsoft.com/en-us/graph/api/event-get?view=graph-rest-1.0&tabs=http

```ruby
  event = client.event('me').get('AAMkADI1N2RjMDRhLTk1MjgtNGIyYS1hMTVkLTEwMGU0OWZmMTllNgBGAAAAAAC3Ox_2oD1vT7uXOvj6e7DVBwBsifJx7olQRY2oHt-3enBxAAAAAAENAABsifJx7olQRY2oHt-3enBxAABW5KLQAAA=')
  puts event.id
  puts event.odata_etag
  puts event.subject
  # ....
  event.attendees.each do |attendee|
    puts attendee.type
    puts attendee.status.response
    puts attendee.status.time
    puts attendee.email_address.name
    puts attendee.email_address.address
  end
```

#### Get recurring event instances

reference https://learn.microsoft.com/en-us/graph/api/event-list-instances?view=graph-rest-1.0&tabs=http

```ruby
  events = client.event('me').get_instances(
    'AAMkADI1N2RjMDRhLTk1MjgtNGIyYS1hMTVkLTEwMGU0OWZmMTllNgBGAAAAAAC3Ox_2oD1vT7uXOvj6e7DVBwBsifJx7olQRY2oHt-3enBxAAAAAAENAABsifJx7olQRY2oHt-3enBxAABW5KLQAAA=',
    start_date_time: '2020-01-01T19:00:00-08:00', end_date_time: '2020-01-02T19:00:00-08:00')
  )

  events.each do |event|
    puts event.id
    puts event.odata_etag
    puts event.subject
    # ....
    event.attendees.each do |attendee|
      puts attendee.type
      puts attendee.status.response
      puts attendee.status.time
      puts attendee.email_address.name
      puts attendee.email_address.address
    end
  end
```

### Groups

#### List Groups

reference https://docs.microsoft.com/en-us/graph/api/group-list?view=graph-rest-1.0&tabs=http

```ruby
  result = client.groups.get
  result.each do |group|
    puts group.id
    puts group.display_name
    puts group.description
    puts group.group_types
    puts group.visibility
    puts group.created_date_time
    puts group.mail
    puts group.mail_enabled
    puts event.mail_nickname
    puts event.security_enabled
    # etc
  end
```

using select and next link query params

```ruby
  result = client.groups
                 .select([:id, :display_name, :description, :mail, :mail_enabled])
                 .get

  result.each do |group|
    puts group.id
    puts group.display_name
    puts group.description
    puts group.mail
    puts group.mail_enabled
  end

  next_result = client.groups.get(**result.next_get_query)
```

### Planner Tasks

#### List Planner Tasks

reference https://docs.microsoft.com/en-us/graph/api/planneruser-list-tasks?view=graph-rest-1.0&tabs=http

```ruby
client.planner_tasks('me').get
client.planner_tasks('users/id-here').get
client.planner_tasks('drive/root/createdByUser').get
client.planner_tasks.get # default's to me
```

```ruby
  result = client.planner_tasks.get
  result.each do |task|
    puts task.id
    puts task.created_by.user.id
    puts task.plan_id
    puts task.bucket_id
    puts task.title
    puts task.order_hint
    puts task.assignee_priority
    puts task.created_date_time
    # etc
  end
```

#### Todo Lists ####

reference https://docs.microsoft.com/en-us/graph/api/resources/todotasklist?view=graph-rest-1.0

Fetch the users todo lists. Note the user always have one default list.
```ruby
result = client.todo_lists.get
result.each do |todo_list|
  puts todo_list.display_name
  puts "  Id:  #{todo_list.id}"
  puts "  Default List:  #{todo_list.wellknownListName == 'defaultList'}"
  puts "" 
end
```

Fetch tasks for a todo list like this

```ruby
todo_list = client.todo_lists.get.first.id
tasks = client.todo_list_tasks(todo_list).get 
tasks.each do |task|
  puts task.title
  puts task.body
  puts task.s
end
```

See all attributes here: https://docs.microsoft.com/en-us/graph/api/todotask-update?view=graph-rest-1.0&tabs=http

## In Tests

You can make the http requests read from file instead of make actual http requests.

```ruby
MsGraphRest.use_fake = true
MsGraphRest.fake_folder = "#{__dir__}/fake_client"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/ms_graph_rest.

