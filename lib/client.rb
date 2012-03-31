# Handles client calls
class Client < Controller
	# new or existing tinker
	get %r{^/(?:([A-Za-z0-9]{5})(?:/([0-9]+))?/?)?$} do |hash, revision|
		locals = {
			:tinker => Tinker.find(hash, revision),
			:doctypes => Doctype.list,
			:frameworks => Framework.list,
			:urls => APP_CONFIG['urls']
		}
		haml :index, :locals => locals
	end

	# embed mode
	get %r{^/([A-Za-z0-9]{5})(?:/([0-9]+))?/embed/?$} do |hash, revision|
		locals = {
			:tinker => Tinker.find(hash, revision),
			:urls => APP_CONFIG['urls']
		}

		headers 'X-Frame-Options' => ''
		body haml :embed, :locals => locals
	end

	# verification
	get %r{^/verify/([a-zA-Z0-9]+==)} do |encoded|
		data = Base64.decode64(encoded).split("\n")
		email = data[0] || nil
		hash = data[1] || nil

		query = DB[:user].filter(
			:email => email,
			:hash => hash,
			:status => 1
		)

		if query.count == 1
			query.update(:hash => nil, :status => 0)
		end

		redirect APP_CONFIG['urls']['client']
	end

	# save new or existing tinker
	post '/save' do
		tinker = Tinker.find(params[:hash])

		tinker['title'] = params[:title]
		tinker['description'] = params[:description]
		tinker['doctype'] = params[:doctype]
		tinker['framework'] = params[:framework]
		tinker['extensions'] = params[:extensions] || []
		tinker['normalize'] = params[:normalize] ? 1 : 0
		tinker['assets'] = params[:assets] || []
		tinker['markup'] = Base64.decode64(params[:markup])
		tinker['style'] = Base64.decode64(params[:style])
		tinker['interaction'] = Base64.decode64(params[:interaction])

		if tinker.save && !tinker['hash'].nil? && !tinker['revision'].nil?
			{
				:status => 'ok',
				:hash => tinker['hash'],
				:revision => tinker['revision']
			}.to_json
		else
			{
				:status => 'error',
				:error => {
					:code => 100,
					:message => 'Something went wrong while trying to save'
				}
			}.to_json
		end
	end

	# user registration
	post '/register' do
		user = User.new

		user['username'] = params[:username]
		user['password'] = Digest::SHA1.hexdigest(params[:password])
		user['email'] = params['email']
		user['hash'] = Digest::SHA1.hexdigest(Time.new.to_i.to_s)[0..4]

		encoded = Base64.encode64(user['email']+"\n"+user['hash'])

		p encoded

		if user.register
			{
				:status => 'ok',
				:data => params
			}.to_json
		else
			{
				:status => 'error',
				:error => {
					:code => 200,
					:message => 'Something went wrong while trying to create the user'
				}
			}.to_json
		end
	end

	# user login
	post '/login' do
		{
			:status => 'ok',
			:data => params
		}.to_json
	end

	# stylesheets
	get '/css/base.css' do
		sass :base
	end
	get '/css/embed.css' do
		sass :embed
	end

end
