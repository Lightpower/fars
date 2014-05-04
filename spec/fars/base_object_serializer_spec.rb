require 'spec_helper'

describe Fars::BaseObjectSerializer do
  before(:all) { Book = Struct.new(:isbn, :title, :author, :price, :count) }
  let(:book) { Book.new('isbn1', 'title1', 'author1', 10, nil) }
  let(:book2) { Book.new('isbn2', 'title2', 'author2', 20.0, 4) }
  let(:book3) { Book.new('isbn3', 'title3', 'author3', 30.5, 7) }
  let(:books) { [book, book2, book3] }

  it 'serializes any object with appropriate serializer' do
    BookSerializer.new(book).as_json.should ==
      { book: { isbn: 'isbn1', title: 'title1', author: 'author1', price: '10.00', count: 0 } }
  end

  it 'includes only requested fields' do
    BookSerializer.new(book, fields: [:isbn, :title, :price]).as_json.should ==
      { book: { isbn: 'isbn1', title: 'title1', price: '10.00' } }
  end

  it 'includes only requested fields reduced by #available_attributes methods' do
    book_serializer = BookSerializer.new(book, fields: [:isbn, :title, :price])
    def book_serializer.available_attributes
      [:isbn, :price]
    end
    book_serializer.as_json.should == { book: { isbn: 'isbn1', price: '10.00' } }
  end

  it 'serializes collection which consists of objects of same tipe with appropriate serializer' do
    books.serialize(root_key: :books, serializer: 'BookSerializer', fields: [:isbn, :title, :price]).should =={ books: [
      { book: { isbn: 'isbn1', title: 'title1', price: '10.00' } },
      { book: { isbn: 'isbn2', title: 'title2', price: '20.00' } },
      { book: { isbn: 'isbn3', title: 'title3', price: '30.50' } }
    ] }.to_json
  end
end
