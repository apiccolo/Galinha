# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_galinha-on-rails_session',
  :secret      => 'd980565c5f49afb1ea0d6028c8c74708f01b621d1c0a90d438b139bcfb86daadd2af9b70528bf57ab9e515507440d68b407641c87fc347cfda9d68ad1782a4cc'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
