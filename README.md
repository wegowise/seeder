# seeder

Seeder provides a way for your app to plant seed data in its database. A
primary benefit of using this gem is that it gives you an easy way to manage
updating and deleting seed data, in addition to just creating it.

## Install

```
gem install seeder
```

## Motivation

Seed data refers to data stored in your database that is not generated
dynamically through your application. You can generate your seed data via
`rake db:seed`, which runs the contents of your `db/seeds.rb` file.

Generating seed data is easy enough. But as your application grows and
changes, you may find that you need to modify existing seed data.

You could run migrations to modify seed data, but you would need to make sure
to adjust the seeds.rb file in a consistent way. It is very easy to forget to
do this, or to make a mistake along the way.

Seeder allows you to manage all of your seeds via the seeds.rb file, without
needing to use migrations when you have to change existing seed data.

You provide a set of attributes associated with your seed data for a given
model. You also specify which attributes of the model should be treated as
"identifying attributes" - that is, which attributes should be used to
determine if an existing database row needs to be updated, or if a new row
needs to be added. Seeder then synchronizes the contents of the database table
to the attributes it is given.

## Usage

Suppose you have a `DataField` model, with attributes `data_type`, `name`, and
`description`.

To seed your database with a couple data fields, you would just include the
following in your seeds.rb file:

```ruby
seeds = [
  { data_type: "Oil", name: "btu", description: "Oil usage" },
  { data_type: "Water", name: "gallons", description: "Water usage" }
]

Seeder.create(seeds, [:data_type, :name], DataField)
```

In the example above, the `data_type` and `name` attributes will be used to
identify records that already exist in the database. The first time you seed
data, there are no existing records so two new records will be created. If you
re-seed the database, Seeder will not do anything, since the records already
exist in the database, and no attributes have changed.

Suppose the database has already been seeded, and you decide to change the
description of the Oil btu data field. All you need to do is update the
seeds.rb file and rerun the `db:seed` Rake task. Seeder will know to update the
_existing_ database record associated with Oil btu:

```ruby
seeds = [
  { data_type: "Oil", name: "btu", description: "Fuel oil usage" },
  { data_type: "Water", name: "gallons", description: "Water usage" }
]

Seeder.create(seeds, [:data_type, :name], DataField)
```

If you then want to add an Oil therms DataField record to the db, you could
just add a line to your seeds.rb file:

```ruby
seeds = [
  { data_type: "Oil", name: "btu", description: "Fuel oil usage (btu)" },
  { data_type: "Oil", name: "therms", description: "Fuel oil usage (therms)" },
  { data_type: "Water", name: "gallons", description: "Water usage" }
]

Seeder.create(seeds, [:data_type, :name], DataField)
```

The above code would adjust the description of the existing Oil btu database
row, and create a new one for Oil therms.

Now let's say you changed your mind and decided that you don't need an
Oil therms entry in the database. You could just delete the corresponding row
from seeds.rb, and Seeder will know to delete that entry from the database.

## License

See LICENSE.txt
