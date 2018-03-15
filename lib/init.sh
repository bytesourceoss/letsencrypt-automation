if [[ -e Gemfile.lock  ]]
then
  bundle update
  touch Gemfile.lock # Update time on file so rake won't call it again
else
  bundle install --path .bundle
fi
