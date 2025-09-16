namespace :build do
  desc "Rum npm install"
  task :install do
    system "npm install"
  end

  # icon must build before css
  desc "Build Javascript and CSS"
  task all: [ :javascript, :css ]

  desc "Build JavaScript"
  task javascript: :install do
    system "npm run build:js"
  end

  desc "Build CSS"
  task css: :install do
    system "npm run build:css"
  end
end

Rake::Task["assets:precompile"].enhance([ "build:all" ])
Rake::Task["test:prepare"].enhance([ "build:all" ])
