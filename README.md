Description
===========

Seeder provides a way for your app to plant seed data in its database.
It respects unique keys in your database, so that it does the equivalent of
MySQL's "on duplicate key update" (but this is database agnostic)


Install
=======

    $ gem install seeder

Usage
=====

Suppose you have a `User` model

And suppose that user model has fields "name", "age", "address", "gender"

Finally, suppose you've set up your database to have a unique key on the fields
"name" and "address" (so two people can have the same name or live at the
same address, but not both)

If you wanted to seed your data with a couple users you could do the following:

```ruby
user_seeds = [
  {
    name: "J'onn J'onzz",
    age: 94,
    address: 'Mars',
    gender: 'Male'
  },
  {
    name: "Barbara Gordon",
    age: 35,
    address: '14 Gotham Heights',
    gender: 'Female'
  }
]

Seeder.create user_seeds, [:name, :address], User
```

License
=======

See LICENSE.txt
