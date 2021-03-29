require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require 'open-uri'
require 'sinatra/json'
require './models/note.rb'
require  './models/user.rb'

enable :sessions

before do
    Dotenv.load
    Cloudinary.config do |config|
        config.cloud_name = ENV['CLOUD_NAME']
        config.api_key = ENV['CLOUDINARY_API_KEY']
        config.api_secret = ENV['CLOUDINARY_API_SECRET']
    end
end

helpers do
    def logged_in?
        !!session[:user]
    end
    def current_user
        User.find(session[:user])
    end
end


get '/' do
    erb :sign_in
end

get '/home' do
    @contents = Note.all.order('id desc')
    if logged_in?
        erb :index
    else
        redirect '/'
    end
end

get '/signup' do
    erb :sign_up
end


post '/signin' do
    user = User.find_by(mail: params[:mail])
    if user && user.authenticate(params[:password])
        session[:user] = user.id
        session[:login_error] = nil
        redirect '/home'
    else
        session[:login_error] = "emailまたはパスワードが違います"
        erb :sign_in
    end
end

get '/sign_out' do
    session[:user] = nil
    redirect '/'
end


post '/signup' do
    @user = User.create(mail: params[:mail],password: params[:password],
      password_confirmation:params[:password_confirmation])
    if @user.authenticate(params[:password]) && @user.authenticate(params[:password_confirmation])
        redirect '/'
    else
        session[:signup_error] = "パスワードが一致していません"
        redirect '/signup'
    end
    if @user.persisted?
        session[:user] = @user.id
    end
end

get '/signout' do
    session[:user] = nill
    redirect '/'
end

post '/note' do
    img_url = ''
    if params[:file]
        img = params[:file]
        tempfile = img[:tempfile]
        upload = Cloudinary::Uploader.upload(tempfile.path)
        img_url = upload['url']
    end
    
    Note.create({
        title: params[:title],
        name: params[:name],
        title_page: img_url
    })
    
    redirect '/home'
end

post'/delete/note/:id' do
    Note.find(params[:id]).destroy
    redirect'/home'
end


get '/sticker/:id' do
    @note_id = params[:id]
    @stickers = Sticker.where(note_id: params[:id]).order('id desc')
    erb :sticker
end


post '/sticker/:id' do
    img_url = ''
    if params[:file]
        img = params[:file]
        tempfile = img[:tempfile]
        upload = Cloudinary::Uploader.upload(tempfile.path)
        img_url = upload['url']
    end
    
    Sticker.create({
        note_id: params[:id],
        image: img_url
    })
    
    redirect "/sticker/#{params[:id]}"
    
end

post '/delete/sticker/:id' do
    sticker = Sticker.find(params[:id])
    sticker_id = sticker.note_id
    sticker.destroy
    redirect "/sticker/#{sticker_id}"
end