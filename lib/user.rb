class User

	# Create a new user
	def initialize
		@dirty = false
		@data = {}
	end

	# attempt to register a new user
	def register
		exists = DB[:user].filter(:username => @data['username']).count
		return nil if exists > 0

		# insert the user with status 1; awaiting verification
		DB[:user].insert(
			:username => @data['username'],
			:password => @data['password'],
			:email => @data['email'],
			:hash => @data['hash'],
			:status => 1
		)

		return true
	end

	# Retrieve a value
	def []( key )
		@data[key] || nil
	end

	# Set a value
	def []=( key, value )
		@data[key] = value
		@dirty = true
	end

end
