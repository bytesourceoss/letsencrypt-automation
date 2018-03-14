if [[ -e Gemfile.lock  ]]
then
  bundle23 update
  touch Gemfile.lock # Update time on file so rake won't call it again
else
  bundle23 install
fi
