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
