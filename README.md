OpenstaxUtilities
=================

A set of common utilities for the various OpenStax projects.

Documentation available on [rdoc.info](http://rdoc.info/github/openstax/openstax_utilities/master/frames).

To use this utility engine, include it in your Gemfile.

## Configuration

This engine accepts configuration options. These are best added in an initializer:

```rb
OSU.configure do |config|
  config.<parameter name> = <parameter value>
  ...
end
```

See `lib/openstax_utilities.rb` for valid configuration options.

## Helpers

This engine's helpers are available in the main application by preceding them with `osu.`, e.g. `osu.section_block('Heading') { "guts" }`

## Access Policies

As applications grow to include different kinds of users, including signed-in and anonymous human users, as well as other applications, the logic for controlling which user has which accesses to which resources can grow complex.  Controllers certainly aren't the place for this logic.  In a case with one kind of User, models *may* be the place for this logic but even then this makes models know way too much about other models.

Access Policies were created to be a dedicated place to store the logic controlling who has access to what.  All other code can ask the `AccessPolicy` class for this info, via the `action_allowed?` or the convenience methods `read_allowed?`, `create_allowed?`, etc.  `AccessPolicy` then delegates the access decisions off to other policy classes, of which there is normally one per kind of resource (e.g. a `UserAccessPolicy`, `ContactInfoPolicy`, etc).

These resource-specific policy classes register themselves with the main `AccessPolicy` class, telling `AccessPolicy` what kinds of resources they can handle.  E.g. the `UserAccessPolicy` tells `AccessPolicy` it handles permissions for `User` with the following call:

```rb
OSU::AccessPolicy.register(User, UserAccessPolicy)
```

This call is typically made after the policy class' definition so that it is called when the Rails application is loaded. We recommend placing the policy classes under `app/access_policies`, as all files under the `app` directory are autoloaded by Rails.

## Controller Extensions

The following methods will be added to all controllers:

`get_model(id_param, klass)` tries to use the id_param to return the model in question for
restful actions, or a new instance of klass if the id could not be found.
(e.g. on :new, :create and even :index)
By default, id_param is :id and klass is controller_name.classify.constantize.

`self.require_restful_actions_allowed!(options)` adds a before_filter that calls AccessPolicy.require_action_allowed! for all restful actions except :index. So by default it will add checks to :show, :new, :create, :edit, :update and :destroy.
options is a hash that contains any desired before_filter options, plus the optional keys :id_param and :model_class, which are passed to get_model instead.
By default, options is an empty hash.
