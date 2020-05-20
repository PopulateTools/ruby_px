# RubyPx

[![Gem Version](https://badge.fury.io/rb/ruby_px.svg)](https://badge.fury.io/rb/ruby_px)
[![Build Status](https://travis-ci.org/PopulateTools/ruby_px.svg?branch=master)](https://travis-ci.org/PopulateTools/ruby_px)

Work with PC-Axis files using Ruby.

## Motivation

The Spanish Statistics Institute ([INE](http://www.ine.es/welcome.shtml)) favourite format to publish
the data is PC-Axis, a semi-plain-text format which is kind of difficult to work with unless you
have a PC with Windows installed in.

There is a library in R called [pxR](https://github.com/cran/pxR) from [@gilbellosta](https://twitter.com/gilbellosta), but I don't know more alternatives in other programming languages.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ruby_px'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ruby_px

## Usage

```ruby
# Load a dataset
dataset = RubyPx::Dataset.new 'spec/fixtures/ine-padron-2014.px'

# Query some metadata
dataset.title
=> "Población por sexo, municipios y edad (año a año)."

dataset.units
=> "personas"

dataset.source
=> "Instituto Nacional de Estadística"

dataset.contact
=> "INE E-mail:www.ine.es/infoine. Internet: www.ine.es. Tel: +34 91 583 91 00 Fax: +34 91 583 91 58"

dataset.last_updated
=> "05/10/99" # Really, INE?

dataset.creation_date
=> "20141201"

# Obtain the headings and the stubs
dataset.headings
=> ["edad (año a año)"]

dataset.stubs
=> ["sexo", "municipios"]

# Obtain the dimensions of the dataset
dataset.dimensions
=> ["sexo", "edad (año a año)", "municipios"]

# Get the list of values of a dimension
dataset.dimension('sexo')
=> ["Ambos sexos", "Hombres", "Mujeres"]

# Query the data using the method #data
# You can query the data in two ways:
# 1 - providing all the dimensions, so you'll obtain a single value
dataset.data('edad (año a año)' => 'Total', 'sexo' => 'Ambos sexos', 'municipios' => '28079-Madrid')
=> "3165235"

# 2 - providing all the dimensions except one, so you'll obtain an array
dataset.data('edad (año a año)' => 'Total', 'sexo' => 'Ambos sexos')
=> [....] # an array with the population of all places for all ages and both sexs

```

## TODO

- Refactor
- Test the gem with more files
- Speed-up the parsing time


## Development

After checking out the repository, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/PopulateTools/ruby_px. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## Thanks

Thank you [Xavier Badosa](https://twitter.com/badosa) for inspiring me with [json-stat.org](http://json-stat.org/) and the API of
the Javascript library [json-stat.com](http://json-stat.com/).

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

