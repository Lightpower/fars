# Fast ActiveRecord Serializer (fars).

JSON serialization of ActiveRecord models and colections (relations or array of objects). Also can serialzie any Array or Hash with minimal syntax.

## Installation

Add this line to your application's Gemfile:

    gem 'fars'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fars

## Usage

### Serialize instance (of Class inherited from ActiveRecord::Bace)

```rb
class Customer < ActiveRecord::Base
  has_many :orders
end
```

Create serializer class named `CustomerSerializer` or `V1::CustomerSerializer`

```rb
class CustomerSerializer < Fars::BaseModelSerializer
  attributes :id, :name, :data, # attrs
                  :created_at, :updated_at, # methods
                  :orders # relations

  def created_at
    object.created_at.try(:strftime, "%F %H:%M")
  end

  def updated_at
    object.updated_at.try(:strftime, "%F %H:%M")
  end

  # _metadata (optional)
  def meta
    abilities = [:update, :destroy].select { |a| scope.can?(a, object) }
    { abilities: abilities }
  end
end
```

Then you can call #serialize method on object

```rb
# Option :scope is optional, can be used for providing metadata.
Customer.first.serialize scope: current_user
```

Available options are: `:api_version`, `:serializer`, `:scope`, `:fields`, `:add_metadata`, `:root_key`, `:params`.
Description of this options provided in [next section](#serialize-relation).

```rb
customer = Customer.first

# whould be serizlized with CustomerSerializer class
customer.serialize

# whould be serizlized with V1::CustomerSerializer class
customer.serialize api_version: 'V1'

# whould be serizlized with V1::ExtendedCustomerSerializer class
customer.serialize api_version: 'V1', serializer: "ExtendedCustomerSerializer"
```

You can specify model class and item root key in serializer:


```rb
class ExtendedCustomerSerializer < Fars::BaseModelSerializer
  self.model = Customer
  self.root_key = :client
end
```

### Serialize relation

```rb
customers = Customer.where("1 = 1")
customers.serialize
```

Available some options

```rb
customers.serialize
  root_key: :clients, # collection root key, default whoud be :customers, false if omit
  api_version: "V1", # namesapce of model serializer class
  fields: [:id, :name, :updated_at], # array of needed fields
  scope: current_user, # user or ability, can be used in serializer meta method
  add_metadata: true, # add or not item metadata, default is true if serializer respond_to? :meta
  serializer: "ExtendedCustomerSerializer", # custom model serializer class
  class_name: "Client", # item model class (can construct serializer class name from it), useful for array of objects
  metadata: { limit: 10, offset: 50 }, # collection metadata (:root_key cannot be omitted)
  params: { format: 'long' } # any parameters, can be accessed in serializes class
```

You can override serializers `#available_attributes` method for providing dynamic attributes
depending on internal serializer's logic.

```rb
class CustomerSerializer < Fars::BaseModelSerializer
  attributes :id, :name, :data, # attrs
                  :created_at, :updated_at, # methods
                  :orders # relations

  def created_at
    object.created_at.try(:strftime, "%F %H:%M")
  end

  def updated_at
    object.updated_at.try(:strftime, "%F %H:%M")
  end

  def available_attributes
     attributes = [:id, :name, :created_at, :updated_at, :orders]
     attributes << :data if scope.can?(:view_data, object)
     attributes
  end

  # _metadata (optional)
  def meta
    abilities = [:update, :destroy].select { |a| scope.can?(a, object) }
    { abilities: abilities }
  end
end
```

### Serialize array of instances

Array of instances can by serialized same as relation. In this case default collection's root_key will be constructed from first element class name (can't be empty array) or from povided class name (class_name option). 

### Serialize any Array

Provide root_key (false if omit) and serializer (proc, block or custom class)

```rb
array = %w{green blue grey}

# with proc
array.serialize root_key: :colors,
  serializer: Proc.new { |c| { color: c }

# with block
array.serialize(root_key: :colors) { |c| { color: c } }

# with custom class
class ColorSerializer < Fars::BaseObjectSerializer
  def as_json
    { color: object }
  end
end

array.serialize(root_key: :colors, serializer: 'ColorSerializer')
```
This will produce:

```rb
{ colors: [
  { color: 'green' },
  { color: 'blue' },
  { color: 'grey' }
] }.to_json
```

### Serialize Hash

Provide root_key (false if omit) and serializer (proc, block or custom class)

```rb
hash = {
  '2014-01-01' => { visitors: 23, visits: 114 },
  '2014-01-02' => { visitors: 27, visits: 217 }
}

# with proc
hash.serialize root_key: :stats,
  serializer: Proc.new { |k, v| { day: k, visitors: v[:visitors] } })

# with block
hash.serialize root_key: :stats do |k, v|
  { day: k, visitors: v[:visitors] }
end

# with custom class
# object in this case is key-value pair
class StatSerializer < Fars::BaseObjectSerializer
  def as_json
    { stat_key: object[0], stat_value: object[1] }
  end
end

hash.serialize root_key: :stats, serializer: 'StatSerializer'
```

This will produce:

```rb
{ stats: [
  { day: '2014-01-01', visitors: 23 },
  { day: '2014-01-02', visitors: 27 }
] }.to_json
```

### Serialize any object with serializer inherited from Fars::BaseObjectSerializer

```rb
Book = Struct.new(:isbn, :title, :author, :price, :count)
b1 = Book.new('isbn1', 'title1', 'author1', 10, nil)
b2 = Book.new('isbn2', 'title2', 'author2', 20.0, 4)
b3 = Book.new('isbn3', 'title3', 'author3', 30.5, 7)
books = [b1, b2, b3]

class BookSerializer < Fars::BaseObjectSerializer
  attributes :isbn, :title, :author, # attrs
             :price, :count # methods

  def price
    "%.2f" % object.price
  end

  def count
    object.count.to_i
  end
end

# serializes any object with appropriate serializer
BookSerializer.new(book, fields: [:isbn, :title, :price]).to_json
# => { book: { isbn: 'isbn1', title: 'title1', price: '10.00' } }.to_json

# serialize collection
books.serialize(root_key: :books, # can be resolved automatically for non empty array
  serializer: 'BookSerializer', # can be resolved automatically for non empty array
  fields: [:isbn, :title, :price]) # all by default

# => { books: [
#  { book: { isbn: 'isbn1', title: 'title1', price: '10.00' } },
#  { book: { isbn: 'isbn2', title: 'title2', price: '20.00' } },
#  { book: { isbn: 'isbn3', title: 'title3', price: '30.50' } }
# ] }.to_json
```

## Contributing

1. Fork it ( http://github.com/Lightpower/fars/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
