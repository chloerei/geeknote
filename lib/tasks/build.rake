namespace :build do
  desc "Rum npm install"
  task :install do
    system "npm install"
  end

  # icon must build before css
  desc "Build Javascript and CSS"
  task :all => [:icon, :javascript, :css]

  desc "Build JavaScript"
  task :javascript => :install do
    system "npm run build:js"
  end

  desc "Build CSS"
  task :css => :install do
    system "npm run build:css"
  end

  desc "Build Icon"
  task :icon => :install do
    system "npm run build:icon"
  end
end

Rake::Task["assets:precompile"].enhance(["build:all"])
