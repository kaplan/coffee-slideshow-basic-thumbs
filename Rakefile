# This Rakefile comes from the Jekyll orderofeverything.com modified to have the Jekyll bit removed.
# Originally from Nick Quaranto through: http://quaran.to/blog/2013/01/09/use-jekyll-scss-coffeescript-without-plugins/

desc "watch coffee and sass files"
task :default do
  pids = [
    spawn("compass watch"), # -s compressed
    spawn("coffee -b -w -o javascripts -c src/*.coffee")
  ]

  trap "INT" do
    Process.kill "INT", *pids
    exit 1
  end

  loop do
    sleep 1
  end
end
