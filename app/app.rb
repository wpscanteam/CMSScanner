# frozen_string_literal: true

# Formatters
require_relative 'formatters/cli'
require_relative 'formatters/cli_no_colour'
require_relative 'formatters/cli_no_color'
require_relative 'formatters/json'

# Controllers
require_relative 'controllers/core'
require_relative 'controllers/interesting_findings'

# Models
require_relative 'models/interesting_finding'
require_relative 'models/robots_txt'
require_relative 'models/fantastico_fileslist'
require_relative 'models/search_replace_db_2'
require_relative 'models/headers'
require_relative 'models/xml_rpc'
require_relative 'models/version'
require_relative 'models/user'

# Finders
require_relative 'finders/interesting_findings'
